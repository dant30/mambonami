# backend/django_admin/apps/users/urls/urls.py
from django.urls import path
from ..views.api import (
    RegisterInitView,
    VerifyOTPView,
    PasswordResetInitView,
    PasswordResetVerifyView,
    PasswordChangeView,
    CustomTokenObtainPairView,
    ProfileView,
    AvatarUploadView,
    VerificationDocumentListCreateView,
    VerificationDocumentDetailView,
    VerificationDocumentReviewView,
    TrustScoreDetailView,
)

app_name = 'users'

urlpatterns = [
    # Authentication
    path('register/init/', RegisterInitView.as_view(), name='register-init'),
    path('register/verify/', VerifyOTPView.as_view(), name='register-verify'),
    path('login/', CustomTokenObtainPairView.as_view(), name='login'),
    path('password-reset/init/', PasswordResetInitView.as_view(), name='password-reset-init'),
    path('password-reset/verify/', PasswordResetVerifyView.as_view(), name='password-reset-verify'),
    path('password-change/', PasswordChangeView.as_view(), name='password-change'),

    # Profile
    path('profile/', ProfileView.as_view(), name='profile'),
    path('profile/avatar/', AvatarUploadView.as_view(), name='avatar-upload'),

    # Verification Documents
    path('verification/documents/', VerificationDocumentListCreateView.as_view(), name='verification-document-list'),
    path('verification/documents/<uuid:uuid>/', VerificationDocumentDetailView.as_view(), name='verification-document-detail'),
    path('verification/documents/<uuid:uuid>/review/', VerificationDocumentReviewView.as_view(), name='verification-document-review'),

    # Trust Score (self)
    path('verification/trust-score/', TrustScoreDetailView.as_view(), name='trust-score-self'),
    # Trust Score (by UUID – admin only, but view handles permissions)
    path('verification/trust-score/<uuid:uuid>/', TrustScoreDetailView.as_view(), name='trust-score-detail'),
]