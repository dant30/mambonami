# core/middleware.py
import uuid
import time
from django.http import JsonResponse, Http404
from django.utils.deprecation import MiddlewareMixin
from django.core.exceptions import PermissionDenied
from rest_framework.exceptions import APIException
from core.logging import get_logger

logger = get_logger('middleware')

class RequestIDMiddleware(MiddlewareMixin):
    """Add a unique request ID to every request and log it."""
    def process_request(self, request):
        request_id = request.headers.get('X-Request-ID', str(uuid.uuid4()))
        request.request_id = request_id
        
    def process_response(self, request, response):
        if hasattr(request, 'request_id'):
            response['X-Request-ID'] = request.request_id
        return response


class ExceptionHandlingMiddleware(MiddlewareMixin):
    """Catch unhandled exceptions and return a generic JSON response."""
    def process_exception(self, request, exception):
        if isinstance(exception, (Http404, PermissionDenied, APIException)):
            return None

        logger.exception(
            'Unhandled exception caught by middleware',
            extra={'request_id': getattr(request, 'request_id', None)}
        )
        return JsonResponse(
            {'detail': 'An internal server error occurred.'},
            status=500
        )


class PerformanceLoggingMiddleware(MiddlewareMixin):
    """Log the duration of each request."""
    def process_request(self, request):
        request._start_time = time.time()
    
    def process_response(self, request, response):
        if hasattr(request, '_start_time'):
            duration = time.time() - request._start_time
            logger.info(
                f"{request.method} {request.path} completed in {duration:.3f}s",
                extra={'request_id': getattr(request, 'request_id', None)}
            )
        return response


class CurrentUserMiddleware:
    """Expose the authenticated user to signal handlers via request._current_user."""
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if getattr(request, 'user', None) is not None and request.user.is_authenticated:
            setattr(request, '_current_user', request.user)
        response = self.get_response(request)
        return response