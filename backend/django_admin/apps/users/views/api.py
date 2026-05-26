# backend/django_admin/apps/users/views/api.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from core.throttling import BurstThrottle
from ..serializers import (
    RegisterInitSerializer,
    VerifyOTPSerializer,
    PasswordResetInitSerializer,
    PasswordResetVerifySerializer,
    UserDetailSerializer,
    LoginSerializer,
)
from ..models import User
from ..services import get_tokens_for_user, authenticate_user


class RegisterInitView(generics.GenericAPIView):
    serializer_class = RegisterInitSerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [BurstThrottle]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        result = serializer.save()
        return Response(result, status=status.HTTP_200_OK)


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


class PasswordResetInitView(generics.GenericAPIView):
    serializer_class = PasswordResetInitSerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [BurstThrottle]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        result = serializer.save()
        return Response(result, status=status.HTTP_200_OK)


class PasswordResetVerifyView(generics.GenericAPIView):
    serializer_class = PasswordResetVerifySerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [BurstThrottle]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'message': 'Password has been reset successfully.'}, status=status.HTTP_200_OK)


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
        return Response(tokens, status=status.HTTP_200_OK)


class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserDetailSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

    def patch(self, request, *args, **kwargs):
        user = self.get_object()
        user.email = request.data.get('email', user.email)
        user.username = request.data.get('username', user.username)
        user.first_name = request.data.get('first_name', user.first_name)
        user.last_name = request.data.get('last_name', user.last_name)
        user.save(update_fields=['email', 'username', 'first_name', 'last_name'])
        return Response(self.get_serializer(user).data)
