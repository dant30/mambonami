from django.test import SimpleTestCase, TestCase
from django.urls import reverse
from rest_framework.test import APIClient

from apps.audit.models import AuditLog, SecurityEvent
from apps.audit.serializers import AuditLogSerializer
from apps.users.models import User


class AuditLogSerializerTests(SimpleTestCase):
	def test_audit_serializer_fields_are_read_only_and_dashboard_compatible(self):
		serializer = AuditLogSerializer()

		self.assertIn('uuid', serializer.fields)
		self.assertIn('actor_phone', serializer.fields)
		self.assertIn('resource_type', serializer.fields)
		self.assertIn('created_at', serializer.fields)
		self.assertTrue(all(field.read_only for field in serializer.fields.values()))

	def test_serializes_audit_aliases_and_nullable_actor(self):
		user = User(phone='+254700000000', username='staff', first_name='Staff')
		log = AuditLog(
			user=user,
			action='UPDATE',
			model_name='products.Product',
			object_id='42',
			object_repr='Tomatoes',
			changes={'is_active': [True, False]},
		)

		data = AuditLogSerializer(log).data

		self.assertEqual(data['actor_phone'], user.phone)
		self.assertEqual(data['resource_type'], 'products.Product')
		self.assertEqual(data['resource_id'], '42')
		self.assertEqual(data['metadata'], {'is_active': [True, False]})
		self.assertIsNone(AuditLogSerializer(AuditLog(action='VIEW', model_name='users.User', object_id='1')).data['actor'])


class AdminSecurityEventAPITests(TestCase):
	def setUp(self):
		self.admin = User.objects.create_user(
			phone='+254700000010',
			username='audit-admin',
			password='StrongPass123!',
			is_staff=True,
		)
		self.event = SecurityEvent.objects.create(
			event_type='authentication_failed',
			description='An authentication attempt failed.',
			severity=SecurityEvent.Severity.HIGH,
			request_id='security-event-test',
		)
		self.client = APIClient()
		self.client.force_authenticate(user=self.admin)

	def test_admin_can_filter_and_review_security_events(self):
		list_response = self.client.get(reverse('admin_audit:admin-security-event-list'), {'severity': 'high'})
		self.assertEqual(list_response.status_code, 200)
		self.assertIn('results', list_response.data)
		self.assertEqual(list_response.data['results'][0]['request_id'], 'security-event-test')

		update_response = self.client.patch(
			reverse('admin_audit:admin-security-event-detail', kwargs={'uuid': self.event.uuid}),
			{'investigated': True, 'investigation_notes': 'Reviewed with the user.'},
			format='json',
		)
		self.assertEqual(update_response.status_code, 200)
		self.event.refresh_from_db()
		self.assertTrue(self.event.investigated)
		self.assertEqual(self.event.investigation_notes, 'Reviewed with the user.')
		self.assertTrue(AuditLog.objects.filter(user=self.admin, model_name='audit.SecurityEvent').exists())
