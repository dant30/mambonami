# backend/django_admin/apps/products/admin.py
from django.contrib import admin
from .models import ProductCategory, Product

@admin.register(ProductCategory)
class ProductCategoryAdmin(admin.ModelAdmin):
    list_display = ('code', 'name', 'base_unit', 'is_active')
    list_filter = ('is_active',)
    search_fields = ('code', 'name')
    list_editable = ('is_active',)

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'variety', 'farmer', 'category', 'price_per_unit', 'available_quantity', 'is_active')
    list_filter = ('category', 'is_active', 'harvest_date')
    search_fields = ('name', 'variety', 'farmer__user__phone', 'farmer__user__username')
    readonly_fields = ('uuid', 'created_at', 'updated_at')
    fieldsets = (
        (None, {'fields': ('farmer', 'category', 'name', 'variety', 'description', 'image')}),
        ('Pricing & Inventory', {'fields': ('price_per_unit', 'available_quantity', 'unit')}),
        ('Harvest Info', {'fields': ('harvest_date', 'shelf_life_days')}),
        ('Status', {'fields': ('is_active',)}),
        ('System', {'fields': ('uuid', 'created_at', 'updated_at')}),
    )