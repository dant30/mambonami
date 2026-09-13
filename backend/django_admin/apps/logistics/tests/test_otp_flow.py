from types import SimpleNamespace
from unittest.mock import patch

from django.test import SimpleTestCase
from apps.logistics.serializers import OTPVerifySerializer
from apps.logistics.services.otp_service import generate_otp


class DeliveryOtpContractTests(SimpleTestCase):
    def test_generated_otp_is_six_digits(self):
        trip = SimpleNamespace(otp_hash='', otp_expires_at=None, otp_attempts=0, id=1)
        with patch('django.contrib.auth.hashers.make_password', return_value='hashed'):
            otp = generate_otp(trip)

        self.assertRegex(otp, r'^\d{6}$')
        self.assertEqual(trip.otp_hash, 'hashed')
        self.assertEqual(trip.otp_attempts, 0)

    def test_verification_requires_six_digit_otp_and_delivery_photo(self):
        missing_photo = OTPVerifySerializer(data={'otp': '123456'})
        self.assertFalse(missing_photo.is_valid())
        self.assertIn('delivery_photo', missing_photo.errors)

        four_digits = OTPVerifySerializer(data={'otp': '1234', 'delivery_photo': object()})
        self.assertFalse(four_digits.is_valid())
        self.assertIn('otp', four_digits.errors)
