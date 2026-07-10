# backend/django_admin/apps/users/views/api.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from core.throttling import BurstThrottle
from ..serializers import (
    RegisterInitSerializer,
    VerifyOTPSerializer,
    PasswordResetInitSerializer,
    PasswordResetVerifySerializer,
    ChangePasswordSerializer,
    UserDetailSerializer,
    LoginSerializer,
)
from ..models import User
from ..services import get_tokens_for_user, authenticate_user


@method_decorator(csrf_exempt, name='dispatch')
class RegisterInitView(generics.GenericAPIView):
    serializer_class = RegisterInitSerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [BurstThrottle]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        result = serializer.save()
        return Response(result, status=status.HTTP_200_OK)


@method_decorator(csrf_exempt, name='dispatch')
class VerifyOTPView(generics.CreateAPIView):
    serializer_class = VerifyOTPSerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [BurstThrottle]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        tokens = get_tokens_for_user(user)
        return Response(
            {'user': UserDetailSerializer(user).data, 'tokens': tokens},
            status=status.HTTP_201_CREATED,
        )


@method_decorator(csrf_exempt, name='dispatch')
class PasswordResetInitView(generics.GenericAPIView):
    serializer_class = PasswordResetInitSerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [BurstThrottle]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        result = serializer.save()
        return Response(result, status=status.HTTP_200_OK)


@method_decorator(csrf_exempt, name='dispatch')
class PasswordResetVerifyView(generics.GenericAPIView):
    serializer_class = PasswordResetVerifySerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [BurstThrottle]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'message': 'Password has been reset successfully.'}, status=status.HTTP_200_OK)


@method_decorator(csrf_exempt, name='dispatch')
class CustomTokenObtainPairView(generics.GenericAPIView):
    serializer_class = LoginSerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [BurstThrottle]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data['phone']
        password = serializer.validated_data['password']
        user = authenticate_user(phone, password)
        if not user:
            return Response({'detail': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

        tokens = get_tokens_for_user(user)
        user_data = UserDetailSerializer(user).data
        return Response(
            {'tokens': tokens, 'user': user_data},
            status=status.HTTP_200_OK
        )


class PasswordChangeView(generics.GenericAPIView):
    serializer_class = ChangePasswordSerializer
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'message': 'Password changed successfully.'}, status=status.HTTP_200_OK)


class ProfileView(generics.RetrieveUpdateDestroyAPIView):
    """
    Retrieve, update (partial), or delete the authenticated user's profile.
    Supports avatar upload via multipart/form-data.
    """
    serializer_class = UserDetailSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]  # allow file uploads

    def get_object(self):
        return self.request.user

    def patch(self, request, *args, **kwargs):
        user = self.get_object()
        # Update simple fields (including new ones)
        update_fields = ['email', 'username', 'first_name', 'last_name', 'middle_name', 'national_id']
        for field in update_fields:
            if field in request.data:
                setattr(user, field, request.data[field])
        # Avatar is handled automatically by the serializer if present in request.FILES
        # but we need to explicitly set it if present
        if 'avatar' in request.FILES:
            user.avatar = request.FILES['avatar']
        user.save(update_fields=update_fields + ['avatar'])
        return Response(self.get_serializer(user).data)

    def delete(self, request, *args, **kwargs):
        user = self.get_object()
        user.delete()
        return Response({'message': 'Account deleted successfully.'}, status=status.HTTP_204_NO_CONTENT)


class AvatarUploadView(generics.UpdateAPIView):
    """
    Dedicated endpoint to upload/update the user's avatar.
    Accepts multipart/form-data with field 'avatar'.
    """
    serializer_class = UserDetailSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_object(self):
        return self.request.user

    def patch(self, request, *args, **kwargs):
        user = self.get_object()
        if 'avatar' not in request.FILES:
            return Response({'error': 'No avatar file provided.'}, status=status.HTTP_400_BAD_REQUEST)
        user.avatar = request.FILES['avatar']
        user.save(update_fields=['avatar'])
        return Response(self.get_serializer(user).data)