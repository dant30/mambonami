from django.test import TestCase
from apps.users.models import User, VerificationDocument, TrustScore


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
