import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useProducts } from '../../../core/hooks/useProducts';
import Form from '../../../shared/components/forms/Form';
import FormField from '../../../shared/components/forms/FormField';
import FormSection from '../../../shared/components/forms/FormSection';
import FormActions from '../../../shared/components/forms/FormActions';
import { Modal, ModalFooter, ModalBody, ModalHeader } from '../../../shared/components/ui/Modal';
import Button from '../../../shared/components/ui/Button';
import Card from '../../../shared/components/cards/Card';
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
  const [variety, setVariety] = useState('');
  const [pricePerUnit, setPricePerUnit] = useState('');
  const [availableQuantity, setAvailableQuantity] = useState('0');
  const [unit, setUnit] = useState('kg');
  const [harvestDate, setHarvestDate] = useState('');
  const [available, setAvailable] = useState(true);
  const [categoryId, setCategoryId] = useState('');
  const [isOrganic, setIsOrganic] = useState(false);

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
        setVariety(response.variety ?? '');
        setPricePerUnit(String(response.price_per_unit ?? ''));
        setAvailableQuantity(String(response.available_quantity ?? 0));
        setUnit(response.unit ?? 'kg');
        setHarvestDate(response.harvest_date ?? '');
        setAvailable(Boolean(response.is_active));
        setIsOrganic(Boolean(response.is_organic));
      })
      .catch(() => {});
  }, [getProduct, uuid]);

  const canSubmit = Boolean(name.trim() && pricePerUnit && availableQuantity && harvestDate && !Number.isNaN(Number(pricePerUnit)) && product?.uuid);

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!canSubmit || !product?.uuid) return;

    const payload = {
      name: name.trim(),
      variety: variety.trim(),
      description: description.trim(),
      price_per_unit: Number(pricePerUnit),
      available_quantity: Number(availableQuantity),
      reserved_quantity: Number(product?.reserved_quantity ?? 0),
      unit,
      harvest_date: harvestDate,
      is_active: available,
      is_organic: isOrganic,
      category: categoryId ? Number(categoryId) : undefined,
    };

    const updated = await updateFarmerProduct(product.uuid, payload);
    if (updated?.uuid) {
      navigate(`/products/${updated.uuid}`);
    }
  };

  const [showDeleteModal, setShowDeleteModal] = useState(false);

  const handleDelete = async () => {
    if (!product?.uuid) return;
    await deleteFarmerProduct(product.uuid);
    setShowDeleteModal(false);
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
            <FormSection>
              <div className="grid gap-4 sm:grid-cols-2">
                <FormField id="productName" label="Product name">
                  <input
                    id="productName"
                    className="form-input"
                    value={name}
                    onChange={(event) => setName(event.target.value)}
                    placeholder="Product name"
                  />
                </FormField>

                <FormField id="productVariety" label="Variety">
                  <input
                    id="productVariety"
                    className="form-input"
                    value={variety}
                    onChange={(event) => setVariety(event.target.value)}
                    placeholder="Variety"
                  />
                </FormField>
              </div>

              <div className="grid gap-4 sm:grid-cols-2">
                <FormField id="productPricePerUnit" label="Price per unit">
                  <input
                    id="productPricePerUnit"
                    className="form-input"
                    type="number"
                    min={0}
                    step={0.01}
                    value={pricePerUnit}
                    onChange={(event) => setPricePerUnit(event.target.value)}
                  />
                </FormField>

                <FormField id="productQuantity" label="Available quantity">
                  <input
                    id="productQuantity"
                    className="form-input"
                    type="number"
                    min={0}
                    step={1}
                    value={availableQuantity}
                    onChange={(event) => setAvailableQuantity(event.target.value)}
                  />
                </FormField>
              </div>

              <div className="grid gap-4 sm:grid-cols-2">
                <FormField id="productUnit" label="Unit">
                  <select
                    id="productUnit"
                    className="form-select"
                    value={unit}
                    onChange={(event) => setUnit(event.target.value)}
                  >
                    <option value="kg">Kilogram</option>
                    <option value="piece">Piece</option>
                    <option value="litre">Litre</option>
                    <option value="tray">Tray</option>
                    <option value="bunch">Bunch</option>
                  </select>
                </FormField>

                <FormField id="productHarvestDate" label="Harvest date">
                  <input
                    id="productHarvestDate"
                    className="form-input"
                    type="date"
                    value={harvestDate}
                    onChange={(event) => setHarvestDate(event.target.value)}
                  />
                </FormField>
              </div>

              <div className="grid gap-4 sm:grid-cols-2">
                <FormField id="productCategory" label="Category">
                  <select
                    id="productCategory"
                    className="form-select"
                    value={categoryId}
                    onChange={(event) => setCategoryId(event.target.value)}
                  >
                    <option value="">Uncategorized</option>
                    {categories.map((category) => (
                      <option key={category.id} value={String(category.id)}>
                        {category.name || `Category ${category.id}`}
                      </option>
                    ))}
                  </select>
                </FormField>

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
                <label className="inline-flex items-center gap-3 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700">
                  <input
                    type="checkbox"
                    checked={isOrganic}
                    onChange={(event) => setIsOrganic(event.target.checked)}
                    className="h-4 w-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500"
                  />
                  <span>{isOrganic ? 'Organic certified' : 'Not organic certified'}</span>
                </label>
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

              <FormActions
                primaryLabel={loading ? 'Saving...' : 'Save changes'}
                primaryProps={{ type: 'submit', disabled: !canSubmit || loading }}
                secondaryLabel="Delete product"
                secondaryProps={{ type: 'button', variant: 'destructive', onClick: () => setShowDeleteModal(true) }}
              />
            </FormSection>
          </div>
        </Card>
      </Form>

      <Modal isOpen={showDeleteModal} onClose={() => setShowDeleteModal(false)} title="Delete product" size="sm">
        <ModalHeader>
          <h3 className="text-base font-semibold">Delete product</h3>
        </ModalHeader>
        <ModalBody>
          <p>Are you sure you want to permanently delete this product? This action cannot be undone.</p>
        </ModalBody>
        <ModalFooter>
          <Button variant="destructive" onClick={handleDelete}>
            Delete
          </Button>
        </ModalFooter>
      </Modal>
    </div>
  );
}

