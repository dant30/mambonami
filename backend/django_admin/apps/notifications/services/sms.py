# backend/django_admin/apps/notifications/services/sms.py
import logging
import requests
from typing import Iterable, Dict, Any
from django.conf import settings
from django.utils import timezone

logger = logging.getLogger(__name__)


def _format_phone_number(phone_number: str) -> str:
    cleaned = phone_number.strip().replace(' ', '').replace('-', '')
    if cleaned.startswith('+'):
        return cleaned
    if cleaned.startswith('0'):
        return f'+254{cleaned.lstrip("0")}'
    if cleaned.startswith('254'):
        return f'+{cleaned}'
    return f'+254{cleaned}'


class OTSSMS:
    """OTS (Olympus Telecom Solutions) SMS Gateway."""

    def __init__(self):
        self.api_url = getattr(settings, 'OTS_API_URL', 'https://sms.ots.co.ke/api/v3/')
        self.api_token = getattr(settings, 'OTS_API_TOKEN', '')
        self.sender_id = getattr(settings, 'OTS_SENDER_ID', 'MAMBONAMI')
        self.sandbox = getattr(settings, 'OTS_SANDBOX', True)

    def _get_headers(self) -> Dict[str, str]:
        return {
            'Authorization': f'Bearer {self.api_token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        }

    def send(self, notification) -> bool:
        result = self.send_sms(notification.user.phone, notification.body)
        if result.get('status') == 'success':
            notification.external_id = result.get('message_id', '')
            notification.status = 'sent'
            notification.delivered_at = timezone.now()
            notification.save(update_fields=['external_id', 'status', 'delivered_at'])
            return True

        notification.status = 'failed'
        notification.error_message = result.get('error', '')
        notification.save(update_fields=['status', 'error_message'])
        return False

    def send_sms(self, phone_number: str, message: str) -> Dict[str, Any]:
        if not self.api_token:
            logger.warning('SMS not sent - OTS API token not configured')
            return {'status': 'failed', 'message': 'OTS API token not configured'}

        formatted_number = _format_phone_number(phone_number)
        endpoint = f"{self.api_url.rstrip('/')}/sms/send"
        payload = {
            'to': formatted_number,
            'from': self.sender_id,
            'message': message,
            'type': 'plain',
        }

        try:
            response = requests.post(
                endpoint,
                json=payload,
                headers=self._get_headers(),
                timeout=30,
            )
            response.raise_for_status()
            result = response.json()
            logger.info('SMS sent to %s: %s', formatted_number, result)
            return {
                'status': 'success',
                'response': result,
                'message_id': result.get('message_id') or result.get('id'),
            }

        except requests.exceptions.Timeout:
            logger.error('SMS timeout for %s', phone_number)
            return {'status': 'failed', 'error': 'Request timeout'}

        except requests.exceptions.RequestException as exc:
            logger.error('SMS failed for %s: %s', phone_number, exc)
            error_msg = str(exc)
            if hasattr(exc, 'response') and exc.response is not None:
                try:
                    error_data = exc.response.json()
                    error_msg = error_data.get('message') or error_data.get('error') or error_msg
                except ValueError:
                    pass
            return {'status': 'failed', 'error': error_msg}

    def send_bulk_sms(self, phone_numbers: Iterable[str], message: str) -> Dict[str, Any]:
        if not self.api_token:
            return {'status': 'failed', 'message': 'OTS API token not configured'}

        formatted_numbers = [_format_phone_number(phone) for phone in phone_numbers]
        endpoint = f"{self.api_url.rstrip('/')}/sms/send"
        payload = {
            'to': formatted_numbers,
            'from': self.sender_id,
            'message': message,
            'type': 'plain',
        }

        try:
            response = requests.post(
                endpoint,
                json=payload,
                headers=self._get_headers(),
                timeout=60,
            )
            response.raise_for_status()
            result = response.json()
            logger.info('Bulk SMS sent to %d recipients', len(formatted_numbers))
            return {'status': 'success', 'response': result}
        except requests.exceptions.RequestException as exc:
            logger.error('Bulk SMS failed: %s', exc)
            return {'status': 'failed', 'error': str(exc)}


AfricaTalkingSMS = OTSSMS


def send_otp_message(phone: str, otp: str) -> dict:
    message = f'Your MAMBONAMI verification code is {otp}. It expires in 5 minutes.'
    sms_service = AfricaTalkingSMS()
    result = sms_service.send_sms(phone, message)

    if result.get('status') != 'success':
        logger.warning('OTP SMS failed for %s: %s', phone, result.get('error') or result.get('message'))

    return result