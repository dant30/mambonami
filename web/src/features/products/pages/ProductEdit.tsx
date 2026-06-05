import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useProducts } from '../../../core/hooks/useProducts';
import Form from '../../../shared/components/forms/Form';
import FormInput from '../../../shared/components/forms/FormInput';
import FormSelect from '../../../shared/components/forms/FormSelect';
import Button from '../../../shared/components/ui/Button';
import Card from '../../../shared/components/ui/Card';
import type { Product } from '../../../core/types';

export default function ProductEdit() {
  const navigate = useNavigate();
  const { uuid } = useParams();
  const {
    categories,
    getCategories,
    getProduct,
    updateFarmerProduct,
    deleteFarmerProduct,
    loading,
    error,
  } = useProducts();
  const [product, setProduct] = useState<Product | null>(null);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState('');
  const [currency, setCurrency] = useState('USD');
  const [stock, setStock] = useState('0');
  const [available, setAvailable] = useState(true);
  const [categoryId, setCategoryId] = useState('');

  useEffect(() => {
    getCategories().catch(() => {});
  }, [getCategories]);

  useEffect(() => {
    if (!uuid) return;
    getProduct(uuid)
      .then((response) => {
        setProduct(response);
        setName(response.name ?? '');
        setDescription(response.description ?? '');
        setPrice(String(response.price ?? ''));
        setCurrency(response.currency ?? 'USD');
        setStock(String(response.stock ?? 0));
        setAvailable(Boolean(response.available));
      })
      .catch(() => {});
  }, [getProduct, uuid]);

  const canSubmit = Boolean(name.trim() && price && !Number.isNaN(Number(price)) && product?.uuid);

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!canSubmit || !product?.uuid) return;

    const payload = {
      name: name.trim(),
      description: description.trim(),
      price: Number(price),
      currency,
      stock: Number(stock),
      available,
      category: categoryId ? Number(categoryId) : undefined,
    };

    const updated = await updateFarmerProduct(product.uuid, payload);
    if (updated?.uuid) {
      navigate(`/products/${updated.uuid}`);
    }
  };

  const handleDelete = async () => {
    if (!product?.uuid) return;
    const confirmed = window.confirm('Delete this product permanently?');
    if (!confirmed) return;
    await deleteFarmerProduct(product.uuid);
    navigate('/products');
  };

  if (!product && loading) {
    return <Card className="max-w-3xl mx-auto p-6">Loading product…</Card>;
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-slate-900">Edit product</h1>
          <p className="mt-2 text-sm text-slate-600">Update product metadata, pricing, and availability.</p>
        </div>
      </div>

      {error ? (
        <div className="rounded-3xl border border-red-200 bg-red-50 px-4 py-4 text-sm text-red-700 shadow-soft">
          {error}
        </div>
      ) : null}

      <Form title="Edit product" description="Adjust product details and save changes." onSubmit={handleSubmit}>
        <Card>
          <div className="space-y-6">
            <div className="grid gap-4 sm:grid-cols-2">
              <FormInput
                id="productName"
                label="Product name"
                value={name}
                onChange={(event) => setName(event.target.value)}
                placeholder="Product name"
              />
              <FormInput
                id="productPrice"
                label="Price"
                type="number"
                min={0}
                step={0.01}
                value={price}
                onChange={(event) => setPrice(event.target.value)}
              />
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <FormSelect id="productCurrency" label="Currency" value={currency} onChange={(event) => setCurrency(event.target.value)}>
                <option value="USD">USD</option>
                <option value="EUR">EUR</option>
                <option value="KES">KES</option>
              </FormSelect>
              <FormInput
                id="productStock"
                label="Stock"
                type="number"
                min={0}
                step={1}
                value={stock}
                onChange={(event) => setStock(event.target.value)}
              />
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <FormSelect
                id="productCategory"
                label="Category"
                value={categoryId}
                onChange={(event) => setCategoryId(event.target.value)}
              >
                <option value="">Uncategorized</option>
                {categories.map((category) => (
                  <option key={category.id} value={String(category.id)}>
                    {category.name || `Category ${category.id}`}
                  </option>
                ))}
              </FormSelect>
              <div className="space-y-2">
                <label htmlFor="productAvailable" className="form-label">
                  Availability
                </label>
                <label className="inline-flex items-center gap-3 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700">
                  <input
                    id="productAvailable"
                    type="checkbox"
                    checked={available}
                    onChange={(event) => setAvailable(event.target.checked)}
                    className="h-4 w-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500"
                  />
                  <span>{available ? 'Published' : 'Draft'}</span>
                </label>
              </div>
            </div>

            <div className="space-y-2">
              <label htmlFor="productDescription" className="form-label">
                Description
              </label>
              <textarea
                id="productDescription"
                value={description}
                onChange={(event) => setDescription(event.target.value)}
                className="form-input min-h-[120px]"
                placeholder="Describe the product for customers"
              />
            </div>

            <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <Button type="submit" variant="default" className="w-full sm:w-auto" disabled={!canSubmit || loading}>
                {loading ? 'Saving...' : 'Save changes'}
              </Button>
              <Button type="button" variant="destructive" className="w-full sm:w-auto" onClick={handleDelete}>
                Delete product
              </Button>
            </div>
          </div>
        </Card>
      </Form>
    </div>
  );
}

