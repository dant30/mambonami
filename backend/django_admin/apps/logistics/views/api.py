# backend/django_admin/apps/logistics/views/api.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from django.shortcuts import get_object_or_404
from django.utils import timezone
from decimal import Decimal
from django.db import transaction
from ..models import Trip, TripMedia, TripLocationPing, TripProviderDecline, TripStatus
from ..serializers import (
    TripSerializer, TripAssignSerializer, TripPickupSerializer,
    TripDeliverSerializer, OTPVerifySerializer, TripLocationPingSerializer,
    TripMediaUploadSerializer
)
from ..services.matching import assign_provider_to_order
from ..services.fee_calculator import calculate_waiting_surcharge, estimate_fee
from ..services.otp_service import generate_otp, verify_otp
from ..services.geolocation import haversine
from apps.orders.models import Order
from apps.users.permissions import IsTransportProvider, IsBuyer, IsAdmin


class AvailableOrdersView(generics.ListAPIView):
    """
    Transport provider sees orders needing assignment.
    Returns Trip objects with status='offered' (available for acceptance).
    """
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    serializer_class = TripSerializer

    def get_queryset(self):
        declined_ids = TripProviderDecline.objects.filter(
            provider=self.request.user.transport_profile,
        ).values('trip_id')
        return Trip.objects.filter(
            status=TripStatus.OFFERED,
            provider__isnull=True,
        ).exclude(id__in=declined_ids).select_related('order', 'order__buyer')


class DeclineTripView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]

    def post(self, request, trip_uuid):
        trip = get_object_or_404(Trip, uuid=trip_uuid, status=TripStatus.OFFERED, provider__isnull=True)
        TripProviderDecline.objects.update_or_create(
            trip=trip,
            provider=request.user.transport_profile,
            defaults={'reason': request.data.get('reason', '')},
        )
        return Response({'message': 'Job declined for this provider.'}, status=status.HTTP_200_OK)


class AssignToMeView(generics.GenericAPIView):
    """
    Provider self-assigns to a trip.
    Status transitions: OFFERED → ACCEPTED.
    """
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]

    def post(self, request, trip_uuid):
        trip = get_object_or_404(
            Trip,
            uuid=trip_uuid,
            status=TripStatus.OFFERED,
            provider__isnull=True
        )
        
        provider = request.user.transport_profile
        
        with transaction.atomic():
            # Update trip
            trip.provider = provider
            trip.status = TripStatus.ACCEPTED
            trip.accepted_at = timezone.now()
            trip.accepted_device = request.META.get('HTTP_USER_AGENT', '')[:200]
            trip.ip_address = request.META.get('REMOTE_ADDR')
            trip.agreed_fee = trip.order.delivery_fee
            
            # Snapshot vehicle details
            trip.vehicle_type = provider.vehicle_type
            trip.vehicle_plate = provider.license_plate
            # Note: vehicle_make/model can be added to TransportProviderProfile
            
            trip.save()
            
            # Update order
            order = trip.order
            order.status = 'transport_assigned'
            order.assigned_provider = provider
            order.save(update_fields=['status', 'assigned_provider'])
            
            # Update provider's trip count
            provider.total_deliveries += 1
            provider.save(update_fields=['total_deliveries'])
        
        return Response(
            TripSerializer(trip, context={'request': request}).data,
            status=status.HTTP_200_OK
        )


class TripStartNavigationPickupView(generics.GenericAPIView):
    """
    Provider starts navigation to pickup location.
    Status: ACCEPTED → EN_ROUTE_PICKUP
    """
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]

    def post(self, request, trip_uuid):
        trip = get_object_or_404(
            Trip,
            uuid=trip_uuid,
            provider=request.user.transport_profile,
            status=TripStatus.ACCEPTED
        )
        trip.status = TripStatus.EN_ROUTE_PICKUP
        trip.started_navigation_pickup = timezone.now()
        trip.save(update_fields=['status', 'started_navigation_pickup'])
        
        return Response(
            {'message': 'Navigation started to pickup', 'status': trip.status},
            status=status.HTTP_200_OK
        )


