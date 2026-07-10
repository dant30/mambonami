# backend/django_admin/apps/logistics/views/api.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from django.shortcuts import get_object_or_404
from django.utils import timezone
from decimal import Decimal
from ..models import Trip
from ..serializers import (
    TripSerializer, TripAssignSerializer, TripPickupSerializer,
    TripDeliverSerializer, OTPVerifySerializer
)
from ..services.matching import assign_provider_to_order
from ..services.fee_calculator import calculate_waiting_surcharge
from ..services.otp_service import generate_otp, verify_otp
from apps.orders.models import Order
from apps.users.permissions import IsTransportProvider, IsBuyer, IsAdmin

class AvailableOrdersView(generics.ListAPIView):
    """Transport provider sees orders needing assignment (status 'paid_escrow' and no trip)."""
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    serializer_class = TripSerializer

    def get_queryset(self):
        # Trips that are offered (not yet accepted) or orders with no trip yet
        # We return Trip objects with status='offered' (or orders without trip)
        # For simplicity, we return trips with status='offered'
        return Trip.objects.filter(status='offered')


class AssignToMeView(generics.GenericAPIView):
    """Provider self-assigns to an order (creates or updates a trip with status 'accepted')."""
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    serializer_class = TripAssignSerializer

    def post(self, request, order_id):
        order = get_object_or_404(Order, id=order_id, status='paid_escrow')
        # Check if trip already exists and is offered
        trip, created = Trip.objects.get_or_create(order=order, defaults={
            'provider': request.user.transport_profile,
            'status': 'accepted',
            'agreed_fee': order.delivery_fee,  # pre-calculated
            'accepted_at': timezone.now(),
        })
        if not created:
            # If trip exists and is offered, update to accepted
            if trip.status == 'offered':
                trip.provider = request.user.transport_profile
                trip.status = 'accepted'
                trip.accepted_at = timezone.now()
                trip.agreed_fee = order.delivery_fee
                trip.save()
            else:
                return Response(
                    {'error': 'This trip is no longer available'},
                    status=status.HTTP_400_BAD_REQUEST
                )
        # Update order status to transport_assigned
        order.status = 'transport_assigned'
        order.assigned_provider = request.user.transport_profile
        order.save(update_fields=['status', 'assigned_provider'])
        return Response(TripSerializer(trip).data, status=status.HTTP_201_CREATED)


class TripArriveAtFarmView(generics.GenericAPIView):
    """Provider marks arrival at farm to start waiting time tracking."""
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    
    def post(self, request, trip_uuid):
        trip = get_object_or_404(
            Trip, 
            uuid=trip_uuid, 
            provider=request.user.transport_profile,
            status='accepted'
        )
        trip.arrived_at_farm = timezone.now()
        trip.save(update_fields=['arrived_at_farm'])
        
        return Response(
            {
                'message': 'Arrived at farm',
                'arrived_at': trip.arrived_at_farm,
                'waiting_grace_minutes': trip.provider.waiting_grace_minutes
            },
            status=status.HTTP_200_OK
        )


class TripPickupView(generics.GenericAPIView):
    """Provider marks pickup, calculates waiting surcharge if applicable."""
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    parser_classes = [MultiPartParser, FormParser]
    serializer_class = TripPickupSerializer
    
    def post(self, request, trip_uuid):
        trip = get_object_or_404(
            Trip,
            uuid=trip_uuid,
            provider=request.user.transport_profile,
            status='accepted'
        )
        
        serializer = TripPickupSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        
        # Calculate waiting time if arrived_at_farm is set
        waiting_surcharge = Decimal('0.00')
        if trip.arrived_at_farm:
            waiting_minutes = int(
                (timezone.now() - trip.arrived_at_farm).total_seconds() / 60
            )
            waiting_surcharge = calculate_waiting_surcharge(
                trip.provider,
                waiting_minutes
            )
        
        # Update trip
        trip.pickup_lat = serializer.validated_data.get('pickup_lat', trip.pickup_lat)
        trip.pickup_lng = serializer.validated_data.get('pickup_lng', trip.pickup_lng)
        trip.pickup_photo = serializer.validated_data.get('pickup_photo', trip.pickup_photo)
        trip.waiting_surcharge = waiting_surcharge
        trip.status = 'picked_up'
        trip.picked_up_at = timezone.now()
        trip.save()
        
        return Response(
            {
                'message': 'Pickup recorded',
                'waiting_surcharge': str(waiting_surcharge),
                'total_fee': str(trip.agreed_fee + waiting_surcharge),
                'status': 'picked_up'
            },
            status=status.HTTP_200_OK
        )


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