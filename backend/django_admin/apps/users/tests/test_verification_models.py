from django.test import SimpleTestCase, TestCase
from rest_framework.test import APIRequestFactory
from apps.users.models import User, VerificationDocument, TrustScore
from apps.users.serializers.verification_serializer import VerificationDocumentSerializer


class VerificationModelsTests(TestCase):
    def test_verification_and_trust_score_models_can_be_created(self):
        user = User.objects.create_user(
            phone='+254700000002',
            username='trust-user',
            password='StrongPass123!',
            role='farmer',
        )
        document = VerificationDocument.objects.create(
            user=user,
            document_type='national_id',
            status='submitted',
        )
        score = TrustScore.objects.create(
            user=user,
            score=78,
            score_band='good',
            reason='Identity verified',
        )
        self.assertEqual(document.status, 'submitted')
        self.assertEqual(score.score_band, 'good')


class VerificationDocumentSerializerTests(SimpleTestCase):
    def test_user_cannot_change_document_review_status(self):
        request = APIRequestFactory().post('/api/users/verification/documents/')
        request.user = type('UserStub', (), {'is_staff': False, 'is_superuser': False, 'role': 'buyer'})()
        serializer = VerificationDocumentSerializer(context={'request': request})

        self.assertTrue(serializer.fields['status'].read_only)
        self.assertTrue(serializer.fields['notes'].read_only)
