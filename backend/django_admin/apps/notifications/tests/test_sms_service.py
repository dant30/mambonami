from unittest.mock import patch

from django.test import TestCase, override_settings

from apps.notifications.services.sms import OTSSMS


class FakeResponse:
    def __init__(self, payload, status_code=200, text=''):
        self.payload = payload
        self.status_code = status_code
        self.text = text

    def json(self):
        return self.payload

    def raise_for_status(self):
        return None


@override_settings(
    OTS_API_URL='https://sms.ots.co.ke/api/v3/',
    OTS_API_TOKEN='test-token',
    OTS_SENDER_ID='PROCALL',
)
class OTSSMSTests(TestCase):
    @patch('apps.notifications.services.sms.requests.post')
    def test_send_sms_posts_ots_payload_with_numeric_kenyan_recipient(self, mock_post):
        mock_post.return_value = FakeResponse({'status': 'success', 'message_id': 'abc123'})

        result = OTSSMS().send_sms('+254712345678', 'Your code is 1234')

        self.assertEqual(result['status'], 'success')
        mock_post.assert_called_once()
        _, kwargs = mock_post.call_args
        self.assertEqual(kwargs['json']['recipient'], '254712345678')
        self.assertEqual(kwargs['json']['to'], '254712345678')
        self.assertEqual(kwargs['json']['sender_id'], 'PROCALL')
        self.assertEqual(kwargs['headers']['Authorization'], 'Bearer test-token')

    @override_settings(OTS_API_TOKEN='Bearer prefixed-token')
    @patch('apps.notifications.services.sms.requests.post')
    def test_send_sms_accepts_token_without_duplicating_bearer_prefix(self, mock_post):
        mock_post.return_value = FakeResponse({'status': 'queued', 'id': 'queued-1'})

        result = OTSSMS().send_sms('0712345678', 'Your code is 1234')

        self.assertEqual(result['status'], 'success')
        _, kwargs = mock_post.call_args
        self.assertEqual(kwargs['headers']['Authorization'], 'Bearer prefixed-token')

    @patch('apps.notifications.services.sms.requests.post')
    def test_send_sms_marks_provider_failure_as_failed(self, mock_post):
        mock_post.return_value = FakeResponse({'status': 'failed', 'message': 'Invalid sender'})

        result = OTSSMS().send_sms('0712345678', 'Your code is 1234')

        self.assertEqual(result['status'], 'failed')
        self.assertEqual(result['message'], 'Invalid sender')
