# backend/django_admin/apps/paybill/admin.py
from django.contrib import admin
from django.urls import reverse
from django.utils.html import format_html

from apps.paybill.models import (
    PayBillTransaction,
    MpesaCallback,
    FloatAdjustment,
    AccountNumberReservation,
    PayBillSettlement,
    PaymentAllocation,
)


class PaymentAllocationInline(admin.TabularInline):
    model = PaymentAllocation
    extra = 0
    readonly_fields = ('amount', 'allocation_type', 'order')
    can_delete = False


@admin.register(PayBillTransaction)
class PayBillTransactionAdmin(admin.ModelAdmin):
    list_display = (
        'transaction_code', 'amount', 'account_number',
        'status', 'matched_order_link', 'created_at',
    )
    list_filter = ('status', 'created_at', 'transaction_type')
    search_fields = ('transaction_code', 'account_number', 'sender_phone')
    readonly_fields = (
        'id', 'uuid', 'transaction_code', 'amount', 'account_number',
        'sender_phone', 'transaction_time', 'status', 'matched_order_link',
        'payer_first_name', 'payer_middle_name', 'payer_last_name',
        'business_shortcode', 'transaction_type', 'currency',
        'running_balance', 'notes', 'created_at', 'updated_at',
    )
    inlines = [PaymentAllocationInline]
    actions = ['mark_as_matched', 'mark_as_completed']

    def matched_order_link(self, obj):
        if obj.matched_order:
            url = reverse('admin:orders_order_change', args=[obj.matched_order.id])
            return format_html('<a href="{}">Order #{}</a>', url, obj.matched_order.id)
        return '-'
    matched_order_link.short_description = 'Matched Order'

    def mark_as_matched(self, request, queryset):
        queryset.update(status='matched')
    mark_as_matched.short_description = 'Mark selected as Matched'

    def mark_as_completed(self, request, queryset):
        queryset.update(status='completed')
    mark_as_completed.short_description = 'Mark selected as Completed'


@admin.register(MpesaCallback)
class MpesaCallbackAdmin(admin.ModelAdmin):
    list_display = ('transaction_code', 'order_id', 'is_processed', 'processed_at', 'processing_attempts')
    list_filter = ('is_processed',)
    search_fields = ('transaction_code',)
    readonly_fields = ('transaction_code', 'order_id', 'processed_at', 'callback_payload', 'is_processed', 'processing_attempts')


@admin.register(FloatAdjustment)
class FloatAdjustmentAdmin(admin.ModelAdmin):
    list_display = ('adjustment_type', 'amount', 'running_balance', 'source', 'initiated_by', 'created_at')
    list_filter = ('adjustment_type', 'source', 'created_at')
    search_fields = ('reason', 'reference_transaction')
    readonly_fields = ('id', 'uuid', 'adjustment_type', 'amount', 'running_balance',
                       'reason', 'initiated_by', 'source', 'reference_transaction', 'created_at')


@admin.register(AccountNumberReservation)
class AccountNumberReservationAdmin(admin.ModelAdmin):
    list_display = ('account_number', 'prefix', 'related_object_type', 'related_object_id', 'is_used', 'used_at')
    list_filter = ('prefix', 'is_used', 'created_at')
    search_fields = ('account_number',)
    readonly_fields = ('account_number', 'prefix', 'related_object_id',
                       'related_object_type', 'expires_at', 'is_used', 'used_at', 'reserved_by')


@admin.register(PayBillSettlement)
class PayBillSettlementAdmin(admin.ModelAdmin):
    list_display = ('settlement_date', 'amount', 'status', 'reference')
    list_filter = ('status', 'settlement_date')
    search_fields = ('reference',)
    readonly_fields = ('id', 'uuid', 'settlement_date', 'amount', 'reference', 'status',
                       'bank_account', 'initiated_at', 'completed_at', 'created_at')


@admin.register(PaymentAllocation)
class PaymentAllocationAdmin(admin.ModelAdmin):
    list_display = ('transaction', 'order', 'amount', 'allocation_type')
    list_filter = ('allocation_type',)
    search_fields = ('transaction__transaction_code', 'order__id')
    readonly_fields = ('id', 'uuid', 'transaction', 'order', 'amount', 'allocation_type', 'created_at')