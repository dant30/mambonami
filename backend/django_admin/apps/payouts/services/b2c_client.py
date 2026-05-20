# backend/django_admin/apps/payouts/services/b2c_client.py
import requests
import base64
from datetime import datetime
from django.conf import settings
from core.cache import RedisCache
import logging

logger = logging.getLogger(__name__)

class SafaricomB2CClient:
    """Handles authentication and B2C payments via Safaricom API."""

    def __init__(self):
        self.consumer_key = settings.MPESA_CONSUMER_KEY
        self.consumer_secret = settings.MPESA_CONSUMER_SECRET
        self.initiator_name = settings.MPESA_B2C_INITIATOR_NAME
        self.security_credential = settings.MPESA_B2C_SECURITY_CREDENTIAL
        self.paybill = settings.MPESA_PAYBILL_NUMBER
        self.api_url = settings.MPESA_ENVIRONMENT_URL  # 'https://sandbox.safaricom.co.ke' or production
        self.b2c_endpoint = '/mpesa/b2c/v1/paymentrequest'

    def _get_access_token(self):
        """Get OAuth token (cached in Redis)."""
        cache_key = 'mpesa_access_token'
        token = RedisCache.get(cache_key)
        if token:
            return token

        auth = base64.b64encode(f"{self.consumer_key}:{self.consumer_secret}".encode()).decode()
        headers = {'Authorization': f'Basic {auth}'}
        response = requests.get(f"{self.api_url}/oauth/v1/generate?grant_type=client_credentials", headers=headers)
        if response.status_code == 200:
            token = response.json().get('access_token')
            RedisCache.set(cache_key, token, timeout=3500)  # 1 hour minus 100 sec
            return token
        logger.error(f"Failed to get access token: {response.text}")
        raise Exception("B2C authentication failed")

    def send_b2c_payment(self, phone_number: str, amount: float, order_id: int, recipient_type: str):
        """
        Send B2C payment to a customer.
        Returns {'ConversationID': ..., 'OriginatorConversationID': ...}
        """
        access_token = self._get_access_token()
        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json'
        }
        if recipient_type == 'farmer':
            command_id = "BusinessPayment"
        else:
            # Transport providers and buyer refunds are sent as customers.
            command_id = "BusinessToCustomer"

        payload = {
            "InitiatorName": self.initiator_name,
            "SecurityCredential": self.security_credential,
            "CommandID": command_id,
            "Amount": str(amount),
            "PartyA": self.paybill,
            "PartyB": phone_number,
            "Remarks": f"Order {order_id} payout",
            "QueueTimeOutURL": f"{settings.CALLBACK_BASE_URL}/api/payouts/b2c/timeout",
            "ResultURL": f"{settings.CALLBACK_BASE_URL}/api/payouts/b2c/result",
            "Occasion": f"Order-{order_id}"
        }
        response = requests.post(f"{self.api_url}{self.b2c_endpoint}", json=payload, headers=headers)
        if response.status_code == 200:
            result = response.json()
            logger.info(f"B2C initiated: {result.get('ConversationID')}")
            return result
        else:
            logger.error(f"B2C failed: {response.text}")
            raise Exception(f"B2C request failed: {response.status_code}")