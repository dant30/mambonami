# PayBill callback view (POST /mpesa/callback)
# backend/django_admin/apps/paybill/views/api.py
import logging
from django.conf import settings
from django.http import HttpResponse
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAdminUser
from rest_framework import status
from drf_yasg.utils import swagger_auto_schema

from apps.paybill.permissions import CanViewPayBillTransactions
from apps.paybill.services.ipn_handler import IPNHandler
from apps.paybill.services.reconciliation import get_estimated_float_balance
from apps.paybill.serializers import (
    IPNCallbackSerializer,
    PayBillSimulationSerializer,
    PayBillTransactionSerializer,
)
from apps.paybill.serializers.settlement_serializer import SettlementSerializer
from apps.paybill.models import PayBillTransaction, PayBillSettlement
from apps.orders.models import Order
from apps.orders.permissions import IsBuyer
from apps.paybill.services.stk_push import StkPushError, initiate_order_stk_push, process_stk_callback
from django.shortcuts import get_object_or_404

logger = logging.getLogger(__name__)


class StkPushInitiationView(APIView):
    permission_classes = [IsBuyer]

    def post(self, request):
        order_uuid = request.data.get('order_uuid')
        phone_number = request.data.get('phone_number') or getattr(request.user, 'phone', '')
        if not order_uuid:
            return Response({'detail': 'order_uuid is required.'}, status=status.HTTP_400_BAD_REQUEST)
        order = get_object_or_404(Order, uuid=order_uuid, buyer=request.user)
        try:
            push_request = initiate_order_stk_push(order, phone_number)
        except StkPushError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_400_BAD_REQUEST)
        return Response({
            'status': push_request.status,
            'message': push_request.result_description,
            'checkout_request_id': push_request.checkout_request_id,
            'account_number': order.account_number,
            'amount': str(push_request.amount),
        }, status=status.HTTP_200_OK)


class StkPushCallbackView(APIView):
    permission_classes = [AllowAny]
    authentication_classes = []

    def post(self, request):
        result = process_stk_callback(request.data)
        logger.info(
            'STK callback handled: success=%s order_id=%s message=%s',
            result.get('success'),
            result.get('order_id'),
            result.get('message', 'Processed'),
        )
        # Safaricom expects an HTTP 200 acknowledgment once the callback is received.
        # Payment success is tracked separately on the order and STK request.
        return Response({'ResultCode': 0, 'ResultDesc': 'Callback received'})

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

@method_decorator(csrf_exempt, name='dispatch')
class C2BValidationCallbackView(APIView):
    """Handle M-Pesa C2B validation requests from Safaricom."""
    permission_classes = [AllowAny]
    authentication_classes = []

    def post(self, request):
        response_xml = (
            '<?xml version="1.0" encoding="UTF-8"?>'
            '<Response>'
            '<ResultCode>0</ResultCode>'
            '<ResultDesc>Accepted</ResultDesc>'
            '</Response>'
        )
        return HttpResponse(response_xml, content_type='application/xml')


@method_decorator(csrf_exempt, name='dispatch')
class C2BConfirmationCallbackView(APIView):
    """Handle M-Pesa C2B confirmation requests from Safaricom."""
    permission_classes = [AllowAny]
    authentication_classes = []

    def post(self, request):
        response_xml = (
            '<?xml version="1.0" encoding="UTF-8"?>'
            '<Response>'
            '<ResultCode>0</ResultCode>'
            '<ResultDesc>Accepted</ResultDesc>'
            '</Response>'
        )
        return HttpResponse(response_xml, content_type='application/xml')


class PayBillSimulationView(APIView):
    """Local development endpoint to simulate a PayBill callback without hitting Safaricom."""
    permission_classes = [AllowAny]
    authentication_classes = []

    def post(self, request):
        serializer = PayBillSimulationSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({'success': False, 'message': 'Invalid simulation payload'}, status=status.HTTP_400_BAD_REQUEST)

        payload = {
            'TransactionCode': serializer.validated_data['TransactionCode'],
            'Amount': str(serializer.validated_data['Amount']),
            'AccountNumber': serializer.validated_data['AccountNumber'],
            'PhoneNumber': serializer.validated_data['PhoneNumber'],
            'Time': serializer.validated_data['Time'],
            'BillRefNumber': serializer.validated_data.get('BillRefNumber', ''),
            'FirstName': serializer.validated_data.get('FirstName', ''),
            'MiddleName': serializer.validated_data.get('MiddleName', ''),
            'LastName': serializer.validated_data.get('LastName', ''),
            'BusinessShortCode': serializer.validated_data.get('BusinessShortCode', ''),
            'TransactionType': serializer.validated_data.get('TransactionType', ''),
        }
        result = IPNHandler.process_callback(payload)
        return Response(
            {
                'success': result['success'],
                'message': result['message'],
                'order_id': result.get('order_id'),
            },
            status=status.HTTP_200_OK,
        )


class PayBillTransactionListView(APIView):
    """
    Admin-only: list all PayBill transactions.
    """
    permission_classes = [CanViewPayBillTransactions]

    def get(self, request):
        transactions = PayBillTransaction.objects.all().order_by('-created_at')
        serializer = PayBillTransactionSerializer(transactions, many=True)
        return Response(serializer.data)


class PayBillSettlementListView(APIView):
    """
    Admin-only: list all PayBill settlements.
    """
    permission_classes = [CanViewPayBillTransactions]

    def get(self, request):
        settlements = PayBillSettlement.objects.all().order_by('-settlement_date')
        serializer = SettlementSerializer(settlements, many=True)
        return Response(serializer.data)


class FloatBalanceView(APIView):
    """
    Admin-only: return the current estimated PayBill float balance.
    """
    permission_classes = [CanViewPayBillTransactions]

    def get(self, request):
        balance = get_estimated_float_balance()
        return Response({'float_balance': str(balance)})