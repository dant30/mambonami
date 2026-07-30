# backend/django_admin/apps/logistics/admin.py
from django.contrib import admin
from django.utils import timezone
from django.utils.html import format_html
from .models import Trip, TripStatusHistory, TripLocationPing, TripMedia, TripStatus


class TripStatusHistoryInline(admin.TabularInline):
    model = TripStatusHistory
    extra = 0
    readonly_fields = ('status', 'changed_at', 'location_lat', 'location_lng', 'actor', 'source', 'note')
    fields = ('status', 'changed_at', 'location_lat', 'location_lng', 'actor', 'source', 'note')
    can_delete = False
    max_num = 0


class TripLocationPingInline(admin.TabularInline):
    model = TripLocationPing
    extra = 0
    readonly_fields = ('latitude', 'longitude', 'speed_kmh', 'accuracy_m', 'timestamp')
    fields = ('latitude', 'longitude', 'speed_kmh', 'accuracy_m', 'timestamp')
    can_delete = False
    max_num = 10
    ordering = ('-timestamp',)


class TripMediaInline(admin.TabularInline):
    model = TripMedia
    extra = 0
    readonly_fields = ('media_type', 'image_preview', 'uploaded_by', 'uploaded_at', 'is_verified')
    fields = ('media_type', 'image_preview', 'uploaded_by', 'uploaded_at', 'is_verified')
    can_delete = False
    max_num = 10

    def image_preview(self, obj):
        if obj.image:
            return format_html('<img src="{}" style="max-height:100px; max-width:100px;" />', obj.image.url)
        return '-'
    image_preview.short_description = 'Preview'


@admin.register(Trip)
class TripAdmin(admin.ModelAdmin):
    list_display = (
        'id', 'order', 'provider', 'status_badge', 'accepted_at', 
        'picked_up_at', 'arrived_delivery_at', 'completed_at'
    )
    list_filter = ('status', 'created_at', 'vehicle_type')
    search_fields = ('order__id', 'order__buyer__phone', 'provider__user__phone', 'pickup_address')
    readonly_fields = (
        'uuid', 'created_at', 'updated_at', 'created_at_trip', 
        'offered_at', 'accepted_at', 'picked_up_at', 'completed_at',
        'otp_hash', 'otp_expires_at', 'otp_attempts',
        'straight_line_km', 'eta_minutes'
    )
    inlines = [
        TripStatusHistoryInline,
        TripLocationPingInline,
        TripMediaInline,
    ]
    fieldsets = (
        ('Order & Provider', {
            'fields': ('order', 'provider', 'status', 'assigned_by')
        }),
        ('Vehicle Snapshot', {
            'fields': ('vehicle_type', 'vehicle_plate', 'vehicle_make', 'vehicle_model')
        }),
        ('Location', {
            'fields': (
                'pickup_address', 'pickup_lat', 'pickup_lng',
                'delivery_address', 'delivery_lat', 'delivery_lng',
                'current_lat', 'current_lng'
            )
        }),
        ('Route & Distance', {
            'fields': ('straight_line_km', 'road_km', 'eta_minutes')
        }),
        ('Fees', {
            'fields': (
                'base_fee', 'distance_fee', 'weight_fee', 
                'waiting_fee', 'surge_fee', 'agreed_fee', 'waiting_surcharge',
                'commission', 'provider_payout', 'platform_fee', 'buyer_total'
            )
        }),
        ('Timestamps', {
            'fields': (
                'created_at_trip', 'offered_at', 'accepted_at',
                'started_navigation_pickup', 'arrived_pickup_at', 'picked_up_at',
                'left_pickup_at', 'started_navigation_delivery', 'arrived_delivery_at',
                'otp_verified_at', 'completed_at', 'cancelled_at', 'failed_at'
            )
        }),
        ('OTP', {
            'fields': ('otp_hash', 'otp_expires_at', 'otp_attempts')
        }),
        ('Ratings', {
            'fields': ('buyer_rating', 'provider_rating')
        }),
        ('Cancellation / Failure', {
            'fields': ('cancel_reason', 'cancelled_by', 'failure_reason')
        }),
        ('Audit', {
            'fields': ('accepted_device', 'completed_device', 'ip_address', 'delivery_notes')
        }),
        ('System', {
            'fields': ('uuid', 'created_at', 'updated_at')
        }),
    )

    def status_badge(self, obj):
        status_colors = {
            TripStatus.OFFERED: '#f59e0b',
            TripStatus.ACCEPTED: '#3b82f6',
            TripStatus.EN_ROUTE_PICKUP: '#8b5cf6',
            TripStatus.ARRIVED_PICKUP: '#06b6d4',
            TripStatus.PICKED_UP: '#10b981',
            TripStatus.EN_ROUTE_DELIVERY: '#f472b6',
            TripStatus.ARRIVED_DELIVERY: '#f97316',
            TripStatus.OTP_PENDING: '#8b5cf6',
            TripStatus.DELIVERED: '#22c55e',
            TripStatus.CANCELLED: '#ef4444',
            TripStatus.FAILED: '#dc2626',
            TripStatus.DISPUTED: '#eab308',
        }
        color = status_colors.get(obj.status, '#6b7280')
        return format_html(
            '<span style="background:{}; color:white; padding:2px 8px; border-radius:12px; font-size:11px;">{}</span>',
            color, obj.status.replace('_', ' ').title()
        )
    status_badge.short_description = 'Status'

    actions = ['mark_as_disputed', 'mark_as_delivered']

    def mark_as_disputed(self, request, queryset):
        queryset.update(status=TripStatus.DISPUTED)
    mark_as_disputed.short_description = 'Mark selected as Disputed'

    def mark_as_delivered(self, request, queryset):
        now = timezone.now()
        for trip in queryset:
            if trip.status != TripStatus.DELIVERED:
                trip.status = TripStatus.DELIVERED
                trip.completed_at = now
                trip.save(update_fields=['status', 'completed_at'])
    mark_as_delivered.short_description = 'Mark selected as Delivered'


