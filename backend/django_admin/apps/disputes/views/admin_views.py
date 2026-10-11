from django.db import transaction
from django.shortcuts import get_object_or_404
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.users.permissions import IsAdmin

from ..models import Dispute, DisputeEvent
from ..serializers import DisputeSerializer


class DisputeStartReviewView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsAdmin]

    def post(self, request, uuid):
        with transaction.atomic():
            dispute = get_object_or_404(Dispute.objects.select_for_update(), uuid=uuid)
            if dispute.status not in (Dispute.Status.OPEN, Dispute.Status.UNDER_REVIEW):
                return Response(
                    {'detail': 'Only open disputes can be started or reassigned for review.'},
                    status=status.HTTP_409_CONFLICT,
                )
            if dispute.assigned_to_id and dispute.assigned_to_id != request.user.id:
                return Response(
                    {'detail': 'This dispute is already assigned to another administrator.'},
                    status=status.HTTP_409_CONFLICT,
                )

            first_review = dispute.status == Dispute.Status.OPEN
            dispute.status = Dispute.Status.UNDER_REVIEW
            dispute.assigned_to = request.user
            dispute.save(update_fields=['status', 'assigned_to', 'updated_at'])
            if first_review:
                DisputeEvent.objects.create(
                    dispute=dispute,
                    actor=request.user,
                    event_type=DisputeEvent.EventType.REVIEWED,
                    details='Review started by administrator.',
                )

        return Response(DisputeSerializer(dispute).data, status=status.HTTP_200_OK)