class TripArriveAtPickupView(generics.GenericAPIView):
    """
    Provider arrives at pickup location.
    Status: EN_ROUTE_PICKUP → ARRIVED_PICKUP
    """
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    serializer_class = TripPickupSerializer

    def post(self, request, trip_uuid):
        trip = get_object_or_404(
            Trip,
            uuid=trip_uuid,
            provider=request.user.transport_profile,
            status=TripStatus.EN_ROUTE_PICKUP
        )
        
        serializer = TripPickupSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        
        trip.status = TripStatus.ARRIVED_PICKUP
        trip.arrived_pickup_at = timezone.now()
        trip.pickup_lat = serializer.validated_data.get('pickup_lat', trip.pickup_lat)
        trip.pickup_lng = serializer.validated_data.get('pickup_lng', trip.pickup_lng)
        
        # Validate against expected pickup location (optional geofence check)
        trip.save(update_fields=['status', 'arrived_pickup_at', 'pickup_lat', 'pickup_lng'])
        
        return Response(
            {
                'message': 'Arrived at pickup',
                'arrived_at': trip.arrived_pickup_at,
                'status': trip.status
            },
            status=status.HTTP_200_OK
        )


class TripPickupView(generics.GenericAPIView):
    """
    Provider picks up goods.
    Status: ARRIVED_PICKUP → PICKED_UP
    Calculates waiting surcharge if applicable.
    """
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    parser_classes = [MultiPartParser, FormParser]
    serializer_class = TripPickupSerializer

    def post(self, request, trip_uuid):
        trip = get_object_or_404(
            Trip,
            uuid=trip_uuid,
            provider=request.user.transport_profile,
            status=TripStatus.ARRIVED_PICKUP
        )
        
        serializer = TripPickupSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        
        # Calculate waiting surcharge
        waiting_surcharge = Decimal('0.00')
        if trip.arrived_pickup_at:
            waiting_minutes = int(
                (timezone.now() - trip.arrived_pickup_at).total_seconds() / 60
            )
            waiting_surcharge = calculate_waiting_surcharge(
                trip.provider,
                waiting_minutes
            )
        
        # Update trip
        trip.pickup_lat = serializer.validated_data.get('pickup_lat', trip.pickup_lat)
        trip.pickup_lng = serializer.validated_data.get('pickup_lng', trip.pickup_lng)
        trip.waiting_surcharge = waiting_surcharge
        trip.status = TripStatus.PICKED_UP
        trip.picked_up_at = timezone.now()
        trip.save()
        
        # Also create pickup photo if provided
        pickup_photo = request.FILES.get('pickup_photo')
        if pickup_photo:
            TripMedia.objects.create(
                trip=trip,
                media_type='pickup',
                image=pickup_photo,
                uploaded_by=request.user,
                latitude=trip.pickup_lat,
                longitude=trip.pickup_lng
            )
        
        # Calculate distance to delivery and update ETA
        if trip.pickup_lat and trip.pickup_lng and trip.delivery_lat and trip.delivery_lng:
            try:
                distance = haversine(
                    float(trip.pickup_lat), float(trip.pickup_lng),
                    float(trip.delivery_lat), float(trip.delivery_lng)
                )
                trip.straight_line_km = round(distance, 2)
                # Estimate ETA: average 40 km/h
                eta_minutes = max(10, int((distance / 40) * 60))
                trip.eta_minutes = eta_minutes
                trip.save(update_fields=['straight_line_km', 'eta_minutes'])
            except:
                pass
        
        return Response(
            {
                'message': 'Pickup recorded',
                'waiting_surcharge': str(waiting_surcharge),
                'total_fee': str(trip.agreed_fee + waiting_surcharge),
                'status': trip.status,
                'eta_minutes': trip.eta_minutes,
            },
            status=status.HTTP_200_OK
        )


class TripStartNavigationDeliveryView(generics.GenericAPIView):
    """
    Provider starts navigation to delivery location.
    Status: PICKED_UP → EN_ROUTE_DELIVERY
    """
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]

    def post(self, request, trip_uuid):
        trip = get_object_or_404(
            Trip,
            uuid=trip_uuid,
            provider=request.user.transport_profile,
            status=TripStatus.PICKED_UP
        )
        trip.status = TripStatus.EN_ROUTE_DELIVERY
        trip.started_navigation_delivery = timezone.now()
        trip.left_pickup_at = timezone.now()
        trip.save(update_fields=['status', 'started_navigation_delivery', 'left_pickup_at'])
        
        return Response(
            {'message': 'Navigation started to delivery', 'status': trip.status},
            status=status.HTTP_200_OK
        )


