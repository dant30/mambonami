# django_admin/apps/logistics/views/api.py
# backend/django_admin/apps/logistics/views/api.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from django.shortcuts import get_object_or_404
from ..models import Trip
from ..serializers import TripSerializer, TripAssignSerializer, TripPickupSerializer, TripDeliverSerializer, OTPVerifySerializer
from ..services.matching import find_nearest_providers, assign_provider_to_order
from ..services.otp_service import generate_otp, verify_otp
from apps.orders.models import Order
from apps.users.permissions import IsTransportProvider, IsBuyer, IsAdmin

class AvailableOrdersView(generics.ListAPIView):
    """Transport provider sees orders needing assignment (status 'paid_escrow' and no trip)."""
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    serializer_class = TripSerializer

    def get_queryset(self):
        # Orders that are paid, not yet assigned to any provider
        return Order.objects.filter(status='paid_escrow', trip__isnull=True)

class AssignToMeView(generics.GenericAPIView):
    """Provider self-assigns to an order."""
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    serializer_class = TripAssignSerializer

    def post(self, request, order_id):
        order = get_object_or_404(Order, id=order_id, status='paid_escrow', trip__isnull=True)
        provider = request.user.transport_profile
        trip = assign_provider_to_order(order, provider)
        return Response(TripSerializer(trip).data, status=status.HTTP_201_CREATED)

class ProviderTripListView(generics.ListAPIView):
    """List trips assigned to the authenticated provider."""
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    serializer_class = TripSerializer

    def get_queryset(self):
        return Trip.objects.filter(provider=self.request.user.transport_profile)

class ProviderTripDetailView(generics.RetrieveUpdateAPIView):
    """Provider updates pickup/delivery."""
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    serializer_class = TripSerializer
    parser_classes = [MultiPartParser, FormParser]
    lookup_field = 'uuid'

    def get_queryset(self):
        return Trip.objects.filter(provider=self.request.user.transport_profile)

    def patch(self, request, *args, **kwargs):
        trip = self.get_object()
        if 'pickup' in request.path:  # or use separate actions
            serializer = TripPickupSerializer(data=request.data, partial=True)
            if serializer.is_valid():
                trip.pickup_lat = serializer.validated_data.get('pickup_lat', trip.pickup_lat)
                trip.pickup_lng = serializer.validated_data.get('pickup_lng', trip.pickup_lng)
                trip.pickup_photo = serializer.validated_data.get('pickup_photo', trip.pickup_photo)
                trip.status = 'picked_up'
                trip.picked_up_at = timezone.now()
                trip.save()
                return Response(TripSerializer(trip).data)
        elif 'deliver' in request.path:
            serializer = TripDeliverSerializer(data=request.data, partial=True)
            if serializer.is_valid():
                # Generate OTP
                otp = generate_otp(trip)
                # TODO: send OTP to buyer via notification
                return Response({'otp': otp, 'message': 'OTP generated for delivery'})
        return super().patch(request, *args, **kwargs)

class GenerateOTPView(generics.GenericAPIView):
    """Provider generates OTP for delivery."""
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    def post(self, request, trip_uuid):
        trip = get_object_or_404(Trip, uuid=trip_uuid, provider=request.user.transport_profile, status='picked_up')
        otp = generate_otp(trip)
        # TODO: send via notification (WhatsApp/SMS)
        return Response({'otp': otp, 'expires_in': 300}, status=status.HTTP_200_OK)

class VerifyOTPView(generics.GenericAPIView):
    """Buyer verifies OTP to complete delivery."""
    permission_classes = [permissions.IsAuthenticated, IsBuyer]
    serializer_class = OTPVerifySerializer
    def post(self, request, trip_uuid):
        trip = get_object_or_404(Trip, uuid=trip_uuid, order__buyer=request.user)
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        if verify_otp(trip, serializer.validated_data['otp']):
            # Trigger payout (via signal or task)
            return Response({'message': 'Delivery confirmed, payment released'}, status=status.HTTP_200_OK)
        return Response({'error': 'Invalid or expired OTP'}, status=status.HTTP_400_BAD_REQUEST)