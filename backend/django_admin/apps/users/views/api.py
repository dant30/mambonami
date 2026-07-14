# backend/django_admin/apps/users/views/api.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.views import APIView
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.utils import timezone
from django.shortcuts import get_object_or_404
from core.throttling import BurstThrottle
from core.validators import normalize_phone_number
from apps.users.permissions import IsAdmin
from ..serializers import (
    RegisterInitSerializer,
    VerifyOTPSerializer,
    PasswordResetInitSerializer,
    PasswordResetVerifySerializer,
    ChangePasswordSerializer,
    UserDetailSerializer,
    LoginSerializer,
    VerificationDocumentSerializer,
    TrustScoreSerializer,
    VerificationReviewSerializer,
)
from ..models import User, VerificationDocument, TrustScore, KycStatus, AccountStatus
from ..services import get_tokens_for_user, authenticate_user


# ────────────────────────────────────────────────────────────────
# AUTHENTICATION & REGISTRATION
# ────────────────────────────────────────────────────────────────

@method_decorator(csrf_exempt, name='dispatch')
class RegisterInitView(generics.GenericAPIView):
    """Step 1: Send OTP to phone."""
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
    """Step 2: Verify OTP and create user."""
    serializer_class = VerifyOTPSerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [BurstThrottle]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            user = serializer.save()
            tokens = get_tokens_for_user(user)
            return Response(
                {'user': UserDetailSerializer(user, context={'request': request}).data, 'tokens': tokens},
                status=status.HTTP_201_CREATED,
            )
        except Exception:
            safe_data = dict(request.data)
            for key in ('password', 'confirm_password', 'otp'):
                if key in safe_data:
                    safe_data[key] = '***'
            logger = __import__('logging').getLogger(__name__)
            logger.exception('Error creating user during verify. request_data=%s', safe_data)

            phone = request.data.get('phone')
            username = request.data.get('username')
            existing_user = None
            if phone:
                try:
                    existing_user = User.objects.filter(phone=normalize_phone_number(phone)).first()
                except Exception:
                    existing_user = None

            # If a user record exists (created during the failing save), return the user data.
            # Attempt to include tokens, but don't fail the whole request if token generation fails.
            if existing_user and (not username or existing_user.username == username):
                try:
                    tokens = None
                    try:
                        tokens = get_tokens_for_user(existing_user)
                    except Exception:
                        logger.exception('Token generation failed for existing user during verify; returning user data without tokens.')

                    user_data = UserDetailSerializer(existing_user, context={'request': request}).data
                    resp = {'user': user_data}
                    if tokens:
                        resp['tokens'] = tokens
                    return Response(resp, status=status.HTTP_201_CREATED)
                except Exception:
                    logger.exception('Fallback response generation failed for existing user during verify.')

            return Response({'detail': 'Internal server error while creating user.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@method_decorator(csrf_exempt, name='dispatch')
class PasswordResetInitView(generics.GenericAPIView):
    """Request password reset OTP."""
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
    """Verify OTP and reset password."""
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
    """Login with phone + password, returns JWT tokens + user data."""
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

        # Update last login info
        user.last_login = timezone.now()
        user.last_login_ip = request.META.get('REMOTE_ADDR')
        user.save(update_fields=['last_login', 'last_login_ip'])

        tokens = get_tokens_for_user(user)
        user_data = UserDetailSerializer(user, context={'request': request}).data
        return Response(
            {'tokens': tokens, 'user': user_data},
            status=status.HTTP_200_OK
        )


# ────────────────────────────────────────────────────────────────
# PROFILE MANAGEMENT
# ────────────────────────────────────────────────────────────────

class PasswordChangeView(generics.GenericAPIView):
    """Change password for authenticated user."""
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
    parser_classes = [MultiPartParser, FormParser]

    def get_object(self):
        return self.request.user

    def patch(self, request, *args, **kwargs):
        user = self.get_object()
        update_fields = []

        # Simple fields
        simple_fields = ['email', 'username', 'first_name', 'last_name', 'middle_name', 'national_id']
        for field in simple_fields:
            if field in request.data:
                setattr(user, field, request.data[field])
                update_fields.append(field)

        # Avatar
        if 'avatar' in request.FILES:
            user.avatar = request.FILES['avatar']
            update_fields.append('avatar')

        # Handle profile-specific fields (role-specific)
        role = user.role
        if role == 'farmer' and hasattr(user, 'farmer_profile'):
            farmer = user.farmer_profile
            farmer_fields = ['latitude', 'longitude', 'county', 'sub_county', 'ward',
                           'village', 'cooperative', 'mpesa_number', 'bank_account']
            for field in farmer_fields:
                if field in request.data:
                    setattr(farmer, field, request.data[field])
            farmer.save()

        elif role == 'transport_provider' and hasattr(user, 'transport_profile'):
            transport = user.transport_profile
            transport_fields = ['vehicle_type', 'capacity_kg', 'license_plate',
                              'driver_license', 'bank_account', 'base_rate_per_km',
                              'waiting_grace_minutes', 'waiting_rate_per_min']
            for field in transport_fields:
                if field in request.data:
                    setattr(transport, field, request.data[field])
            transport.save()

        elif role == 'buyer' and hasattr(user, 'buyer_profile'):
            buyer = user.buyer_profile
            buyer_fields = ['delivery_address', 'delivery_instructions', 'bank_account']
            for field in buyer_fields:
                if field in request.data:
                    setattr(buyer, field, request.data[field])
            buyer.save()

        elif role == 'retailer' and hasattr(user, 'retailer_profile'):
            retailer = user.retailer_profile
            retailer_fields = ['business_name', 'owner_full_name', 'business_phone',
                             'business_email', 'business_address', 'business_type',
                             'kra_pin', 'bank_account', 'business_registration_number',
                             'latitude', 'longitude']
            for field in retailer_fields:
                if field in request.data:
                    setattr(retailer, field, request.data[field])
            retailer.save()

        if update_fields:
            user.save(update_fields=update_fields)

        return Response(self.get_serializer(user).data)

    def delete(self, request, *args, **kwargs):
        """
        Soft-delete the account (sets is_active=False) instead of hard delete.
        Hard delete still available via admin.
        """
        user = self.get_object()
        user.is_active = False
        user.account_status = AccountStatus.BANNED
        user.save(update_fields=['is_active', 'account_status'])
        return Response({'message': 'Account deactivated successfully.'}, status=status.HTTP_204_NO_CONTENT)


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


# ────────────────────────────────────────────────────────────────
# VERIFICATION DOCUMENTS
# ────────────────────────────────────────────────────────────────

class VerificationDocumentListCreateView(generics.ListCreateAPIView):
    """
    List user's verification documents or upload a new one.
    Admin sees all documents.
    """
    serializer_class = VerificationDocumentSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return VerificationDocument.objects.all().order_by('-created_at')
        return VerificationDocument.objects.filter(user=user).order_by('-created_at')

    def perform_create(self, serializer):
        # Set the user and default status
        document = serializer.save(user=self.request.user, status='submitted')

        # If this is the first document uploaded, update user's KYC status
        user = self.request.user
        if user.kyc_status == KycStatus.PENDING and not VerificationDocument.objects.filter(user=user).exists():
            # Keep as pending, but we could add a log entry here
            pass

        return document


class VerificationDocumentDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Retrieve, update, or delete a verification document.
    Users can only manage their own documents; admins can manage all.
    """
    serializer_class = VerificationDocumentSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]
    lookup_field = 'uuid'

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return VerificationDocument.objects.all()
        return VerificationDocument.objects.filter(user=user)

    def perform_update(self, serializer):
        # Only allow certain fields to be updated by the user (not status)
        # Admin updates status through review endpoint
        user = self.request.user
        if not user.is_staff:
            # Users can only update file, document_type, etc. Not status
            serializer.save()
        else:
            serializer.save()


class VerificationDocumentReviewView(generics.GenericAPIView):
    """
    Admin endpoint to review and approve/reject verification documents.
    Updates document status and cascades to user's KYC status.
    """
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    serializer_class = VerificationReviewSerializer

    def post(self, request, uuid):
        document = get_object_or_404(VerificationDocument, uuid=uuid)
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        new_status = serializer.validated_data['status']
        notes = serializer.validated_data.get('notes', '')

        # Update document
        document.status = new_status
        document.notes = notes
        document.reviewed_by = request.user
        document.reviewed_at = timezone.now()
        document.save()

        # Cascade to user's KYC status
        user = document.user
        if new_status == 'approved':
            # Check if all required documents are approved
            all_docs = VerificationDocument.objects.filter(user=user)
            pending_or_rejected = all_docs.exclude(status='approved').exists()
            if not pending_or_rejected:
                user.kyc_status = KycStatus.APPROVED
                # Also update account status to verified if pending
                if user.account_status == AccountStatus.PENDING:
                    user.account_status = AccountStatus.VERIFIED
                user.save(update_fields=['kyc_status', 'account_status'])
        elif new_status == 'rejected':
            user.kyc_status = KycStatus.REJECTED
            user.save(update_fields=['kyc_status'])

        return Response(VerificationDocumentSerializer(document).data, status=status.HTTP_200_OK)


# ────────────────────────────────────────────────────────────────
# TRUST SCORE
# ────────────────────────────────────────────────────────────────

class TrustScoreDetailView(generics.RetrieveAPIView):
    """
    Retrieve a user's trust score.
    Admin can view any user's score; regular users can only view their own.
    """
    serializer_class = TrustScoreSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'uuid'

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return TrustScore.objects.all()
        return TrustScore.objects.filter(user=user)

    def get_object(self):
        """
        If the user is requesting their own score and no trust score exists,
        create one with default values (score 0, band 'fair').
        """
        queryset = self.get_queryset()
        user = self.request.user

        if not user.is_staff:
            # Try to get existing score
            try:
                return queryset.get(user=user)
            except TrustScore.DoesNotExist:
                # Create a default trust score
                trust_score = TrustScore.objects.create(
                    user=user,
                    score=0,
                    score_band='fair',
                    reason='New user. No activity yet.'
                )
                return trust_score

        # For admin, use the UUID lookup
        return super().get_object()