class TripArriveAtDeliveryView(generics.GenericAPIView):
    """
    Provider arrives at delivery location.
    Status: EN_ROUTE_DELIVERY → ARRIVED_DELIVERY
    """
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    serializer_class = TripDeliverSerializer

    def post(self, request, trip_uuid):
        trip = get_object_or_404(
            Trip,
            uuid=trip_uuid,
            provider=request.user.transport_profile,
            status=TripStatus.EN_ROUTE_DELIVERY
        )
        
        serializer = TripDeliverSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        
        trip.status = TripStatus.ARRIVED_DELIVERY
        trip.arrived_delivery_at = timezone.now()
        trip.delivery_lat = serializer.validated_data.get('delivery_lat', trip.delivery_lat)
        trip.delivery_lng = serializer.validated_data.get('delivery_lng', trip.delivery_lng)
        trip.save(update_fields=['status', 'arrived_delivery_at', 'delivery_lat', 'delivery_lng'])
        
        return Response(
            {
                'message': 'Arrived at delivery location',
                'arrived_at': trip.arrived_delivery_at,
                'status': trip.status
            },
            status=status.HTTP_200_OK
        )


class GenerateOTPView(generics.GenericAPIView):
    """
    Provider generates OTP for delivery.
    Status: ARRIVED_DELIVERY → OTP_PENDING
    """
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]

    def post(self, request, trip_uuid):
        trip = get_object_or_404(
            Trip,
            uuid=trip_uuid,
            provider=request.user.transport_profile,
            status=TripStatus.ARRIVED_DELIVERY
        )
        
        otp = generate_otp(trip)
        trip.status = TripStatus.OTP_PENDING
        trip.save(update_fields=['status'])
        
        # TODO: Send OTP via notification service to buyer
        # from apps.notifications.services.whatsapp import send_otp_to_buyer
        # send_otp_to_buyer.delay(trip.order.buyer.id, otp)
        
        return Response({
            'otp': otp,  # In production, don't return this; send via notification
            'expires_in': 300,
            'status': trip.status
        }, status=status.HTTP_200_OK)


class VerifyOTPView(generics.GenericAPIView):
    """
    Buyer verifies OTP to complete delivery.
    Status: OTP_PENDING → DELIVERED
    """
    permission_classes = [permissions.IsAuthenticated, IsBuyer]
    serializer_class = OTPVerifySerializer
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request, trip_uuid):
        trip = get_object_or_404(
            Trip,
            uuid=trip_uuid,
            order__buyer=request.user,
            status=TripStatus.OTP_PENDING
        )
        
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        if verify_otp(trip, serializer.validated_data['otp'], complete_delivery=False):
            delivery_photo = serializer.validated_data['delivery_photo']
            delivery_lat = serializer.validated_data.get('delivery_lat', trip.delivery_lat)
            delivery_lng = serializer.validated_data.get('delivery_lng', trip.delivery_lng)
            TripMedia.objects.create(
                trip=trip,
                media_type='delivery',
                image=delivery_photo,
                uploaded_by=request.user,
                latitude=delivery_lat,
                longitude=delivery_lng,
                caption='Proof of delivery confirmed with buyer OTP',
            )
            trip.status = TripStatus.DELIVERED
            trip.otp_verified_at = timezone.now()
            trip.completed_at = timezone.now()
            trip.save(update_fields=['status', 'otp_verified_at', 'completed_at'])
            
            # Payout will be triggered by signal
            
            return Response({
                'message': 'Delivery confirmed, payment released',
                'status': trip.status
            }, status=status.HTTP_200_OK)
        
        # Check if max attempts exceeded
        if trip.otp_attempts >= 3:
            trip.status = TripStatus.FAILED
            trip.failure_reason = 'OTP attempts exceeded'
            trip.failed_at = timezone.now()
            trip.save(update_fields=['status', 'failure_reason', 'failed_at'])
            return Response({
                'error': 'Maximum OTP attempts exceeded. Please contact support.',
                'status': trip.status
            }, status=status.HTTP_400_BAD_REQUEST)
        
        return Response({
            'error': 'Invalid or expired OTP',
            'attempts_remaining': 3 - trip.otp_attempts
        }, status=status.HTTP_400_BAD_REQUEST)


class ProviderTripListView(generics.ListAPIView):
    """List trips assigned to the authenticated provider."""
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    serializer_class = TripSerializer

    def get_queryset(self):
        return Trip.objects.filter(
            provider=self.request.user.transport_profile
        ).select_related('order', 'provider__user')


class ProviderTripDetailView(generics.RetrieveAPIView):
    """Provider views trip details."""
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    serializer_class = TripSerializer
    lookup_field = 'uuid'

    def get_queryset(self):
        return Trip.objects.filter(provider=self.request.user.transport_profile)


