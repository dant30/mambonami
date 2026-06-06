# backend/django_admin/apps/products/admin.py
from django.contrib import admin
from .models import ProductCategory, Product

@admin.register(ProductCategory)
class ProductCategoryAdmin(admin.ModelAdmin):
    list_display = ('code', 'name', 'is_active')
    list_filter = ('is_active',)
    search_fields = ('code', 'name')
    list_editable = ('is_active',)

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('sku', 'name', 'variety', 'farmer', 'category', 'price_per_unit', 'available_quantity', 'reserved_quantity', 'expiry_date', 'is_organic', 'is_active')
    list_filter = ('category', 'is_active', 'harvest_date', 'expiry_date', 'is_organic')
    search_fields = ('sku', 'name', 'variety', 'farmer__user__phone', 'farmer__user__username')
    readonly_fields = ('sku', 'uuid', 'expiry_date', 'created_at', 'updated_at')
    fieldsets = (
        (None, {'fields': ('farmer', 'category', 'sku', 'name', 'variety', 'description', 'image')}),
        ('Pricing & Inventory', {'fields': ('price_per_unit', 'available_quantity', 'reserved_quantity', 'unit', 'weight_per_unit')}),
        ('Harvest Info', {'fields': ('harvest_date', 'shelf_life_days', 'expiry_date')}),
        ('Product Info', {'fields': ('is_organic',)}),
        ('Status', {'fields': ('is_active',)}),
        ('System', {'fields': ('uuid', 'created_at', 'updated_at')}),
    )