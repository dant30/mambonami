# django_admin/apps/orders/views/api.py
# backend/django_admin/apps/orders/views/api.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from apps.orders.models import Order, SubOrder
from apps.orders.serializers import OrderSerializer, OrderCreateSerializer, SubOrderSerializer
from apps.orders.services.order_service import create_order_from_cart
from apps.orders.services.state_machine import OrderStateMachine
from apps.orders.permissions import IsBuyer, IsFarmerForSubOrder, IsTransportProviderForOrder
from core.cache import cache_otp, get_otp
from core.utils import generate_otp

class CartCreateOrderView(APIView):
    """Create order from cart (step after PayBill payment)."""
    permission_classes = [permissions.IsAuthenticated, IsBuyer]

    def post(self, request):
        serializer = OrderCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        order = create_order_from_cart(request.user, serializer.validated_data)
        # Return PayBill instructions
        return Response({
            'order_uuid': order.uuid,
            'account_number': order.account_number,
            'total_amount': order.total_amount,
            'paybill_number': '123456',  # from settings
            'instructions': f"Pay KES {order.total_amount} to PayBill 123456, Account {order.account_number}"
        }, status=status.HTTP_201_CREATED)

class OrderDetailView(generics.RetrieveAPIView):
    """View order details (buyer, farmer, or provider)."""
    queryset = Order.objects.all()
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'uuid'

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return Order.objects.all()
        if user.role == 'buyer':
            return Order.objects.filter(buyer=user)
        if user.role == 'farmer':
            return Order.objects.filter(sub_orders__farmer=user.farmer_profile)
        if user.role == 'transport_provider':
            return Order.objects.filter(assigned_provider=user.transport_profile)
        return Order.objects.none()

class OrderListView(generics.ListAPIView):
    """List orders for the authenticated user."""
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return Order.objects.all()
        if user.role == 'buyer':
            return Order.objects.filter(buyer=user)
        if user.role == 'farmer':
            return Order.objects.filter(sub_orders__farmer=user.farmer_profile).distinct()
        if user.role == 'transport_provider':
            return Order.objects.filter(assigned_provider=user.transport_profile)
        return Order.objects.none()

class FarmerSubOrdersView(generics.ListAPIView):
    """List suborders for the authenticated farmer."""
    serializer_class = SubOrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role != 'farmer':
            return SubOrder.objects.none()
        return SubOrder.objects.filter(farmer=user.farmer_profile)

class FarmerSubOrderDetailView(generics.RetrieveAPIView):
    """Retrieve a single suborder for the authenticated farmer."""
    queryset = SubOrder.objects.all()
    serializer_class = SubOrderSerializer
    permission_classes = [permissions.IsAuthenticated, IsFarmerForSubOrder]
    lookup_field = 'id'
    lookup_url_kwarg = 'suborder_id'

class FarmerConfirmSubOrderView(APIView):
    """Farmer confirms or rejects a sub‑order."""
    permission_classes = [permissions.IsAuthenticated, IsFarmerForSubOrder]

    def post(self, request, suborder_id):
        suborder = get_object_or_404(SubOrder, id=suborder_id)
        action = request.data.get('action')
        if action == 'confirm':
            suborder.confirm()
            # Check if main order can now assign transport
            if suborder.order.is_fully_confirmed():
                # Trigger transport matching (async task)
                from apps.orders.tasks import match_transport_for_order
                match_transport_for_order.delay(suborder.order.id)
            return Response({'status': 'confirmed'})
        elif action == 'reject':
            suborder.status = 'cancelled'
            suborder.save()
            suborder.order.status = 'cancelled'
            suborder.order.save()
            return Response({'status': 'cancelled'})
        return Response({'error': 'Invalid action'}, status=400)

class FarmerReadyView(APIView):
    """Farmer marks sub‑order ready for pickup."""
    permission_classes = [permissions.IsAuthenticated, IsFarmerForSubOrder]

    def post(self, request, suborder_id):
        suborder = get_object_or_404(SubOrder, id=suborder_id)
        suborder.mark_ready()
        # If all farmers ready, notify transport providers
        if suborder.order.are_all_farmers_ready():
            from apps.orders.tasks import match_transport_for_order
            match_transport_for_order.delay(suborder.order.id)
        return Response({'status': 'ready'})

class GenerateDeliveryOTPView(APIView):
    """Transport provider generates OTP for buyer."""
    permission_classes = [permissions.IsAuthenticated, IsTransportProviderForOrder]

    def post(self, request, order_uuid):
        order = get_object_or_404(Order, uuid=order_uuid)
        if order.assigned_provider.user != request.user:
            return Response({'error': 'Not your assigned order'}, status=403)
        if order.status != 'picked_up':
            return Response({'error': 'Order not ready for delivery'}, status=400)
        otp = generate_otp()
        cache_otp(f"delivery_otp_{order.id}", otp, timeout=300)
        # Send OTP to buyer via SMS
        from apps.notifications.services.sms import send_otp_message
        send_otp_message(order.buyer.phone, otp)
        return Response({'message': 'OTP sent to buyer'})

class VerifyDeliveryOTPView(APIView):
    """Buyer verifies OTP and uploads photo."""
    permission_classes = [permissions.IsAuthenticated, IsBuyer]

    def post(self, request, order_uuid):
        order = get_object_or_404(Order, uuid=order_uuid, buyer=request.user)
        otp = request.data.get('otp')
        photo = request.FILES.get('photo')
        if not otp or not photo:
            return Response({'error': 'OTP and photo required'}, status=400)
        cached_otp = get_otp(f"delivery_otp_{order.id}")
        if cached_otp != otp:
            return Response({'error': 'Invalid or expired OTP'}, status=400)
        # Mark order delivered
        OrderStateMachine.transition(order, 'delivered')
        # Trigger payouts
        from apps.payouts.tasks import process_payouts_for_order
        process_payouts_for_order.delay(order.id)
        # Save photo (use storage service)
        return Response({'status': 'delivered'})