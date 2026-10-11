from django.contrib.auth import get_user_model
from django.contrib.auth.signals import user_logged_in
from django.test import RequestFactory, TestCase

from apps.audit.models import AuditLog, SecurityEvent
from apps.audit.services import log_security_event


class SecurityEventTests(TestCase):
	def test_successful_login_creates_audit_log_with_request_context(self):
		user = get_user_model().objects.create_user(
			username='audit-login-test',
			phone='254700000001',
			password='StrongPass123!',
		)
		request = RequestFactory().post('/api/auth/login/', REMOTE_ADDR='203.0.113.11')
		request.request_id = 'login-request-123'

		user_logged_in.send(sender=get_user_model(), request=request, user=user)

		log = AuditLog.objects.get(user=user, action='LOGIN')
		self.assertEqual(log.model_name, 'users.User')
		self.assertEqual(log.object_id, str(user.pk))
		self.assertEqual(log.user_ip, '203.0.113.11')
		self.assertEqual(log.request_id, 'login-request-123')

	def test_security_event_records_request_and_redacts_sensitive_metadata(self):
		request = RequestFactory().post('/api/auth/login/', HTTP_X_FORWARDED_FOR='203.0.113.10')
		request.request_id = 'failed-login-request-456'
		event = log_security_event(
			event_type='authentication_failed',
			description='An authentication attempt failed.',
			request=request,
			metadata={
				'provider': 'password',
				'auth': {'access_token': 'should-not-be-stored'},
				'attempt': {'otp-code': '123456'},
			},
		)

		self.assertEqual(event.ip_address, '203.0.113.10')
		self.assertEqual(event.request_id, 'failed-login-request-456')
		self.assertEqual(event.metadata['provider'], 'password')
		self.assertEqual(event.metadata['auth']['access_token'], '[REDACTED]')
		self.assertEqual(event.metadata['attempt']['otp-code'], '[REDACTED]')
		self.assertEqual(event.severity, SecurityEvent.Severity.MEDIUM)
		self.assertFalse(event.investigated)
