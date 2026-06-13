import { useEffect, useState } from 'react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import { useProducts } from '../../../core/hooks/useProducts';
import { formatCurrency, formatDate } from '../../../core/utils';
import Button from '../../../shared/components/ui/Button';
import Card from '../../../shared/components/cards/Card';
import { Product } from '../../../core/types';

export default function ProductDetail() {
  const { uuid } = useParams();
  const navigate = useNavigate();
  const { getProduct, loading, error } = useProducts();
  const [product, setProduct] = useState<Product | null>(null);

  useEffect(() => {
    if (!uuid) return;
    getProduct(uuid)
      .then((response) => setProduct(response))
      .catch(() => {});
  }, [getProduct, uuid]);

  if (loading && !product) {
    return <Card className="max-w-3xl mx-auto p-6">Loading product details...</Card>;
  }

  if (error) {
    return (
      <Card className="max-w-3xl mx-auto border-destructive/30 bg-red-50 text-red-700 p-6">
        {error}
      </Card>
    );
  }

  if (!product) {
    return (
      <Card className="max-w-3xl mx-auto p-6">
        <p className="text-slate-700">Product not found.</p>
        <div className="mt-4 flex flex-wrap gap-3">
          <Link to="/products" className="text-emerald-600 hover:text-emerald-700">
            Back to products
          </Link>
          <Button type="button" variant="secondary" onClick={() => navigate('/products')}>
            Product list
          </Button>
        </div>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-slate-900">{product.name || `Product ${product.uuid ?? product.id}`}</h1>
          <p className="mt-2 text-sm text-slate-600">Review full product details and update inventory as needed.</p>
        </div>
        <div className="flex flex-wrap items-center gap-3">
          <Link to="/products" className="inline-flex items-center rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700 transition hover:bg-slate-50">
            Back to products
          </Link>
          <Button type="button" variant="secondary" onClick={() => navigate(`/products/${product.uuid}/edit`)}>
            Edit product
          </Button>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <div className="space-y-4">
            <div>
              <h2 className="text-lg font-semibold text-slate-900">Product overview</h2>
              <p className="mt-1 text-sm text-slate-500">Essential product metadata and pricing information.</p>
            </div>
            <div className="grid gap-4 text-sm text-slate-600 sm:grid-cols-2">
              <div>
                <p className="font-semibold text-slate-900">Name</p>
                <p>{product.name || 'Unnamed product'}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Price per unit</p>
                <p>{formatCurrency(Number(product.price_per_unit ?? 0))}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Available quantity</p>
                <p>{product.available_quantity ?? 'Not tracked'}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Availability</p>
                <p>{product.is_active ? 'Active' : 'Inactive'}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Vendor</p>
                <p>{product.farmer_phone ?? product.farmer ?? 'Not assigned'}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">UUID</p>
                <p>{product.uuid || 'N/A'}</p>
              </div>
            </div>
          </div>
        </Card>

        <Card>
          <div className="space-y-4">
            <div>
              <h2 className="text-lg font-semibold text-slate-900">Inventory</h2>
              <p className="mt-1 text-sm text-slate-500">Units, reserve counts, and freshness details.</p>
            </div>
            <div className="grid gap-4 text-sm text-slate-600 sm:grid-cols-2">
              <div>
                <p className="font-semibold text-slate-900">Unit</p>
                <p>{product.unit || 'N/A'}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Reserved quantity</p>
                <p>{product.reserved_quantity ?? 0}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Harvest date</p>
                <p>{product.harvest_date ? formatDate(product.harvest_date) : 'Not set'}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Expiry date</p>
                <p>{product.expiry_date ? formatDate(product.expiry_date) : 'Not calculated'}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Shelf life</p>
                <p>{product.shelf_life_days ?? 'N/A'} days</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Organic</p>
                <p>{product.is_organic ? 'Yes' : 'No'}</p>
              </div>
            </div>
          </div>
        </Card>

        <Card>
          <div className="space-y-4">
            <div>
              <h2 className="text-lg font-semibold text-slate-900">Description</h2>
              <p className="mt-1 text-sm text-slate-500">What customers see when they browse this item.</p>
            </div>
            <p className="text-sm text-slate-600">{product.description || 'No description provided.'}</p>
          </div>
        </Card>
      </div>

      <Card>
        <div className="grid gap-4 text-sm text-slate-600 sm:grid-cols-2">
          <div>
            <p className="font-semibold text-slate-900">Created</p>
            <p>{product.created_at ? formatDate(product.created_at) : 'N/A'}</p>
          </div>
          <div>
            <p className="font-semibold text-slate-900">Updated</p>
            <p>{product.updated_at ? formatDate(product.updated_at) : 'N/A'}</p>
          </div>
        </div>
      </Card>
    </div>
  );
}

