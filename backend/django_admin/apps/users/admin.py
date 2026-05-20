# django_admin/apps/users/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, FarmerProfile, TransportProviderProfile


class FarmerProfileInline(admin.StackedInline):
    model = FarmerProfile
    can_delete = False
    verbose_name_plural = 'Farmer Profile'


class TransportProfileInline(admin.StackedInline):
    model = TransportProviderProfile
    can_delete = False
    verbose_name_plural = 'Transport Provider Profile'


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
    inlines = [FarmerProfileInline, TransportProfileInline]


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
    list_display = ('user', 'vehicle_type', 'deposit_paid', 'is_approved', 'rating')
    list_filter = ('vehicle_type', 'deposit_paid', 'is_approved')
    search_fields = ('user__phone', 'license_plate')
    actions = ['approve_provider']

    def approve_provider(self, request, queryset):
        queryset.update(is_approved=True)
    approve_provider.short_description = 'Approve transport providers'