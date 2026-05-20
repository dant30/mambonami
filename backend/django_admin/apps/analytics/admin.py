# backend/django_admin/apps/analytics/admin.py
from django.contrib import admin
from .models import DailyMetric

@admin.register(DailyMetric)
class DailyMetricAdmin(admin.ModelAdmin):
    list_display = ('date', 'total_orders', 'completed_orders', 'total_sales', 'platform_commission')
    list_filter = ('date',)
    readonly_fields = [f.name for f in DailyMetric._meta.fields if f.name not in ('id',)]
    search_fields = ('date',)

    def has_add_permission(self, request):
        return False  # metrics are computed automatically

    def has_delete_permission(self, request, obj=None):
        return False