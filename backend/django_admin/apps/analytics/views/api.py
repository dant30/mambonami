# backend/django_admin/apps/analytics/views/api.py
from datetime import date, timedelta
import logging

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

logger = logging.getLogger(__name__)
MAX_RECOMPUTE_DAYS = 366
MAX_SYNCHRONOUS_RECOMPUTE_DAYS = 7


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
        try:
            start_date = date.fromisoformat(start)
            end_date = date.fromisoformat(end)
        except (TypeError, ValueError):
            return Response(
                {'detail': 'start_date and end_date must be valid ISO dates.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        day_count = (end_date - start_date).days + 1
        if day_count <= 0:
            return Response({'detail': 'end_date must be on or after start_date.'}, status=status.HTTP_400_BAD_REQUEST)
        if day_count > MAX_RECOMPUTE_DAYS:
            return Response(
                {'detail': f'Recompute ranges cannot exceed {MAX_RECOMPUTE_DAYS} days.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        from ..tasks import aggregate_metrics_for_range

        try:
            aggregate_metrics_for_range.delay(start_date.isoformat(), end_date.isoformat())
        except Exception:
            logger.exception('Unable to enqueue analytics recompute for %s through %s', start_date, end_date)
            if day_count > MAX_SYNCHRONOUS_RECOMPUTE_DAYS:
                return Response(
                    {'detail': 'The background task queue is unavailable; retry with a range of 7 days or less.'},
                    status=status.HTTP_503_SERVICE_UNAVAILABLE,
                )

            try:
                from ..services.aggregator import aggregate_range

                aggregate_range(start_date, end_date)
            except Exception:
                logger.exception('Synchronous analytics recompute failed for %s through %s', start_date, end_date)
                return Response(
                    {'detail': 'Analytics recomputation failed. Check the Django application logs.'},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

            return Response(
                {'message': 'Aggregation completed synchronously because the background queue is unavailable.'},
                status=status.HTTP_200_OK,
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
