# backend/django_admin/apps/disputes/admin.py
from django.contrib import admin
from .models import Dispute

@admin.register(Dispute)
class DisputeAdmin(admin.ModelAdmin):
    list_display = ('id', 'order', 'raised_by', 'reason', 'status', 'created_at')
    list_filter = ('status', 'reason', 'created_at')
    search_fields = ('order__id', 'raised_by__phone', 'description')
    readonly_fields = ('uuid', 'created_at', 'updated_at')
    actions = ['mark_under_review', 'resolve_selected']

    def mark_under_review(self, request, queryset):
        queryset.update(status='under_review')
    mark_under_review.short_description = "Mark as Under Review"

    def resolve_selected(self, request, queryset):
        # This is a placeholder; you'd need a custom form in real scenario
        self.message_user(request, "Please use the admin action form or API.")
    resolve_selected.short_description = "Resolve selected (use API)"