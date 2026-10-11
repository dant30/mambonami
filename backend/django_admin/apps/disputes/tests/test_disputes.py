from contextlib import nullcontext
from types import SimpleNamespace
from unittest.mock import Mock, patch
from uuid import uuid4

from django.test import SimpleTestCase
from rest_framework.test import APIRequestFactory, force_authenticate

from apps.disputes.models import Dispute
from apps.disputes.views.admin_views import DisputeStartReviewView


class DisputeStartReviewTests(SimpleTestCase):
	def setUp(self):
		self.factory = APIRequestFactory()
		self.view = DisputeStartReviewView.as_view()
		self.admin = SimpleNamespace(is_authenticated=True, is_staff=True, is_superuser=False, id=7)
		self.uuid = uuid4()

	def make_request(self):
		request = self.factory.post(f'/admin-api/disputes/{self.uuid}/review/', {}, format='json')
		force_authenticate(request, user=self.admin)
		return request

	def test_open_dispute_is_assigned_and_review_event_is_created(self):
		dispute = SimpleNamespace(
			status=Dispute.Status.OPEN,
			assigned_to_id=None,
			assigned_to=None,
			save=Mock(),
		)
		serializer = Mock()
		serializer.data = {'status': Dispute.Status.UNDER_REVIEW}

		with patch('apps.disputes.views.admin_views.transaction.atomic', return_value=nullcontext()), \
			 patch('apps.disputes.views.admin_views.get_object_or_404', return_value=dispute), \
			 patch('apps.disputes.views.admin_views.DisputeEvent.objects.create') as create_event, \
			 patch('apps.disputes.views.admin_views.DisputeSerializer', return_value=serializer):
			response = self.view(self.make_request(), uuid=self.uuid)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(dispute.status, Dispute.Status.UNDER_REVIEW)
		self.assertEqual(dispute.assigned_to, self.admin)
		create_event.assert_called_once()

	def test_dispute_assigned_to_another_admin_is_not_reassigned(self):
		dispute = SimpleNamespace(
			status=Dispute.Status.UNDER_REVIEW,
			assigned_to_id=99,
			assigned_to=None,
			save=Mock(),
		)

		with patch('apps.disputes.views.admin_views.transaction.atomic', return_value=nullcontext()), \
			 patch('apps.disputes.views.admin_views.get_object_or_404', return_value=dispute):
			response = self.view(self.make_request(), uuid=self.uuid)

		self.assertEqual(response.status_code, 409)
		dispute.save.assert_not_called()
