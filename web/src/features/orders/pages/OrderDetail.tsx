import { useEffect } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useOrders } from '../hooks/useOrders';
import {
  getOrderStatusLabel,
  getOrderStatusClasses,
  getSubOrderStatusLabel,
} from '../hooks/useOrderStatus';
import { formatCurrency, formatDate } from '../../../core/utils';
import Badge from '../../../shared/components/ui/Badge';
import Card from '../../../shared/components/ui/Card';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../../shared/components/tables/Table';

export default function OrderDetail() {
  const { uuid } = useParams();
  const { order, loading, error, fetchOrder } = useOrders();

  useEffect(() => {
    if (uuid) {
      fetchOrder(uuid);
    }
  }, [fetchOrder, uuid]);

  if (loading && !order) {
    return <Card className="max-w-2xl mx-auto">Loading order...</Card>;
  }

  if (error) {
    return (
      <Card className="max-w-2xl mx-auto border-destructive/30 bg-red-50 text-red-700">
        {error}
      </Card>
    );
  }

  if (!order) {
    return (
      <Card className="max-w-2xl mx-auto">
        <p className="text-slate-700">No order found.</p>
        <Link to="/orders" className="mt-4 inline-flex text-emerald-600 hover:text-emerald-700">
          Back to orders
        </Link>
      </Card>
    );
  }

  const subOrders = order.sub_orders ?? [];

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-slate-900">Order details</h1>
          <p className="mt-2 text-sm text-slate-600">Review the order and its sub-orders in one place.</p>
        </div>
        <Link
          to="/orders"
          className="inline-flex items-center rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700 transition hover:bg-slate-50"
        >
          Back to orders
        </Link>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <div className="flex items-center justify-between gap-4">
            <div>
              <h2 className="text-lg font-semibold text-slate-900">Order summary</h2>
              <p className="mt-1 text-sm text-slate-500">Essential order details and delivery metadata.</p>
            </div>
            <Badge className={getOrderStatusClasses(order.status)}>{getOrderStatusLabel(order.status)}</Badge>
          </div>

          <div className="mt-6 grid gap-4 text-sm text-slate-600 sm:grid-cols-2">
            <div>
              <p className="font-semibold text-slate-900">Order</p>
              <p>{order.account_number || order.uuid}</p>
            </div>
            <div>
              <p className="font-semibold text-slate-900">Buyer</p>
              <p>{order.buyer_phone || 'Unknown'}</p>
            </div>
            <div>
              <p className="font-semibold text-slate-900">Delivery address</p>
              <p>{order.delivery_address || 'Not set'}</p>
            </div>
            <div>
              <p className="font-semibold text-slate-900">Scheduled</p>
              <p>
                {order.scheduled_date
                  ? `${formatDate(order.scheduled_date)} • ${order.scheduled_time_window || 'Anytime'}`
                  : 'Not scheduled'}
              </p>
            </div>
          </div>
        </Card>

        <Card>
          <div className="space-y-3">
            <div>
              <h2 className="text-lg font-semibold text-slate-900">Financials</h2>
              <p className="mt-1 text-sm text-slate-500">Total, fees, and payout information.</p>
            </div>
            <div className="grid gap-4 text-sm text-slate-600 sm:grid-cols-2">
              <div>
                <p className="font-semibold text-slate-900">Total amount</p>
                <p>{formatCurrency(Number(order.total_amount ?? 0))}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Delivery fee</p>
                <p>{formatCurrency(Number(order.delivery_fee ?? 0))}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Commission</p>
                <p>{formatCurrency(Number(order.platform_commission ?? 0))}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Order weight</p>
                <p>{order.total_weight_kg ?? '0'} kg</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Assigned provider</p>
                <p>{order.assigned_provider ?? 'Not assigned'}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Paid at</p>
                <p>{order.paid_at ? formatDate(order.paid_at) : 'Not paid'}</p>
              </div>
              <div>
                <p className="font-semibold text-slate-900">Delivered at</p>
                <p>{order.delivered_at ? formatDate(order.delivered_at) : 'Not delivered'}</p>
              </div>
            </div>
          </div>
        </Card>
      </div>

      <section className="space-y-4">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h2 className="text-lg font-semibold text-slate-900">Sub-orders</h2>
            <p className="mt-1 text-sm text-slate-500">View order components broken down by supplier.</p>
          </div>
          <span className="text-sm text-slate-500">{order.sub_orders?.length ?? 0} sub-order(s)</span>
        </div>

        <div className="space-y-4">
          {(order.sub_orders?.length ?? 0) === 0 ? (
            <Card className="bg-slate-50 p-6 text-slate-500">
              No sub-orders are attached to this order.
            </Card>
          ) : (
            subOrders.map((subOrder) => (
              <Card key={subOrder.id} className="bg-slate-50">
                <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                  <div>
                    <p className="text-sm font-semibold text-slate-900">Farmer {subOrder.farmer_phone || subOrder.farmer}</p>
                    <p className="mt-1 text-sm text-slate-500">Subtotal: {formatCurrency(Number(subOrder.subtotal ?? 0))}</p>
                  </div>
                  <Badge className="bg-slate-100 text-slate-700">
                    {getSubOrderStatusLabel(subOrder.status)}
                  </Badge>
                </div>

                {subOrder.items?.length ? (
                  <Table className="min-w-full text-left text-sm text-slate-700">
                    <TableHeader className="bg-white text-slate-900">
                      <TableRow>
                        <TableHead className="px-4 py-3">Product</TableHead>
                        <TableHead className="px-4 py-3">Qty</TableHead>
                        <TableHead className="px-4 py-3">Unit price</TableHead>
                        <TableHead className="px-4 py-3">Total</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {(subOrder.items ?? []).map((item) => (
                        <TableRow key={item.id ?? `${item.product?.id}-${item.quantity}`}>
                          <TableCell className="px-4 py-3">{item.product_detail?.description || item.product?.description || `Product ${item.id ?? ''}`}</TableCell>
                          <TableCell className="px-4 py-3">{item.quantity}</TableCell>
                          <TableCell className="px-4 py-3">{formatCurrency(Number(item.unit_price ?? 0))}</TableCell>
                          <TableCell className="px-4 py-3">{formatCurrency(Number(item.total_price ?? 0))}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                ) : null}
              </Card>
            ))
          )}
        </div>
      </section>
    </div>
  );
}

