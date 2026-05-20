# backend/django_admin/apps/disputes/views/api.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from ..models import Dispute
from ..serializers import DisputeSerializer, DisputeCreateSerializer, DisputeResolutionSerializer
from ..services.resolution import resolve_dispute
from apps.users.permissions import IsAdmin

class DisputeCreateView(generics.CreateAPIView):
    """Buyer/farmer/provider raises a dispute."""
    serializer_class = DisputeCreateSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(raised_by=self.request.user, status='open')

class DisputeListView(generics.ListAPIView):
    """List disputes accessible to the user (admin sees all, others see own)."""
    serializer_class = DisputeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return Dispute.objects.all()
        # User can see disputes they raised or disputes on orders they are part of
        return Dispute.objects.filter(
            models.Q(raised_by=user) |
            models.Q(order__buyer=user) |
            models.Q(order__farmer_profile__user=user) |
            models.Q(order__trip__provider__user=user)
        ).distinct()

class DisputeDetailView(generics.RetrieveAPIView):
    serializer_class = DisputeSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'uuid'

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return Dispute.objects.all()
        return Dispute.objects.filter(
            models.Q(raised_by=user) |
            models.Q(order__buyer=user) |
            models.Q(order__farmer_profile__user=user) |
            models.Q(order__trip__provider__user=user)
        ).distinct()

class DisputeResolveView(generics.GenericAPIView):
    """Admin endpoint to resolve a dispute."""
    permission_classes = [IsAdmin]
    serializer_class = DisputeResolutionSerializer
    lookup_field = 'uuid'

    def get_queryset(self):
        return Dispute.objects.filter(status__in=['open', 'under_review'])

    def post(self, request, uuid):
        dispute = generics.get_object_or_404(self.get_queryset(), uuid=uuid)
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        resolved = resolve_dispute(dispute, serializer.validated_data, request.user)
        return Response(DisputeSerializer(resolved).data, status=status.HTTP_200_OK)