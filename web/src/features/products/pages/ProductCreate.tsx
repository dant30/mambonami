import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useProducts } from '../../../core/hooks/useProducts';
import Form from '../../../shared/components/forms/Form';
import FormField from '../../../shared/components/forms/FormField';
import FormSection from '../../../shared/components/forms/FormSection';
import FormActions from '../../../shared/components/forms/FormActions';
import Card from '../../../shared/components/cards/Card';

export default function ProductCreate() {
  const navigate = useNavigate();
  const {
    categories,
    createFarmerProduct,
    getCategories,
    loading,
    error,
  } = useProducts();

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

  const canSubmit = Boolean(name.trim() && pricePerUnit && availableQuantity && harvestDate && !Number.isNaN(Number(pricePerUnit)));

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    if (!canSubmit) return;

    const payload = {
      name: name.trim(),
      variety: variety.trim(),
      description: description.trim(),
      price_per_unit: Number(pricePerUnit),
      available_quantity: Number(availableQuantity),
      reserved_quantity: 0,
      unit,
      harvest_date: harvestDate,
      is_active: available,
      is_organic: isOrganic,
      category: categoryId ? Number(categoryId) : undefined,
    };

    const product = await createFarmerProduct(payload);
    if (product?.uuid) {
      navigate(`/products/${product.uuid}`);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-slate-900">Create product</h1>
          <p className="mt-2 text-sm text-slate-600">Add a new product to the catalog for order creation.</p>
        </div>
      </div>

      {error ? (
        <div className="rounded-3xl border border-red-200 bg-red-50 px-4 py-4 text-sm text-red-700 shadow-soft">
          {error}
        </div>
      ) : null}

      <Form title="New product" description="Provide a name, pricing, quantity, and supporting details for this product." onSubmit={handleSubmit}>
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
                    placeholder="Fresh red mango"
                  />
                </FormField>

                <FormField id="productVariety" label="Variety">
                  <input
                    id="productVariety"
                    className="form-input"
                    value={variety}
                    onChange={(event) => setVariety(event.target.value)}
                    placeholder="Ngowe"
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

              <div className="flex flex-col gap-3 sm:flex-row sm:justify-between sm:items-center">
                <p className="text-sm text-slate-500">Once saved, this product can be selected for new orders.</p>
                <FormActions primaryLabel={loading ? 'Saving...' : 'Create product'} primaryProps={{ type: 'submit', disabled: !canSubmit || loading }} />
              </div>
            </FormSection>
          </div>
        </Card>
      </Form>
    </div>
  );
}

