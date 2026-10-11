# backend/django_admin/apps/payouts/views/api.py
from decimal import Decimal
from django.db.models import Sum, Q
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.users.permissions import IsAdmin, is_admin_user
from ..models import Payout
from ..permissions import CanViewPayouts
from ..serializers import PayoutSerializer
from ..services.payout_service import handle_b2c_callback

class PayoutListView(generics.ListAPIView):
    """Admins see all payouts; farmers and providers see their own payouts."""
    permission_classes = [CanViewPayouts]
    serializer_class = PayoutSerializer

    def get_queryset(self):
        user = self.request.user
        if is_admin_user(user):
            return Payout.objects.all().order_by('-created_at')

        recipient_type = 'farmer' if user.role == 'farmer' else 'transport_provider' if user.role == 'transport_provider' else None
        if recipient_type is None:
            return Payout.objects.none()
        return Payout.objects.filter(
            recipient_user=user,
            recipient_type=recipient_type,
        ).order_by('-created_at')

class PayoutDetailView(generics.RetrieveAPIView):
    """Admin-only: view single payout."""
    permission_classes = [IsAdmin]
    serializer_class = PayoutSerializer
    queryset = Payout.objects.all()
    lookup_field = 'uuid'


class TransportPayoutSummaryView(APIView):
    """Return authenticated provider payout totals for the dashboard analytics strip."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        recipient_type = 'farmer' if request.user.role == 'farmer' else 'transport_provider' if request.user.role == 'transport_provider' else None
        if recipient_type is None:
            return Response({'detail': 'Only farmers and transport providers can view payout summaries.'}, status=status.HTTP_403_FORBIDDEN)

        payouts = Payout.objects.filter(recipient_user=request.user, recipient_type=recipient_type)

        total = payouts.aggregate(total=Sum('amount'))['total'] or Decimal('0')
        completed = payouts.filter(status='completed')
        pending = payouts.filter(~Q(status='completed'))

        completed_total = completed.aggregate(total=Sum('amount'))['total'] or Decimal('0')
        pending_total = pending.aggregate(total=Sum('amount'))['total'] or Decimal('0')
        today_start = timezone.localdate()
        today_total = payouts.filter(
            created_at__date=today_start,
        ).aggregate(total=Sum('amount'))['total'] or Decimal('0')

        latest_paid_at = payouts.filter(status='completed', paid_at__isnull=False).order_by('-paid_at').first()

        return Response({
            'total_payout_amount': float(total),
            'completed_payout_amount': float(completed_total),
            'pending_payout_amount': float(pending_total),
            'today_payout_amount': float(today_total),
            'completed_payout_count': completed.count(),
            'pending_payout_count': pending.count(),
            'latest_paid_at': latest_paid_at.paid_at.isoformat() if latest_paid_at else None,
        }, status=status.HTTP_200_OK)

@method_decorator(csrf_exempt, name='dispatch')
class B2CResultCallbackView(APIView):
    """
    Safaricom B2C result callback endpoint.
    No authentication – called by Safaricom.
    """
    permission_classes = []
    authentication_classes = []

    def post(self, request):
        handle_b2c_callback(request.data)
        return Response({"ResultCode": 0, "ResultDesc": "Success"}, status=status.HTTP_200_OK)

@method_decorator(csrf_exempt, name='dispatch')
class B2CTimeoutCallbackView(APIView):
    """Handle timeout callbacks (mark as failed and retry)."""
    permission_classes = []
    authentication_classes = []

    def post(self, request):
        # Similar to result callback but assume failure
        conversation_id = request.data.get('Result', {}).get('ConversationID')
        if conversation_id:
            try:
                payout = Payout.objects.get(b2c_transaction_id=conversation_id)
                payout.status = 'failed'
                payout.error_message = "B2C timeout"
                payout.save(update_fields=['status', 'error_message'])
                # Retry logic...
            except Payout.DoesNotExist:
                pass
        return Response({"ResultCode": 0}, status=status.HTTP_200_OK)