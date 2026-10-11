from django.test import SimpleTestCase

from apps.audit.models import AuditLog
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
