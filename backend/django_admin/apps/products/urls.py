# backend/django_admin/apps/products/urls.py
from django.urls import path
from .views import api
from .views.admin_views import AdminProductListView, AdminProductStatusView

app_name = 'products'

urlpatterns = [
    path('admin/', AdminProductListView.as_view(), name='admin-product-list'),
    path('admin/<uuid:uuid>/status/', AdminProductStatusView.as_view(), name='admin-product-status'),
    # Public
    path('categories/', api.ProductCategoryListView.as_view(), name='product-categories'),
    path('units/', api.ProductUnitListView.as_view(), name='product-units'),
    path('wishlist/', api.WishlistListView.as_view(), name='wishlist-list'),
    path('wishlist/<uuid:uuid>/', api.WishlistItemView.as_view(), name='wishlist-item'),
	path('<uuid:uuid>/reviews/', api.ProductReviewListCreateView.as_view(), name='product-reviews'),
    path('', api.ProductListView.as_view(), name='product-list'),
    path('<uuid:uuid>/', api.ProductDetailView.as_view(), name='product-detail'),

    # Farmer only
    path('farmer/products/', api.FarmerProductListCreateView.as_view(), name='farmer-products'),
    path('farmer/products/<uuid:uuid>/', api.FarmerProductUpdateDeleteView.as_view(), name='farmer-product-detail'),
]