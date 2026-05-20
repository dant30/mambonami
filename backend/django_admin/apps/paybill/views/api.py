# PayBill callback view (POST /mpesa/callback)
# backend/django_admin/apps/paybill/views/api.py
import logging
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework import status
from drf_yasg.utils import swagger_auto_schema

from apps.paybill.permissions import CanViewPayBillTransactions
from apps.paybill.services.ipn_handler import IPNHandler
from apps.paybill.serializers import IPNCallbackSerializer, PayBillTransactionSerializer
from apps.paybill.models import PayBillTransaction

logger = logging.getLogger(__name__)

class IPNCallbackView(APIView):
    """
    M-Pesa PayBill Instant Payment Notification endpoint.
    No authentication – called directly by Safaricom.
    """
    permission_classes = [AllowAny]
    authentication_classes = []  # no auth for IPN

    @swagger_auto_schema(request_body=IPNCallbackSerializer)
    def post(self, request):
        allowed_ips = getattr(settings, 'IPN_ALLOWED_IPS', [])
        client_ip = self._get_client_ip(request)
        if allowed_ips and client_ip not in allowed_ips:
            logger.warning(f"IPN from unauthorized IP: {client_ip}")
            return Response({'ResultCode': 1, 'ResultDesc': 'Forbidden'}, status=status.HTTP_403_FORBIDDEN)

        serializer = IPNCallbackSerializer(data=request.data)
        if not serializer.is_valid():
            logger.warning(f"Invalid IPN payload: {serializer.errors}")
            return Response({'ResultCode': 1, 'ResultDesc': 'Invalid data'}, status=status.HTTP_400_BAD_REQUEST)

        result = IPNHandler.process_callback(serializer.validated_data)
        if result['success']:
            return Response({'ResultCode': 0, 'ResultDesc': 'Success'}, status=status.HTTP_200_OK)
        else:
            return Response({'ResultCode': 1, 'ResultDesc': result['message']}, status=status.HTTP_200_OK)

    @staticmethod
    def _get_client_ip(request):
        forwarded = request.META.get('HTTP_X_FORWARDED_FOR')
        if forwarded:
            return forwarded.split(',')[0].strip()
        return request.META.get('REMOTE_ADDR')

class PayBillTransactionListView(APIView):
    """
    Admin-only: list all PayBill transactions.
    """
    permission_classes = [CanViewPayBillTransactions]

    def get(self, request):
        transactions = PayBillTransaction.objects.all().order_by('-created_at')
        serializer = PayBillTransactionSerializer(transactions, many=True)
        return Response(serializer.data)