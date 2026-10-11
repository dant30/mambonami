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
    TripMediaUploadSerializer, TripMediaSerializer,
)
from ..services.matching import assign_provider_to_order
from ..services.fee_calculator import calculate_waiting_surcharge, estimate_fee
from ..services.otp_service import generate_otp, verify_otp
from ..services.geolocation import haversine
from apps.orders.models import Order
from apps.orders.services.state_machine import OrderStateMachine
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
        provider = request.user.transport_profile
        with transaction.atomic():
            trip = get_object_or_404(
                Trip.objects.select_for_update().select_related('order'),
                uuid=trip_uuid,
                status=TripStatus.OFFERED,
                provider__isnull=True,
            )
            order = Order.objects.select_for_update().get(pk=trip.order_id)
            if order.status != 'paid_escrow' or not OrderStateMachine.has_successful_payment(order):
                return Response({'error': 'A successfully paid order is required before transport can be assigned.'}, status=status.HTTP_409_CONFLICT)
            if not order.are_all_farmers_ready():
                return Response({'error': 'All farmer suborders must be ready before transport can be assigned.'}, status=status.HTTP_409_CONFLICT)
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
            order.assigned_provider = provider
            order.save(update_fields=['assigned_provider', 'updated_at'])
            OrderStateMachine.transition(order, 'transport_assigned', user=request.user)
            
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
            status=TripStatus.ACCEPTED,
            order__status='transport_assigned',
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
            status=TripStatus.EN_ROUTE_PICKUP,
            order__status='transport_assigned',
        )
        
        serializer = TripPickupSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        if trip.order.status != 'transport_assigned' or not OrderStateMachine.has_successful_payment(trip.order):
            return Response({'error': 'Pickup is blocked until the order is paid and assigned.'}, status=status.HTTP_409_CONFLICT)
        if not trip.order.are_all_farmers_ready():
            return Response({'error': 'All farmer suborders must be ready before pickup.'}, status=status.HTTP_409_CONFLICT)
        
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
            status=TripStatus.ARRIVED_PICKUP,
            order__status='transport_assigned',
        )
        
        serializer = TripPickupSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        if not OrderStateMachine.has_successful_payment(trip.order) or not trip.order.are_all_farmers_ready():
            return Response({'error': 'Pickup is blocked until payment is verified and all farmer suborders are ready.'}, status=status.HTTP_409_CONFLICT)
        if trip.order.status != 'transport_assigned' or not OrderStateMachine.has_successful_payment(trip.order):
            return Response({'error': 'Pickup is blocked until the order has a successful payment and a transport assignment.'}, status=status.HTTP_409_CONFLICT)
        if not trip.order.are_all_farmers_ready():
            return Response({'error': 'All farmer suborders must be ready before pickup.'}, status=status.HTTP_409_CONFLICT)
        
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
        
        with transaction.atomic():
            trip.pickup_lat = serializer.validated_data.get('pickup_lat', trip.pickup_lat)
            trip.pickup_lng = serializer.validated_data.get('pickup_lng', trip.pickup_lng)
            trip.waiting_surcharge = waiting_surcharge
            trip.status = TripStatus.PICKED_UP
            trip.picked_up_at = timezone.now()
            trip.save()
            order = Order.objects.select_for_update().get(pk=trip.order_id)
            OrderStateMachine.transition(order, 'picked_up', user=request.user)
        
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
            status=TripStatus.PICKED_UP,
            order__status='picked_up',
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
            status=TripStatus.EN_ROUTE_DELIVERY,
            order__status='picked_up',
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
            status__in=[TripStatus.ARRIVED_DELIVERY, TripStatus.OTP_PENDING],
            order__status='picked_up',
        )
        
        otp = generate_otp(trip)
        from apps.notifications.services.sms import send_otp_message

        sms_result = send_otp_message(trip.order.buyer.phone, otp)
        if sms_result.get('status') != 'success':
            trip.otp_hash = ''
            trip.otp_expires_at = None
            trip.otp_attempts = 0
            trip.save(update_fields=['otp_hash', 'otp_expires_at', 'otp_attempts'])
            return Response(
                {'error': 'Could not send the delivery code to the buyer. Try again.'},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        trip.status = TripStatus.OTP_PENDING
        trip.save(update_fields=['status'])

        return Response({
            'message': 'Delivery code sent to the buyer.',
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
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        with transaction.atomic():
            trip = get_object_or_404(
                Trip.objects.select_for_update().select_related('order'),
                uuid=trip_uuid,
                order__buyer=request.user,
            )
            if trip.status == TripStatus.DELIVERED and trip.order.status == 'delivered':
                return Response({'message': 'Delivery was already confirmed.', 'status': trip.status}, status=status.HTTP_200_OK)
            if trip.status != TripStatus.OTP_PENDING or trip.order.status != 'picked_up':
                return Response({'error': 'This trip is not awaiting delivery confirmation.'}, status=status.HTTP_409_CONFLICT)

            if not verify_otp(trip, serializer.validated_data['otp'], complete_delivery=False):
                if trip.otp_attempts >= 3 or trip.status == TripStatus.FAILED:
                    return Response({
                        'error': 'Maximum OTP attempts exceeded or the code expired. Contact support.',
                        'status': trip.status,
                    }, status=status.HTTP_400_BAD_REQUEST)
                return Response({
                    'error': 'Invalid or expired OTP',
                    'attempts_remaining': max(0, 3 - trip.otp_attempts),
                }, status=status.HTTP_400_BAD_REQUEST)

            now = timezone.now()
            TripMedia.objects.create(
                trip=trip,
                media_type='delivery',
                image=serializer.validated_data['delivery_photo'],
                uploaded_by=request.user,
                latitude=serializer.validated_data.get('delivery_lat', trip.delivery_lat),
                longitude=serializer.validated_data.get('delivery_lng', trip.delivery_lng),
                caption='Proof of delivery confirmed with buyer OTP',
            )
            trip.status = TripStatus.DELIVERED
            trip.otp_verified_at = now
            trip.completed_at = now
            trip.completed_device = request.META.get('HTTP_USER_AGENT', '')[:200]
            trip.otp_hash = ''
            trip.otp_expires_at = None
            trip.save(update_fields=[
                'status', 'otp_verified_at', 'completed_at', 'completed_device',
                'otp_hash', 'otp_expires_at',
            ])

            order = Order.objects.select_for_update().get(pk=trip.order_id)
            from apps.orders.services.order_service import consume_order_inventory
            consume_order_inventory(order)
            OrderStateMachine.transition(order, 'delivered', user=request.user)

            if trip.provider_id:
                provider = trip.provider
                provider.total_deliveries += 1
                provider.save(update_fields=['total_deliveries'])

            def dispatch_order_payouts():
                try:
                    from apps.payouts.tasks import release_payment_task

                    release_payment_task.delay(order.id)
                    if trip.provider_id:
                        from apps.logistics.tasks import update_provider_reliability_metrics

                        update_provider_reliability_metrics.delay(trip.provider_id)
                except Exception:
                    import logging

                    logging.getLogger(__name__).exception('Could not enqueue payouts for delivered order %s', order.id)

            transaction.on_commit(dispatch_order_payouts)

        return Response({'message': 'Delivery confirmed.', 'status': trip.status}, status=status.HTTP_200_OK)


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


class BuyerOrderTripDetailView(generics.RetrieveAPIView):
    """Resolve a buyer's trip from the order UUID used by order tracking."""
    permission_classes = [permissions.IsAuthenticated, IsBuyer]
    serializer_class = TripSerializer
    lookup_field = 'order__uuid'
    lookup_url_kwarg = 'order_uuid'

    def get_queryset(self):
        return Trip.objects.filter(order__buyer=self.request.user).select_related('order', 'provider__user')


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