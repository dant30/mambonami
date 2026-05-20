# backend/django_admin/apps/payouts/admin.py
from django.contrib import admin
from .models import Payout

@admin.register(Payout)
class PayoutAdmin(admin.ModelAdmin):
    list_display = ('id', 'order', 'recipient_type', 'recipient_user', 'amount', 'status', 'created_at')
    list_filter = ('status', 'recipient_type', 'created_at')
    search_fields = ('order__id', 'recipient_user__phone', 'b2c_transaction_id')
    readonly_fields = ('uuid', 'created_at', 'updated_at', 'b2c_transaction_id')
    actions = ['retry_failed_payouts']

    def retry_failed_payouts(self, request, queryset):
        from .tasks import retry_payout
        for payout in queryset.filter(status='failed'):
            retry_payout.delay(payout.id)
        self.message_user(request, f"Scheduled retry for {queryset.count()} payouts")
    retry_failed_payouts.short_description = "Retry selected failed payouts"