# backend/django_admin/apps/users/views/admin_views.py
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from ..models import FarmerProfile, TransportProviderProfile, User
from ..permissions import IsAdmin
from ..serializers.admin_serializers import (
    FarmerAdminSerializer,
    StaffAdminSerializer,
    TransportProviderAdminSerializer,
    UserAdminSerializer,
    UserAdminDetailSerializer,
)


class FarmerAdminViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAdmin]
    queryset = FarmerProfile.objects.select_related('user')
    serializer_class = FarmerAdminSerializer

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        farmer = self.get_object()
        farmer.coop_verified = True
        farmer.save(update_fields=['coop_verified'])
        return Response({'status': 'approved', 'id': farmer.id}, status=status.HTTP_200_OK)


class TransportProviderAdminViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAdmin]
    queryset = TransportProviderProfile.objects.select_related('user')
    serializer_class = TransportProviderAdminSerializer

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        provider = self.get_object()
        provider.is_approved = True
        provider.save(update_fields=['is_approved'])
        return Response({'status': 'approved', 'id': provider.id}, status=status.HTTP_200_OK)


class UserAdminViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAdmin]
    queryset = User.objects.all().order_by('-date_joined')
    serializer_class = UserAdminSerializer

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return UserAdminDetailSerializer
        return UserAdminSerializer

    @action(detail=True, methods=['post'])
    def suspend(self, request, pk=None):
        user = self.get_object()
        if user.pk == request.user.pk or user.is_superuser:
            return Response(
                {'detail': 'You cannot suspend yourself or a superuser.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        user.is_active = False
        user.save(update_fields=['is_active'])
        return Response({'status': 'suspended', 'id': user.id}, status=status.HTTP_200_OK)

    @action(detail=True, methods=['post'])
    def activate(self, request, pk=None):
        user = self.get_object()
        user.is_active = True
        user.save(update_fields=['is_active'])
        return Response({'status': 'activated', 'id': user.id}, status=status.HTTP_200_OK)


class StaffAdminViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAdmin]
    serializer_class = StaffAdminSerializer
    queryset = User.objects.filter(is_staff=True, is_superuser=False).order_by('last_name', 'first_name', 'id')