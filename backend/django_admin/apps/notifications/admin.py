# backend/django_admin/apps/notifications/admin.py
from django.contrib import admin
from .models import Notification, NotificationTemplate


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'channel', 'category', 'delivery_status', 'title', 'created_at')
    list_filter = ('channel', 'category', 'delivery_status', 'created_at', 'is_read')
    search_fields = ('user__phone', 'title', 'body')
    readonly_fields = ('uuid', 'created_at')
    actions = ['resend_failed']

    def resend_failed(self, request, queryset):
        from .tasks import send_notification_task
        for notif in queryset.filter(delivery_status=Notification.DeliveryStatus.FAILED):
            send_notification_task.delay(notif.id)
        self.message_user(request, f"Rescheduled {queryset.count()} failed notifications.")

    resend_failed.short_description = "Resend selected failed notifications"


@admin.register(NotificationTemplate)
class NotificationTemplateAdmin(admin.ModelAdmin):
    list_display = ('name', 'channel', 'is_active')
    list_filter = ('channel', 'is_active')
    search_fields = ('name',)