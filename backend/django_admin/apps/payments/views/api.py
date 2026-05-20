# backend/django_admin/apps/payments/views/api.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser

class PaymentHealthView(APIView):
    """Simple health check for payments app (future use)."""
    permission_classes = [IsAdminUser]

    def get(self, request):
        return Response({"status": "payments app placeholder", "active": False})