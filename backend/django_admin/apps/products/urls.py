# backend/django_admin/apps/products/urls.py
from django.urls import path
from .views import api

urlpatterns = [
    # Public
    path('categories/', api.ProductCategoryListView.as_view(), name='product-categories'),
    path('', api.ProductListView.as_view(), name='product-list'),
    path('<uuid:uuid>/', api.ProductDetailView.as_view(), name='product-detail'),

    # Farmer only
    path('farmer/products/', api.FarmerProductListCreateView.as_view(), name='farmer-products'),
    path('farmer/products/<uuid:uuid>/', api.FarmerProductUpdateDeleteView.as_view(), name='farmer-product-detail'),
]