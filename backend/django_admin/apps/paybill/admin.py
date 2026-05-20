from django.contrib import admin

from apps.paybill.models import (
    PayBillTransaction,
    MpesaCallback,
    FloatAdjustment,
    AccountNumberReservation,
)


@admin.register(PayBillTransaction)
class PayBillTransactionAdmin(admin.ModelAdmin):
    list_display = (
        'id', 'transaction_code', 'amount', 'account_number',
        'status', 'matched_order_id', 'created_at',
    )
    list_filter = ('status', 'created_at')
    search_fields = ('transaction_code', 'account_number', 'sender_phone')
    readonly_fields = (
        'id', 'uuid', 'transaction_code', 'amount', 'account_number',
        'sender_phone', 'transaction_time', 'status', 'matched_order_id',
        'notes', 'created_at', 'updated_at',
    )
    actions = ['mark_as_matched']

    def mark_as_matched(self, request, queryset):
        queryset.update(status='matched')
    mark_as_matched.short_description = 'Mark selected transactions as matched'


@admin.register(MpesaCallback)
class MpesaCallbackAdmin(admin.ModelAdmin):
    list_display = ('transaction_code', 'order_id', 'processed_at')
    search_fields = ('transaction_code',)
    readonly_fields = ('transaction_code', 'order_id', 'processed_at', 'callback_payload')


@admin.register(FloatAdjustment)
class FloatAdjustmentAdmin(admin.ModelAdmin):
    list_display = (
        'adjustment_type', 'amount', 'running_balance',
        'initiated_by', 'created_at',
    )
    list_filter = ('adjustment_type',)
    readonly_fields = (
        'id', 'uuid', 'adjustment_type', 'amount', 'running_balance',
        'reason', 'initiated_by', 'reference_transaction', 'created_at', 'updated_at',
    )


@admin.register(AccountNumberReservation)
class AccountNumberReservationAdmin(admin.ModelAdmin):
    list_display = (
        'account_number', 'prefix', 'related_object_type',
        'related_object_id', 'is_used',
    )
    search_fields = ('account_number',)
    readonly_fields = (
        'account_number', 'prefix', 'related_object_id',
        'related_object_type', 'expires_at', 'is_used',
    )
