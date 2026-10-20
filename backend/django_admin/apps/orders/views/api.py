# backend/django_admin/apps/orders/views/api.py
import logging
from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import transaction
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from apps.orders.models import Order, SubOrder
from apps.orders.serializers import OrderSerializer, OrderCreateSerializer, SubOrderSerializer
from apps.orders.services.order_service import create_order_from_cart
from apps.orders.services.state_machine import OrderStateMachine
from apps.users.permissions import is_admin_user
from apps.orders.permissions import IsBuyer, IsFarmerForSubOrder, IsTransportProviderForOrder


def _get_farmer_profile_or_none(user):
    if not getattr(user, 'is_authenticated', False):
        return None
    if getattr(user, 'role', None) != 'farmer':
        return None
    return getattr(user, 'farmer_profile', None)


class CartCreateOrderView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsBuyer]

    def post(self, request):
        serializer = OrderCreateSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        try:
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
                'paybill_number': settings.MPESA_PAYBILL_NUMBER,
                'instructions': f"Pay KES {order.total_amount} to PayBill {settings.MPESA_PAYBILL_NUMBER}, Account {order.account_number}"
            }, status=status.HTTP_201_CREATED)
        except ValidationError as exc:
            return Response({'detail': exc.messages}, status=status.HTTP_409_CONFLICT)
        except Exception:
            logging.getLogger(__name__).exception('Order create failed')
            return Response({'detail': 'Unable to create this order right now.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class OrderDetailView(generics.RetrieveAPIView):
    queryset = Order.objects.all()
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'uuid'

    def get_queryset(self):
        user = self.request.user
        if is_admin_user(user):
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


class ConfirmSelfPickupView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsBuyer]

    def post(self, request, uuid):
        order = get_object_or_404(
            Order.objects.filter(buyer=request.user),
            uuid=uuid,
        )
        if order.fulfillment_type != 'self_pickup':
            return Response({'detail': 'This order is not a self-pickup order.'}, status=status.HTTP_409_CONFLICT)
        try:
            completed_order = OrderStateMachine.transition(
                order,
                'delivered',
                actor=request.user,
            )
        except ValidationError as exc:
            return Response({'detail': exc.messages}, status=status.HTTP_409_CONFLICT)
        return Response(OrderSerializer(completed_order, context={'request': request}).data)

class OrderListView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if is_admin_user(user):
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
        suborder = get_object_or_404(SubOrder.objects.select_related('order', 'farmer__user'), id=suborder_id)
        self.check_object_permissions(request, suborder)
        action = request.data.get('action')
        if action == 'confirm':
            try:
                suborder.confirm()
            except ValidationError as exc:
                return Response({'error': exc.messages[0]}, status=status.HTTP_409_CONFLICT)
            return Response({'status': 'confirmed'})
        elif action == 'reject':
            if suborder.order.status != 'placed':
                return Response({'error': 'A paid order cannot be rejected without initiating a refund.'}, status=status.HTTP_409_CONFLICT)
            if suborder.order.stk_push_requests.filter(status__in=['initiating', 'pending']).exists():
                return Response({'error': 'An M-Pesa payment prompt is pending. Wait for its result before rejecting this order.'}, status=status.HTTP_409_CONFLICT)
            if suborder.status != 'pending':
                return Response({'error': 'Only a pending order can be rejected.'}, status=status.HTTP_409_CONFLICT)
            with transaction.atomic():
                order = Order.objects.select_for_update().get(pk=suborder.order_id)
                suborder = SubOrder.objects.select_for_update().get(pk=suborder.pk)
                if suborder.status != 'pending' or order.status != 'placed':
                    return Response({'error': 'The order changed while it was being rejected.'}, status=status.HTTP_409_CONFLICT)
                suborder.status = 'cancelled'
                suborder.save(update_fields=['status', 'updated_at'])
                order.status = 'cancelled'
                order.save(update_fields=['status', 'updated_at'])
                order.sub_orders.exclude(pk=suborder.pk).update(status='cancelled')
                from apps.orders.services.order_service import release_order_inventory
                release_order_inventory(order)
            return Response({'status': 'cancelled'})
        return Response({'error': 'Invalid action'}, status=400)

class FarmerReadyView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsFarmerForSubOrder]

    def post(self, request, suborder_id):
        suborder = get_object_or_404(SubOrder.objects.select_related('order', 'farmer__user'), id=suborder_id)
        self.check_object_permissions(request, suborder)
        try:
            with transaction.atomic():
                locked = SubOrder.objects.select_for_update().select_related('order').get(pk=suborder.pk)
                locked.mark_ready()
                suborder = locked
        except ValidationError as exc:
            return Response({'error': exc.messages[0]}, status=status.HTTP_409_CONFLICT)
        if suborder.order.are_all_farmers_ready() and suborder.order.fulfillment_type == 'delivery':
            def enqueue_transport_match():
                try:
                    from apps.orders.tasks import match_transport_for_order
                    match_transport_for_order.delay(suborder.order_id)
                except Exception:
                    logging.getLogger(__name__).exception('Unable to enqueue transport matching for order %s', suborder.order_id)
            transaction.on_commit(enqueue_transport_match)
        return Response({'status': 'ready'})