class BuyerTripDetailView(generics.RetrieveAPIView):
    """Buyer views trip details for their order."""
    permission_classes = [permissions.IsAuthenticated, IsBuyer]
    serializer_class = TripSerializer
    lookup_field = 'uuid'

    def get_queryset(self):
        return Trip.objects.filter(order__buyer=self.request.user)


class TripLocationPingView(generics.GenericAPIView):
    """
    Provider uploads continuous GPS location during a trip.
    """
    permission_classes = [permissions.IsAuthenticated, IsTransportProvider]
    serializer_class = TripLocationPingSerializer

    def post(self, request, trip_uuid):
        trip = get_object_or_404(
            Trip,
            uuid=trip_uuid,
            provider=request.user.transport_profile
        )
        
        serializer = TripLocationPingSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        ping = TripLocationPing.objects.create(
            trip=trip,
            latitude=serializer.validated_data['latitude'],
            longitude=serializer.validated_data['longitude'],
            heading=serializer.validated_data.get('heading'),
            speed_kmh=serializer.validated_data.get('speed_kmh'),
            accuracy_m=serializer.validated_data.get('accuracy_m'),
            altitude_m=serializer.validated_data.get('altitude_m'),
            battery_level=serializer.validated_data.get('battery_level'),
        )
        
        # Update current location on trip
        trip.current_lat = ping.latitude
        trip.current_lng = ping.longitude
        trip.save(update_fields=['current_lat', 'current_lng'])
        
        # If in delivery, update ETA based on current position
        if trip.status in [TripStatus.EN_ROUTE_DELIVERY, TripStatus.ARRIVED_DELIVERY]:
            if trip.current_lat and trip.current_lng and trip.delivery_lat and trip.delivery_lng:
                try:
                    distance = haversine(
                        float(trip.current_lat), float(trip.current_lng),
                        float(trip.delivery_lat), float(trip.delivery_lng)
                    )
                    eta_minutes = max(5, int((distance / 40) * 60))
                    trip.eta_minutes = eta_minutes
                    trip.save(update_fields=['eta_minutes'])
                except:
                    pass
        
        return Response(
            {'message': 'Location updated', 'eta_minutes': trip.eta_minutes},
            status=status.HTTP_201_CREATED
        )


class TripMediaUploadView(generics.GenericAPIView):
    """
    Provider uploads media (photos) during a trip.
    """
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]
    serializer_class = TripMediaUploadSerializer

    def post(self, request, trip_uuid):
        trip = get_object_or_404(Trip, uuid=trip_uuid)
        
        # Verify user has permission (provider or buyer)
        if request.user.role == 'transport_provider' and trip.provider.user != request.user:
            return Response(
                {'error': 'You are not the provider for this trip'},
                status=status.HTTP_403_FORBIDDEN
            )
        elif request.user.role == 'buyer' and trip.order.buyer != request.user:
            return Response(
                {'error': 'You are not the buyer for this order'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        serializer = TripMediaUploadSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        media = TripMedia.objects.create(
            trip=trip,
            media_type=serializer.validated_data['media_type'],
            image=serializer.validated_data['image'],
            uploaded_by=request.user,
            latitude=serializer.validated_data.get('latitude'),
            longitude=serializer.validated_data.get('longitude'),
            caption=serializer.validated_data.get('caption', ''),
        )
        
        return Response(
            TripMediaSerializer(media, context={'request': request}).data,
            status=status.HTTP_201_CREATED
        )


# ── Admin-only views ──

class AdminTripListView(generics.ListAPIView):
    """Admin views all trips."""
    permission_classes = [IsAdmin]
    serializer_class = TripSerializer
    queryset = Trip.objects.all().select_related('order', 'provider__user')


class AdminTripDetailView(generics.RetrieveUpdateAPIView):
    """Admin views/updates any trip."""
    permission_classes = [IsAdmin]
    serializer_class = TripSerializer
    lookup_field = 'uuid'
    queryset = Trip.objects.all()


class AdminCancelTripView(generics.GenericAPIView):
    """Admin cancels a trip (with reason)."""
    permission_classes = [IsAdmin]

    def post(self, request, trip_uuid):
        trip = get_object_or_404(Trip, uuid=trip_uuid)
        reason = request.data.get('reason', 'Cancelled by admin')
        
        trip.status = TripStatus.CANCELLED
        trip.cancelled_at = timezone.now()
        trip.cancel_reason = reason
        trip.cancelled_by = request.user
        trip.save(update_fields=['status', 'cancelled_at', 'cancel_reason', 'cancelled_by'])
        
        return Response(
            {'message': 'Trip cancelled', 'status': trip.status},
            status=status.HTTP_200_OK
        )