@admin.register(TripStatusHistory)
class TripStatusHistoryAdmin(admin.ModelAdmin):
    list_display = ('trip', 'status', 'changed_at', 'actor', 'source')
    list_filter = ('status', 'source')
    search_fields = ('trip__id', 'trip__order__id', 'note')
    readonly_fields = ('trip', 'status', 'changed_at', 'location_lat', 'location_lng', 'actor', 'source', 'note')
    date_hierarchy = 'changed_at'

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False


@admin.register(TripLocationPing)
class TripLocationPingAdmin(admin.ModelAdmin):
    list_display = ('trip', 'latitude', 'longitude', 'speed_kmh', 'timestamp')
    list_filter = ('trip__status',)
    search_fields = ('trip__id',)
    readonly_fields = ('trip', 'latitude', 'longitude', 'heading', 'speed_kmh', 'accuracy_m', 'timestamp')
    date_hierarchy = 'timestamp'

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False


@admin.register(TripMedia)
class TripMediaAdmin(admin.ModelAdmin):
    list_display = ('trip', 'media_type', 'image_preview', 'uploaded_by', 'uploaded_at', 'is_verified')
    list_filter = ('media_type', 'is_verified')
    search_fields = ('trip__id', 'caption')
    readonly_fields = ('trip', 'media_type', 'image', 'uploaded_by', 'uploaded_at', 'latitude', 'longitude')

    def image_preview(self, obj):
        if obj.image:
            return format_html('<img src="{}" style="max-height:50px; max-width:50px;" />', obj.image.url)
        return '-'
    image_preview.short_description = 'Preview'

    actions = ['mark_verified']

    def mark_verified(self, request, queryset):
        queryset.update(is_verified=True)
    mark_verified.short_description = 'Mark selected as Verified'