from django.test import SimpleTestCase

from apps.paybill.services.stk_push import StkPushError, normalize_ke_phone


class KenyanPhoneNormalizationTests(SimpleTestCase):
    def test_local_number_is_converted_to_international_format(self):
        self.assertEqual(normalize_ke_phone('0712345678'), '254712345678')

    def test_international_number_with_plus_is_normalized(self):
        self.assertEqual(normalize_ke_phone('+254 712 345 678'), '254712345678')

    def test_non_kenyan_number_is_rejected(self):
        with self.assertRaises(StkPushError):
            normalize_ke_phone('+15551234567')
