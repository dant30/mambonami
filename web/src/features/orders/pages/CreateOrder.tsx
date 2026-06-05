import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useProducts } from '../../../core/hooks/useProducts';
import { formatCurrency } from '../../../core/utils';
import { useOrders } from '../hooks/useOrders';
import type { OrderCreateItem, OrderCreatePayload } from '../services/orderService';
import Form from '../../../shared/components/forms/Form';
import FormInput from '../../../shared/components/forms/FormInput';
import FormSelect from '../../../shared/components/forms/FormSelect';
import Button from '../../../shared/components/ui/Button';
import Card from '../../../shared/components/ui/Card';
import DatePicker from '../../../shared/components/ui/DatePicker';
import TimePicker from '../../../shared/components/ui/TimePicker';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../../shared/components/tables/Table';

export default function CreateOrder() {
  const navigate = useNavigate();
  const { products, error: productError, listProducts } = useProducts();
  const { createOrder, loading: orderLoading, error: orderError, clearError } = useOrders();

  const [deliveryAddress, setDeliveryAddress] = useState('');
  const [deliveryLat, setDeliveryLat] = useState('');
  const [deliveryLng, setDeliveryLng] = useState('');
  const [scheduledDate, setScheduledDate] = useState('');
  const [scheduledStart, setScheduledStart] = useState('10:00');
  const [scheduledEnd, setScheduledEnd] = useState('12:00');
  const [selectedProductUuid, setSelectedProductUuid] = useState('');
  const [quantity, setQuantity] = useState(1);
  const [cart, setCart] = useState<OrderCreateItem[]>([]);

  useEffect(() => {
    listProducts({ page_size: 50 }).catch(() => {});
  }, [listProducts]);

  const productOptions = useMemo(
    () => products.filter((product) => typeof product.uuid === 'string'),
    [products],
  );

  const cartItems = useMemo(
    () =>
      cart.map((item) => ({
        ...item,
        product: products.find((productItem) => productItem.uuid === item.product_uuid),
      })),
    [cart, products],
  );

  const cartTotal = useMemo(
    () =>
      cartItems.reduce(
        (sum, item) => sum + Number(item.product?.price ?? 0) * item.quantity,
        0,
      ),
    [cartItems],
  );

  const scheduledTimeWindow = `${scheduledStart}-${scheduledEnd}`;
  const canAddItem = Boolean(selectedProductUuid && quantity > 0);
  const canSubmit = Boolean(
    deliveryAddress && deliveryLat && deliveryLng && scheduledDate && scheduledStart && scheduledEnd && cart.length > 0,
  );

  const handleAddItem = () => {
    if (!selectedProductUuid || quantity <= 0) return;

    setCart((prev) => {
      const existing = prev.find((item) => item.product_uuid === selectedProductUuid);
      if (existing) {
        return prev.map((item) =>
          item.product_uuid === selectedProductUuid
            ? { ...item, quantity: item.quantity + quantity }
            : item,
        );
      }
      return [...prev, { product_uuid: selectedProductUuid, quantity }];
    });

    setQuantity(1);
  };

  const handleRemoveItem = (product_uuid: string) => {
    setCart((prev) => prev.filter((item) => item.product_uuid !== product_uuid));
  };

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    clearError();

    if (!canSubmit) {
      return;
    }

    const payload: OrderCreatePayload = {
      delivery_address: deliveryAddress,
      delivery_lat: Number(deliveryLat),
      delivery_lng: Number(deliveryLng),
      scheduled_date: scheduledDate,
      scheduled_time_window: scheduledTimeWindow,
      items: cart,
    };

    const order = await createOrder(payload);
    if (order?.uuid) {
      navigate(`/orders/${order.uuid}`);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-slate-900">Create order</h1>
          <p className="mt-2 text-sm text-slate-600">
            Specify delivery details, add items, and preview order totals before submitting.
          </p>
        </div>
      </div>

      {(productError || orderError) && (
        <div className="rounded-3xl border border-red-200 bg-red-50 px-4 py-4 text-sm text-red-700 shadow-soft">
          {productError || orderError}
        </div>
      )}

      <Form
        title="New order"
        description="Provide delivery details, choose products, and confirm the final order preview."
        onSubmit={handleSubmit}
        className="space-y-6"
      >
        <Card>
          <div className="space-y-4">
            <div>
              <h2 className="text-lg font-semibold text-slate-900">Delivery information</h2>
              <p className="mt-1 text-sm text-slate-500">Where should this order be delivered?</p>
            </div>
            <div className="grid gap-4 sm:grid-cols-2">
              <FormInput
                id="deliveryAddress"
                label="Delivery address"
                value={deliveryAddress}
                onChange={(event) => setDeliveryAddress(event.target.value)}
                placeholder="123 Main Street"
              />
              <FormInput
                id="deliveryLat"
                label="Latitude"
                type="number"
                value={deliveryLat}
                onChange={(event) => setDeliveryLat(event.target.value)}
                placeholder="-1.2921"
                step="0.000001"
              />
              <FormInput
                id="deliveryLng"
                label="Longitude"
                type="number"
                value={deliveryLng}
                onChange={(event) => setDeliveryLng(event.target.value)}
                placeholder="36.8219"
                step="0.000001"
              />
              <DatePicker
                id="scheduledDate"
                className="w-full"
                value={scheduledDate}
                onChange={(event: React.ChangeEvent<HTMLInputElement>) => setScheduledDate(event.target.value)}
              />
              <div className="sm:col-span-2 grid gap-4 sm:grid-cols-2">
                <div>
                  <label htmlFor="scheduledStart" className="form-label">
                    Start time
                  </label>
                  <TimePicker
                    id="scheduledStart"
                    value={scheduledStart}
                    onChange={(event: React.ChangeEvent<HTMLInputElement>) => setScheduledStart(event.target.value)}
                  />
                </div>
                <div>
                  <label htmlFor="scheduledEnd" className="form-label">
                    End time
                  </label>
                  <TimePicker
                    id="scheduledEnd"
                    value={scheduledEnd}
                    onChange={(event: React.ChangeEvent<HTMLInputElement>) => setScheduledEnd(event.target.value)}
                  />
                </div>
              </div>
            </div>
          </div>
        </Card>

        <Card>
          <div className="space-y-4">
            <div>
              <h2 className="text-lg font-semibold text-slate-900">Order items</h2>
              <p className="mt-1 text-sm text-slate-500">Select products, choose quantities, and review cart line items.</p>
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <FormSelect
                id="selectedProduct"
                label="Choose product"
                value={selectedProductUuid}
                onChange={(event) => setSelectedProductUuid(event.target.value)}
              >
                <option value="">Select a product</option>
                {productOptions.map((product) => (
                  <option key={product.uuid} value={product.uuid}>
                    {product.name || product.description || product.uuid} • {formatCurrency(Number(product.price ?? 0))}
                  </option>
                ))}
              </FormSelect>
              <FormInput
                id="quantity"
                label="Quantity"
                type="number"
                min={1}
                step={1}
                value={quantity}
                onChange={(event) => setQuantity(Number(event.target.value))}
              />
            </div>

            <Button type="button" variant="secondary" disabled={!canAddItem} onClick={handleAddItem}>
              Add item
            </Button>

            {cart.length > 0 ? (
              <Card className="p-0">
                <Table className="min-w-full text-left text-sm text-slate-700">
                  <TableHeader className="bg-slate-50 text-slate-900">
                    <TableRow>
                      <TableHead className="px-4 py-3">Product</TableHead>
                      <TableHead className="px-4 py-3">Qty</TableHead>
                      <TableHead className="px-4 py-3">Subtotal</TableHead>
                      <TableHead className="px-4 py-3">Action</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {cartItems.map((item) => (
                      <TableRow key={item.product_uuid}>
                        <TableCell className="px-4 py-3">
                          {item.product?.name || item.product?.description || item.product_uuid}
                        </TableCell>
                        <TableCell className="px-4 py-3">{item.quantity}</TableCell>
                        <TableCell className="px-4 py-3">
                          {formatCurrency(Number(item.product?.price ?? 0) * item.quantity)}
                        </TableCell>
                        <TableCell className="px-4 py-3">
                          <button
                            type="button"
                            onClick={() => handleRemoveItem(item.product_uuid)}
                            className="text-sm text-red-600 hover:text-red-800"
                          >
                            Remove
                          </button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </Card>
            ) : (
              <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6 text-sm text-slate-600">
                Add one or more items to build your order.
              </div>
            )}
          </div>
        </Card>

        <Card>
          <div className="space-y-4">
            <div>
              <h2 className="text-lg font-semibold text-slate-900">Order preview</h2>
              <p className="mt-1 text-sm text-slate-500">Review the delivery summary and total before submitting.</p>
            </div>

            <div className="grid gap-4 sm:grid-cols-3">
              <div className="rounded-3xl border border-slate-200 bg-slate-50 p-4">
                <p className="font-semibold text-slate-900">Items</p>
                <p className="mt-3 text-sm text-slate-600">{cart.length} product{cart.length === 1 ? '' : 's'}</p>
                <p className="mt-2 text-sm font-semibold text-slate-900">Order total</p>
                <p className="text-2xl font-semibold text-slate-900">{formatCurrency(cartTotal)}</p>
              </div>
              <div className="rounded-3xl border border-slate-200 bg-slate-50 p-4">
                <p className="font-semibold text-slate-900">Delivery</p>
                <p className="mt-3 text-sm text-slate-600">{deliveryAddress || 'Address required'}</p>
                <p className="mt-1 text-sm text-slate-600">
                  {deliveryLat && deliveryLng ? `${deliveryLat}, ${deliveryLng}` : 'Coordinates required'}
                </p>
              </div>
              <div className="rounded-3xl border border-slate-200 bg-slate-50 p-4">
                <p className="font-semibold text-slate-900">Schedule</p>
                <p className="mt-3 text-sm text-slate-600">{scheduledDate ? scheduledDate : 'No date selected'}</p>
                <p className="mt-1 text-sm text-slate-600">{scheduledStart && scheduledEnd ? `${scheduledStart} – ${scheduledEnd}` : 'No time selected'}</p>
              </div>
            </div>
          </div>
        </Card>

        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <p className="text-sm text-slate-500">Complete every section and submit when the order preview looks right.</p>
          <Button type="submit" variant="default" className="w-full sm:w-auto" disabled={!canSubmit || orderLoading}>
            {orderLoading ? 'Creating order…' : 'Create order'}
          </Button>
        </div>
      </Form>
    </div>
  );
}

