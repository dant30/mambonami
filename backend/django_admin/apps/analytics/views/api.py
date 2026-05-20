# backend/django_admin/apps/analytics/views/api.py
from datetime import date, timedelta
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from ..models import DailyMetric
from ..serializers import DailyMetricSerializer
from ..services.reports import (
    get_summary_report,
    get_top_farmers,
    get_top_transport_providers,
    get_payments_metrics,
)
from apps.users.permissions import IsAdmin


class DailyMetricViewSet(viewsets.ReadOnlyModelViewSet):
    """Admin-only readonly API for daily metrics."""
    permission_classes = [IsAdmin]
    serializer_class = DailyMetricSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['date']
    queryset = DailyMetric.objects.all().order_by('-date')

    @action(detail=False, methods=['post'], url_path='recompute')
    def recompute(self, request):
        start = request.data.get('start_date', date.today().isoformat())
        end = request.data.get('end_date', date.today().isoformat())
        start_date = date.fromisoformat(start)
        end_date = date.fromisoformat(end)
        from ..tasks import aggregate_metrics_for_range
        aggregate_metrics_for_range.delay(start_date.isoformat(), end_date.isoformat())
        return Response({"message": "Aggregation started"}, status=202)

    @action(detail=False, methods=['get'], url_path='summary')
    def summary(self, request):
        start = request.query_params.get('start_date', (date.today() - timedelta(days=30)).isoformat())
        end = request.query_params.get('end_date', date.today().isoformat())
        start_date = date.fromisoformat(start)
        end_date = date.fromisoformat(end)
        report = get_summary_report(start_date, end_date)
        return Response(report)

    @action(detail=False, methods=['get'], url_path='payments')
    def payments(self, request):
        start = request.query_params.get('start_date', (date.today() - timedelta(days=30)).isoformat())
        end = request.query_params.get('end_date', date.today().isoformat())
        start_date = date.fromisoformat(start)
        end_date = date.fromisoformat(end)
        data = get_payments_metrics(start_date, end_date)
        return Response(data)

    @action(detail=False, methods=['get'], url_path='top-farmers')
    def top_farmers(self, request):
        limit = int(request.query_params.get('limit', 10))
        days = int(request.query_params.get('days', 30))
        data = get_top_farmers(limit, days)
        return Response(data)

    @action(detail=False, methods=['get'], url_path='top-transport')
    def top_transport(self, request):
        limit = int(request.query_params.get('limit', 10))
        days = int(request.query_params.get('days', 30))
        data = get_top_transport_providers(limit, days)
        return Response(data)
