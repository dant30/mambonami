# django_admin/apps/users/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, FarmerProfile, TransportProviderProfile, BuyerProfile, RetailerProfile


class FarmerProfileInline(admin.StackedInline):
    model = FarmerProfile
    can_delete = False
    verbose_name_plural = 'Farmer Profile'


class TransportProfileInline(admin.StackedInline):
    model = TransportProviderProfile
    can_delete = False
    verbose_name_plural = 'Transport Provider Profile'


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
    list_display = ('phone', 'username', 'role', 'is_phone_verified', 'is_staff', 'is_active')
    list_filter = ('role', 'is_phone_verified', 'is_staff', 'is_active')
    search_fields = ('phone', 'username', 'email')
    ordering = ('-date_joined',)
    fieldsets = UserAdmin.fieldsets + (
        ('MAMBONAMI Info', {'fields': ('role', 'phone', 'is_phone_verified')}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('MAMBONAMI Info', {'fields': ('role', 'phone')}),
    )
    inlines = [FarmerProfileInline, TransportProfileInline, BuyerProfileInline, RetailerProfileInline]


@admin.register(FarmerProfile)
class FarmerProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'coop_verified', 'total_sales')
    list_filter = ('coop_verified',)
    search_fields = ('user__phone', 'user__username')
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
    fieldsets = (
        ('Provider Info', {
            'fields': ('user', 'vehicle_type', 'license_plate', 'driver_license')
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
            'fields': ('deposit_paid', 'is_approved')
        }),
        ('Performance', {
            'fields': ('rating', 'total_deliveries'),
            'classes': ('collapse',)
        }),
    )
    readonly_fields = ('rating', 'total_deliveries')
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
