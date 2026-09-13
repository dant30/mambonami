# backend/django_admin/apps/orders/views/api.py
import logging
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


def _get_farmer_profile_or_none(user):
    if not getattr(user, 'is_authenticated', False):
        return None
    if getattr(user, 'role', None) != 'farmer':
        return None
    return getattr(user, 'farmer_profile', None)


class CartCreateOrderView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsBuyer]

    def post(self, request):
        logger = logging.getLogger(__name__)
        serializer = OrderCreateSerializer(data=request.data)
        try:
            serializer.is_valid(raise_exception=True)
            order = create_order_from_cart(request.user, serializer.validated_data)
            return Response({
                'id': order.id,
                'uuid': order.uuid,
                'order_uuid': order.uuid,
                'account_number': order.account_number,
                'subtotal': float(order.total_amount - order.delivery_fee),
                'delivery_fee': float(order.delivery_fee),
                'platform_commission': float(order.platform_commission),
                'total_amount': order.total_amount,
                'discount_amount': float(order.discount_amount),
                'paybill_number': '123456',
                'instructions': f"Pay KES {order.total_amount} to PayBill 123456, Account {order.account_number}"
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            logger.exception("Order create failed")
            return Response({"error": "internal", "detail": str(e)}, status=500)

class OrderDetailView(generics.RetrieveAPIView):
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
        if user.role == 'retailer':
            return Order.objects.filter(buyer=user)
        if user.role == 'farmer':
            farmer_profile = _get_farmer_profile_or_none(user)
            if not farmer_profile:
                return Order.objects.none()
            return Order.objects.filter(sub_orders__farmer=farmer_profile)
        if user.role == 'transport_provider':
            return Order.objects.filter(assigned_provider=user.transport_profile)
        return Order.objects.none()

class OrderListView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return Order.objects.all()
        if user.role == 'buyer':
            return Order.objects.filter(buyer=user)
        if user.role == 'retailer':
            return Order.objects.filter(buyer=user)
        if user.role == 'farmer':
            farmer_profile = _get_farmer_profile_or_none(user)
            if not farmer_profile:
                return Order.objects.none()
            return Order.objects.filter(sub_orders__farmer=farmer_profile).distinct()
        if user.role == 'transport_provider':
            return Order.objects.filter(assigned_provider=user.transport_profile)
        return Order.objects.none()

# NEW: Active Order Endpoint
class ActiveOrderView(generics.RetrieveAPIView):
    """Returns buyer's current active order (for BuyerDashboard strip)."""
    permission_classes = [permissions.IsAuthenticated, IsBuyer]
    serializer_class = OrderSerializer

    def get_object(self):
        return Order.objects.filter(
            buyer=self.request.user,
            status__in=['paid_escrow', 'transport_assigned', 'picked_up']
        ).order_by('-created_at').first()

class FarmerSubOrdersView(generics.ListAPIView):
    serializer_class = SubOrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role != 'farmer':
            return SubOrder.objects.none()
        farmer_profile = _get_farmer_profile_or_none(user)
        if not farmer_profile:
            return SubOrder.objects.none()
        return SubOrder.objects.filter(farmer=farmer_profile)

class FarmerSubOrderDetailView(generics.RetrieveAPIView):
    queryset = SubOrder.objects.all()
    serializer_class = SubOrderSerializer
    permission_classes = [permissions.IsAuthenticated, IsFarmerForSubOrder]
    lookup_field = 'id'
    lookup_url_kwarg = 'suborder_id'

class FarmerConfirmSubOrderView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsFarmerForSubOrder]

    def post(self, request, suborder_id):
        suborder = get_object_or_404(SubOrder, id=suborder_id)
        action = request.data.get('action')
        if action == 'confirm':
            suborder.confirm()
            if suborder.order.is_fully_confirmed():
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
    permission_classes = [permissions.IsAuthenticated, IsFarmerForSubOrder]

    def post(self, request, suborder_id):
        suborder = get_object_or_404(SubOrder, id=suborder_id)
        suborder.mark_ready()
        if suborder.order.are_all_farmers_ready():
            from apps.orders.tasks import match_transport_for_order
            match_transport_for_order.delay(suborder.order.id)
        return Response({'status': 'ready'})

class GenerateDeliveryOTPView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsTransportProviderForOrder]

    def post(self, request, order_uuid):
        order = get_object_or_404(Order, uuid=order_uuid)
        if order.assigned_provider.user != request.user:
            return Response({'error': 'Not your assigned order'}, status=403)
        if order.status != 'picked_up':
            return Response({'error': 'Order not ready for delivery'}, status=400)
        otp = generate_otp()
        cache_otp(f"delivery_otp_{order.id}", otp, timeout=300)
        from apps.notifications.services.sms import send_otp_message
        send_otp_message(order.buyer.phone, otp)
        return Response({'message': 'OTP sent to buyer'})

class VerifyDeliveryOTPView(APIView):
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
        OrderStateMachine.transition(order, 'delivered')
        from apps.payouts.tasks import process_payouts_for_order
        process_payouts_for_order.delay(order.id)
        return Response({'status': 'delivered'})