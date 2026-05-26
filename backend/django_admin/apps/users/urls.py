# backend/django_admin/apps/users/urls.py
from django.urls import path
from .views.api import (
    RegisterInitView,
    VerifyOTPView,
    PasswordResetInitView,
    PasswordResetVerifyView,
    CustomTokenObtainPairView,
    ProfileView,
)

urlpatterns = [
    path('register/init/', RegisterInitView.as_view(), name='register_init'),
    path('register/verify/', VerifyOTPView.as_view(), name='register_verify'),
    path('password-reset/init/', PasswordResetInitView.as_view(), name='password_reset_init'),
    path('password-reset/verify/', PasswordResetVerifyView.as_view(), name='password_reset_verify'),
    path('login/', CustomTokenObtainPairView.as_view(), name='login'),
    path('profile/', ProfileView.as_view(), name='profile'),
]