# backend/django_admin/apps/logistics/admin.py
from django.contrib import admin
from .models import Trip

@admin.register(Trip)
class TripAdmin(admin.ModelAdmin):
    list_display = ('id', 'order', 'provider', 'status', 'picked_up_at', 'delivered_at')
    list_filter = ('status', 'created_at')
    search_fields = ('order__id', 'provider__user__phone')
    readonly_fields = ('uuid', 'created_at', 'updated_at', 'otp_code', 'otp_expires_at')
    fieldsets = (
        (None, {'fields': ('order', 'provider', 'status')}),
        ('Location', {'fields': ('pickup_lat', 'pickup_lng', 'delivery_lat', 'delivery_lng')}),
        ('Photos', {'fields': ('pickup_photo', 'delivery_photo')}),
        ('Timestamps', {'fields': ('picked_up_at', 'delivered_at')}),
        ('OTP', {'fields': ('otp_code', 'otp_expires_at', 'otp_attempts')}),
        ('System', {'fields': ('uuid', 'created_at', 'updated_at')}),
    )