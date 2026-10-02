from django.test import SimpleTestCase
from rest_framework.exceptions import ValidationError

from apps.orders.serializers import OrderCreateSerializer


class OrderCreateSerializerTests(SimpleTestCase):
    def test_optional_landmark_uses_blank_string_not_null(self):
        field = OrderCreateSerializer().fields['delivery_landmark']

        self.assertEqual(field.run_validation(''), '')
        with self.assertRaises(ValidationError):
            field.run_validation(None)
