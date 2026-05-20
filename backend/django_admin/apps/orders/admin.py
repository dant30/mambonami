# backend/django_admin/apps/orders/admin.py
from django.contrib import admin
from .models import Order, SubOrder, OrderItem

class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields = ('product', 'quantity', 'unit_price', 'total_price')

class SubOrderInline(admin.TabularInline):
    model = SubOrder
    extra = 0
    readonly_fields = ('farmer', 'status', 'subtotal', 'confirmed_at', 'ready_at')
    inlines = [OrderItemInline]

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'buyer', 'total_amount', 'status', 'account_number', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('id', 'buyer__phone', 'account_number')
    readonly_fields = ('id', 'uuid', 'account_number', 'created_at', 'updated_at')
    inlines = [SubOrderInline]
    actions = ['mark_paid_manually']

    def mark_paid_manually(self, request, queryset):
        for order in queryset:
            if order.status == 'placed':
                order.status = 'paid_escrow'
                order.save()
    mark_paid_manually.short_description = "Mark selected orders as paid (escrow)"

@admin.register(SubOrder)
class SubOrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'order', 'farmer', 'status', 'subtotal')
    list_filter = ('status',)
    search_fields = ('order__id', 'farmer__user__phone')