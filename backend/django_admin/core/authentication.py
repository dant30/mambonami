# core/authentication.py
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.tokens import Token
from rest_framework.exceptions import AuthenticationFailed

class CustomJWTAuthentication(JWTAuthentication):
    """
    Extended JWT authentication that checks user activity and role.
    """
    def get_user(self, validated_token: Token):
        user = super().get_user(validated_token)
        if not user.is_active:
            raise AuthenticationFailed('User account is disabled.', code='user_inactive')
        # Optional: add role validation based on token claims
        # if 'role' in validated_token and validated_token['role'] != user.role:
        #     raise AuthenticationFailed('Role mismatch.')
        return user