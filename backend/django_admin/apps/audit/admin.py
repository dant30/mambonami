# backend/django_admin/apps/audit/admin.py
from django.contrib import admin
from .models import AuditLog

@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    list_display = ('timestamp', 'user', 'action', 'model_name', 'object_id', 'request_id')
    list_filter = ('action', 'model_name', 'timestamp')
    search_fields = ('user__phone', 'object_id', 'object_repr', 'request_id')
    readonly_fields = ('id', 'uuid', 'timestamp', 'user', 'action', 'model_name', 'object_id', 'object_repr', 'changes', 'user_ip', 'user_agent', 'request_id', 'endpoint')
    list_select_related = ('user',)
    date_hierarchy = 'timestamp'

    def has_add_permission(self, request):
        return False  # prevent manual creation

    def has_change_permission(self, request, obj=None):
        return False  # prevent updates

    def has_delete_permission(self, request, obj=None):
        return False  # prevent deletions