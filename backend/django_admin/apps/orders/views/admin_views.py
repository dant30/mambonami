from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404

from apps.orders.models import Order
from apps.orders.serializers import OrderSerializer
from apps.orders.services.state_machine import OrderStateMachine
from apps.users.permissions import IsAdmin


class AdminOrderListView(generics.ListAPIView):
    queryset = Order.objects.select_related('buyer', 'assigned_provider').prefetch_related('sub_orders__items__product')
    serializer_class = OrderSerializer
    permission_classes = [IsAdmin]


class AdminOrderDetailView(generics.RetrieveAPIView):
    queryset = Order.objects.select_related('buyer', 'assigned_provider').prefetch_related('sub_orders__items__product')
    serializer_class = OrderSerializer
    permission_classes = [IsAdmin]
    lookup_field = 'uuid'


class AdminOrderStatusView(APIView):
    permission_classes = [IsAdmin]

    def post(self, request, uuid):
        order = get_object_or_404(Order, uuid=uuid)
        new_status = request.data.get('status')
        if not isinstance(new_status, str):
            return Response({'status': 'status is required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            OrderStateMachine.transition(order, new_status, user=request.user)
        except Exception as exc:
            return Response({'status': str(exc)}, status=status.HTTP_400_BAD_REQUEST)

        return Response(OrderSerializer(order).data, status=status.HTTP_200_OK)