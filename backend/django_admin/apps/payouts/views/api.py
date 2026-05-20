# backend/django_admin/apps/payouts/views/api.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from ..models import Payout
from ..serializers import PayoutSerializer
from ..services.payout_service import handle_b2c_callback
from apps.users.permissions import IsAdmin

class PayoutListView(generics.ListAPIView):
    """Admin-only: view all payouts."""
    permission_classes = [IsAdmin]
    serializer_class = PayoutSerializer
    queryset = Payout.objects.all().order_by('-created_at')

class PayoutDetailView(generics.RetrieveAPIView):
    """Admin-only: view single payout."""
    permission_classes = [IsAdmin]
    serializer_class = PayoutSerializer
    queryset = Payout.objects.all()
    lookup_field = 'uuid'

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