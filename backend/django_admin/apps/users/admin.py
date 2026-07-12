# backend/django_admin/apps/users/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .models import (
    BuyerProfile,
    FarmerProfile,
    RetailerProfile,
    TransportProviderProfile,
    User,
)


class FarmerProfileInline(admin.StackedInline):
    model = FarmerProfile
    can_delete = False
    verbose_name_plural = 'Farmer Profile'
    fields = (
        'latitude', 'longitude', 'county', 'sub_county', 'ward', 'village',
        'cooperative', 'coop_verified', 'bank_account', 'mpesa_number',
        'total_sales', 'rating', 'rating_count', 'total_orders',
    )
    readonly_fields = ('total_sales', 'rating', 'rating_count', 'total_orders')


class TransportProfileInline(admin.StackedInline):
    model = TransportProviderProfile
    can_delete = False
    verbose_name_plural = 'Transport Provider Profile'
    fields = (
        'vehicle_type', 'capacity_kg', 'license_plate', 'driver_license',
        'bank_account', 'deposit_paid', 'deposit_transaction_id', 'is_approved',
        'base_rate_per_km', 'waiting_grace_minutes', 'waiting_rate_per_min',
        'rating', 'rating_count', 'total_deliveries', 'current_latitude',
        'current_longitude', 'is_online', 'available',
    )
    readonly_fields = ('rating', 'rating_count', 'total_deliveries')


class BuyerProfileInline(admin.StackedInline):
    model = BuyerProfile
    can_delete = False
    verbose_name_plural = 'Buyer Profile'


class RetailerProfileInline(admin.StackedInline):
    model = RetailerProfile
    can_delete = False
    verbose_name_plural = 'Retailer Profile'


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    list_display = (
        'phone', 'username', 'email', 'role', 'is_phone_verified',
        'is_staff', 'is_active', 'account_status', 'kyc_status',
    )
    list_filter = (
        'role', 'is_phone_verified', 'is_staff', 'is_active',
        'account_status', 'kyc_status',
    )
    search_fields = ('phone', 'username', 'email', 'middle_name', 'national_id')
    ordering = ('-date_joined',)
    fieldsets = UserAdmin.fieldsets + (
        ('MAMBONAMI Info', {'fields': (
            'role', 'phone', 'is_phone_verified', 'is_email_verified',
            'account_status', 'kyc_status', 'middle_name', 'national_id', 'avatar'
        )}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('MAMBONAMI Info', {'fields': ('role', 'phone')}),
    )
    inlines = [FarmerProfileInline, TransportProfileInline, BuyerProfileInline, RetailerProfileInline]


@admin.register(FarmerProfile)
class FarmerProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'coop_verified', 'rating', 'total_sales', 'total_orders')
    list_filter = ('coop_verified',)
    search_fields = ('user__phone', 'user__username')
    readonly_fields = ('rating', 'total_sales', 'total_orders')
    fieldsets = (
        (None, {'fields': ('user', 'latitude', 'longitude', 'county', 'sub_county', 'ward', 'village', 'cooperative', 'coop_verified')}),
        ('Financial', {'fields': ('bank_account', 'mpesa_number', 'total_sales')}),
        ('Performance', {'fields': ('rating', 'rating_count', 'total_orders')}),
    )
    actions = ['approve_coop']

    def approve_coop(self, request, queryset):
        queryset.update(coop_verified=True)

    approve_coop.short_description = 'Mark cooperative as verified'


@admin.register(TransportProviderProfile)
class TransportProviderProfileAdmin(admin.ModelAdmin):
    list_display = (
        'user', 'vehicle_type', 'capacity_kg', 'base_rate_per_km',
        'deposit_paid', 'is_approved', 'rating'
    )
    list_filter = ('vehicle_type', 'deposit_paid', 'is_approved')
    search_fields = ('user__phone', 'license_plate')
    readonly_fields = ('rating', 'rating_count', 'total_deliveries')
    fieldsets = (
        ('Provider Info', {
            'fields': ('user', 'vehicle_type', 'license_plate', 'driver_license', 'bank_account')
        }),
        ('Capacity', {
            'fields': ('capacity_kg',),
        }),
        ('Dynamic Pricing', {
            'fields': (
                'base_rate_per_km', 'waiting_grace_minutes', 'waiting_rate_per_min'
            ),
            'description': 'Configure provider-specific delivery fee parameters'
        }),
        ('Status', {
            'fields': ('deposit_paid', 'deposit_transaction_id', 'is_approved')
        }),
        ('Location', {
            'fields': ('current_latitude', 'current_longitude', 'is_online', 'available')
        }),
        ('Performance', {
            'fields': ('rating', 'rating_count', 'total_deliveries'),
            'classes': ('collapse',)
        }),
    )
    actions = ['approve_provider', 'reset_rates_to_defaults']

    def approve_provider(self, request, queryset):
        queryset.update(is_approved=True)

    approve_provider.short_description = 'Approve transport providers'

    def reset_rates_to_defaults(self, request, queryset):
        """Reset provider rates to vehicle type defaults."""
        from apps.logistics.services.fee_calculator import get_default_rates_for_vehicle_type

        for provider in queryset:
            defaults = get_default_rates_for_vehicle_type(provider.vehicle_type)
            provider.base_rate_per_km = defaults['base_rate_per_km']
            provider.waiting_grace_minutes = defaults['waiting_grace_minutes']
            provider.waiting_rate_per_min = defaults['waiting_rate_per_min']
            provider.save()

    reset_rates_to_defaults.short_description = 'Reset rates to vehicle type defaults'