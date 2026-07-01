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


def _format_ots_recipient(phone_number: str) -> str:
    """OTS expects Kenyan recipients without the leading plus sign."""
    return _format_phone_number(phone_number).lstrip('+')


def _is_success_response(result: Dict[str, Any]) -> bool:
    if not isinstance(result, dict):
        return False
    success_values = {'success', 'ok', 'sent', 'queued', 'accepted', 'delivered'}
    failure_values = {'failed', 'fail', 'error', 'rejected', 'invalid', 'undelivered'}
    status = result.get('status')
    if isinstance(status, str) and status.lower() in failure_values:
        return False
    if isinstance(status, str) and status.lower() in success_values:
        return True
    if status is True:
        return True
    if result.get('success') is True:
        return True
    for key in ('data', 'message', 'messages', 'response'):
        nested = result.get(key)
        if isinstance(nested, dict) and _is_success_response(nested):
            return True
        if isinstance(nested, list) and any(
            isinstance(item, dict) and _is_success_response(item)
            for item in nested
        ):
            return True
    return False


def _provider_error_message(result: Dict[str, Any]) -> str:
    if not isinstance(result, dict):
        return ''
    for key in ('error', 'message', 'description', 'detail'):
        value = result.get(key)
        if isinstance(value, str) and value:
            return value
    for key in ('data', 'response'):
        nested = result.get(key)
        if isinstance(nested, dict):
            message = _provider_error_message(nested)
            if message:
                return message
    return ''


def _provider_message_id(result: Dict[str, Any]) -> str:
    if not isinstance(result, dict):
        return ''
    for key in ('message_id', 'id', 'queue_uid', 'uid'):
        value = result.get(key)
        if isinstance(value, str) and value:
            return value
    for key in ('data', 'response'):
        nested = result.get(key)
        if isinstance(nested, dict):
            message_id = _provider_message_id(nested)
            if message_id:
                return message_id
    return ''


def _provider_status_url(result: Dict[str, Any]) -> str:
    if not isinstance(result, dict):
        return ''
    value = result.get('check_status_url')
    if isinstance(value, str) and value:
        return value
    for key in ('data', 'response'):
        nested = result.get(key)
        if isinstance(nested, dict):
            status_url = _provider_status_url(nested)
            if status_url:
                return status_url
    return ''


class OTSSMS:
    """OTS (Olympus Telecom Solutions) SMS Gateway."""

    def __init__(self):
        self.api_url = getattr(settings, 'OTS_API_URL', 'https://sms.ots.co.ke/api/v3/')
        self.api_token = getattr(settings, 'OTS_API_TOKEN', '')
        self.sender_id = getattr(settings, 'OTS_SENDER_ID', 'MAMBONAMI')
        self.sandbox = getattr(settings, 'OTS_SANDBOX', True)
        self.debug = getattr(settings, 'OTS_DEBUG', False)

    def _get_headers(self) -> Dict[str, str]:
        token = self.api_token.strip()
        if token.lower().startswith('bearer '):
            logger.warning('OTS_API_TOKEN contains a Bearer prefix. Remove the prefix from the token value.')
            token = token.split(None, 1)[1]
        return {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        }

    def _safe_headers_for_logging(self) -> Dict[str, str]:
        headers = self._get_headers().copy()
        if headers.get('Authorization'):
            headers['Authorization'] = 'Bearer ***'
        return headers

    def _build_payload(self, recipient, message: str) -> Dict[str, Any]:
        return {
            'recipient': recipient,
            'to': recipient,
            'sender': self.sender_id,
            'sender_id': self.sender_id,
            'from': self.sender_id,
            'message': message,
            'type': 'plain',
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
        ots_recipient = _format_ots_recipient(phone_number)
        endpoint = f"{self.api_url.rstrip('/')}/sms/send"
        payload = self._build_payload(ots_recipient, message)
        logger.info('Sending OTS SMS to %s using sender %s', formatted_number, self.sender_id)
        logger.debug('OTS SMS payload for %s: %s', formatted_number, payload)
        if self.debug:
            logger.debug('OTS request endpoint: %s', endpoint)
            logger.debug('OTS request headers: %s', self._safe_headers_for_logging())

        try:
            response = requests.post(
                endpoint,
                json=payload,
                headers=self._get_headers(),
                timeout=30,
            )
            try:
                result = response.json()
            except ValueError:
                body = response.text[:500]
                logger.error(
                    'OTS SMS returned non-JSON response for %s: HTTP %s %s',
                    formatted_number,
                    response.status_code,
                    body,
                )
                response.raise_for_status()
                return {
                    'status': 'failed',
                    'error': f'OTS returned non-JSON response with HTTP {response.status_code}',
                    'status_code': response.status_code,
                    'response': body,
                }

            response.raise_for_status()
            success = _is_success_response(result)
            log_method = logger.info if success else logger.warning
            log_method(
                'OTS SMS response for %s: HTTP %s success=%s body=%s',
                formatted_number,
                response.status_code,
                success,
                result,
            )
            if self.debug:
                logger.debug('OTS SMS response body: %s', result)
            return {
                'status': 'success' if success else 'failed',
                'status_code': response.status_code,
                'response': result,
                'message_id': _provider_message_id(result),
                'check_status_url': _provider_status_url(result),
                'message': _provider_error_message(result),
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
        ots_recipients = [_format_ots_recipient(phone) for phone in phone_numbers]
        endpoint = f"{self.api_url.rstrip('/')}/sms/send"
        payload = self._build_payload(ots_recipients, message)

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

    def check_queue_status(self, queue_uid: str) -> Dict[str, Any]:
        if not self.api_token:
            return {'status': 'failed', 'message': 'OTS API token not configured'}

        endpoint = f"{self.api_url.rstrip('/')}/sms/queue/{queue_uid}"
        try:
            response = requests.get(
                endpoint,
                headers=self._get_headers(),
                timeout=30,
            )
            try:
                result = response.json()
            except ValueError:
                body = response.text[:500]
                response.raise_for_status()
                return {
                    'status': 'failed',
                    'error': f'OTS returned non-JSON response with HTTP {response.status_code}',
                    'status_code': response.status_code,
                    'response': body,
                }

            response.raise_for_status()
            return {
                'status': 'success' if _is_success_response(result) else 'failed',
                'status_code': response.status_code,
                'response': result,
                'message': _provider_error_message(result),
            }
        except requests.exceptions.Timeout:
            logger.error('OTS queue status timeout for %s', queue_uid)
            return {'status': 'failed', 'error': 'Request timeout'}
        except requests.exceptions.RequestException as exc:
            logger.error('OTS queue status failed for %s: %s', queue_uid, exc)
            return {'status': 'failed', 'error': str(exc)}


AfricaTalkingSMS = OTSSMS


def send_otp_message(phone: str, otp: str) -> dict:
    message = f'Your MAMBONAMI verification code is {otp}. It expires in 5 minutes.'
    sms_service = AfricaTalkingSMS()
    result = sms_service.send_sms(phone, message)

    if result.get('status') != 'success':
        logger.warning('OTP SMS failed for %s: %s', phone, result.get('error') or result.get('message'))

    return result
