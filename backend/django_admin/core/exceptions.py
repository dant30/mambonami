# core/exceptions.py
from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status
from django.core.exceptions import ValidationError

def custom_exception_handler(exc, context):
    """
    Override DRF's default exception handler to return consistent error responses.
    """
    response = exception_handler(exc, context)
    
    if response is None:
        # Handle Django ValidationError
        if isinstance(exc, ValidationError):
            return Response(
                {'detail': exc.messages[0] if exc.messages else 'Validation error'},
                status=status.HTTP_400_BAD_REQUEST
            )
        # Handle any other unhandled exception
        return Response(
            {'detail': 'Internal server error.'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    
    # Add request ID if available (set by middleware)
    request = context.get('request')
    if request and hasattr(request, 'request_id'):
        response.data['request_id'] = request.request_id
    
    return response


class EscrowError(Exception):
    """Base exception for escrow-related failures."""
    pass

class FloatInsufficientError(EscrowError):
    """Raised when PayBill float is below required amount."""
    pass

class IdempotencyError(EscrowError):
    """Raised when a duplicate IPN is detected."""
    pass

class PaymentVerificationError(EscrowError):
    """Raised when Safaricom IPN payload fails validation."""
    pass