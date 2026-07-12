# backend/django_admin/apps/analytics/views/api.py
from datetime import date, timedelta

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import generics, permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.users.permissions import IsAdmin

from ..models import AnalyticsExportJob, DailyMetric
from ..serializers import (
    AnalyticsExportJobSerializer,
    DailyMetricSerializer,
)
from ..services.reports import (
    get_payments_metrics,
    get_summary_report,
    get_top_farmers,
    get_top_transport_providers,
)


# =============================================================================
# DAILY METRICS
# =============================================================================

class DailyMetricViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Read-only analytics metrics.
    Admin only.
    """

    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    serializer_class = DailyMetricSerializer
    queryset = DailyMetric.objects.order_by("-date")

    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["date"]

    @action(detail=False, methods=["post"], url_path="recompute")
    def recompute(self, request):
        """
        Trigger background metrics aggregation.
        """

        start = request.data.get("start_date", date.today().isoformat())
        end = request.data.get("end_date", date.today().isoformat())

        start_date = date.fromisoformat(start)
        end_date = date.fromisoformat(end)

        from ..tasks import aggregate_metrics_for_range

        aggregate_metrics_for_range.delay(
            start_date.isoformat(),
            end_date.isoformat(),
        )

        return Response(
            {"message": "Aggregation started"},
            status=status.HTTP_202_ACCEPTED,
        )

    @action(detail=False, methods=["get"])
    def summary(self, request):
        """
        KPI summary.
        """

        start = request.query_params.get(
            "start_date",
            (date.today() - timedelta(days=30)).isoformat(),
        )

        end = request.query_params.get(
            "end_date",
            date.today().isoformat(),
        )

        report = get_summary_report(
            date.fromisoformat(start),
            date.fromisoformat(end),
        )

        return Response(report)

    @action(detail=False, methods=["get"])
    def payments(self, request):
        """
        Payment analytics.
        """

        start = request.query_params.get(
            "start_date",
            (date.today() - timedelta(days=30)).isoformat(),
        )

        end = request.query_params.get(
            "end_date",
            date.today().isoformat(),
        )

        data = get_payments_metrics(
            date.fromisoformat(start),
            date.fromisoformat(end),
        )

        return Response(data)

    @action(detail=False, methods=["get"], url_path="top-farmers")
    def top_farmers(self, request):
        """
        Best performing farmers.
        """

        limit = int(request.query_params.get("limit", 10))
        days = int(request.query_params.get("days", 30))

        return Response(get_top_farmers(limit, days))

    @action(detail=False, methods=["get"], url_path="top-transport")
    def top_transport(self, request):
        """
        Best performing transport providers.
        """

        limit = int(request.query_params.get("limit", 10))
        days = int(request.query_params.get("days", 30))

        return Response(get_top_transport_providers(limit, days))


# =============================================================================
# ANALYTICS EXPORT JOBS
# =============================================================================

class AnalyticsExportJobListCreateView(generics.ListCreateAPIView):
    """
    List export jobs and create a new export request.
    """

    serializer_class = AnalyticsExportJobSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    queryset = AnalyticsExportJob.objects.order_by("-created_at")

    def perform_create(self, serializer):
        serializer.save(
            requested_by=self.request.user,
        )


class AnalyticsExportJobDetailView(generics.RetrieveAPIView):
    """
    Retrieve a single export job.
    """

    serializer_class = AnalyticsExportJobSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    lookup_field = "uuid"
    queryset = AnalyticsExportJob.objects.order_by("-created_at")
