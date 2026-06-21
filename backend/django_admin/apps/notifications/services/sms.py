# backend/django_admin/apps/notifications/services/sms.py
import logging
import importlib
from typing import Iterable
from django.conf import settings

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


class AfricaTalkingSMS:
    def __init__(self):
        self.sender = getattr(settings, 'AFRICASTALKING_SENDER_ID', 'MAMBONAMI')
        self.sandbox = getattr(settings, 'AFRICASTALKING_SANDBOX', True)
        self.sms = None

        username = getattr(settings, 'AFRICASTALKING_USERNAME', '')
        api_key = getattr(settings, 'AFRICASTALKING_API_KEY', '')

        if username and api_key:
            try:
                africastalking = importlib.import_module('africastalking')
                africastalking.initialize(username, api_key)
                self.sms = africastalking.SMS
            except Exception as exc:
                logger.exception('Failed to initialize Africa\'s Talking SMS: %s', exc)
        else:
            logger.warning("Africa's Talking credentials not configured")

    def send_sms(self, phone_number: str, message: str) -> dict:
        """Send a single SMS."""
        if not self.sms:
            logger.warning('SMS not sent - Africa\'s Talking not configured')
            return {'status': 'failed', 'message': 'SMS service not configured'}

        try:
            formatted_number = _format_phone_number(phone_number)
            response = self.sms.send(
                message,
                [formatted_number],
                sender_id=self.sender,
            )
            logger.info('SMS sent to %s: %s', formatted_number, response)
            return {'status': 'success', 'response': response}
        except Exception as exc:
            logger.error('SMS failed for %s: %s', phone_number, exc)
            return {'status': 'failed', 'error': str(exc)}

    def send_bulk_sms(self, phone_numbers: Iterable[str], message: str) -> dict:
        """Send bulk SMS to multiple recipients."""
        if not self.sms:
            return {'status': 'failed', 'message': 'SMS service not configured'}

        try:
            formatted_numbers = [_format_phone_number(phone) for phone in phone_numbers]
            response = self.sms.send(
                message,
                formatted_numbers,
                sender_id=self.sender,
            )
            return {'status': 'success', 'response': response}
        except Exception as exc:
            logger.error('Bulk SMS failed: %s', exc)
            return {'status': 'failed', 'error': str(exc)}


def send_otp_message(phone: str, otp: str) -> dict:
    message = f'Your MAMBONAMI verification code is {otp}. It expires in 5 minutes.'
    sms_service = AfricaTalkingSMS()
    result = sms_service.send_sms(phone, message)

    if result.get('status') != 'success':
        logger.warning('OTP SMS failed for %s: %s', phone, result.get('error') or result.get('message'))

    return result