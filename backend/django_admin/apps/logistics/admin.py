# backend/django_admin/apps/logistics/admin.py
from django.contrib import admin
from .models import Trip

@admin.register(Trip)
class TripAdmin(admin.ModelAdmin):
    list_display = ('id', 'order', 'provider', 'status', 'accepted_at', 'picked_up_at', 'delivered_at')
    list_filter = ('status', 'created_at')
    search_fields = ('order__id', 'provider__user__phone', 'pickup_address')
    readonly_fields = ('uuid', 'created_at', 'updated_at', 'otp_code', 'otp_expires_at', 'distance_km', 'eta_minutes')
    fieldsets = (
        (None, {'fields': ('order', 'provider', 'status')}),
        ('Timing', {'fields': ('accepted_at', 'arrived_at_farm', 'picked_up_at', 'delivered_at')}),
        ('Location', {'fields': ('pickup_address', 'pickup_lat', 'pickup_lng', 'delivery_lat', 'delivery_lng')}),
        ('Distance & ETA', {'fields': ('distance_km', 'eta_minutes')}),
        ('Photos', {'fields': ('pickup_photo', 'delivery_photo')}),
        ('Fees', {'fields': ('agreed_fee', 'waiting_surcharge')}),
        ('OTP', {'fields': ('otp_code', 'otp_expires_at', 'otp_attempts')}),
        ('System', {'fields': ('uuid', 'created_at', 'updated_at')}),
    )