import { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useOrders } from '../hooks/useOrders';
import { getOrderStatusLabel, getOrderStatusClasses } from '../hooks/useOrderStatus';
import { formatCurrency, formatDate } from '../../../core/utils';
import Badge from '../../../shared/components/ui/Badge';
import Button from '../../../shared/components/ui/Button';
import Card from '../../../shared/components/ui/Card';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../../shared/components/tables/Table';

export default function OrderList() {
  const { orders, loading, error, fetchOrders, clearError } = useOrders();

  useEffect(() => {
    fetchOrders();
  }, [fetchOrders]);

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-slate-900">Orders</h1>
          <p className="mt-2 text-sm text-slate-600">
            Manage customer orders, review status, and inspect details in one place.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <Link
            to="create"
            className="inline-flex items-center rounded-full bg-emerald-600 px-4 py-2 text-sm font-semibold text-white shadow-soft transition hover:bg-emerald-700"
          >
            Create order
          </Link>
          <Button
            type="button"
            variant="secondary"
            className="rounded-full"
            onClick={() => {
              clearError();
              fetchOrders();
            }}
          >
            Refresh
          </Button>
        </div>
      </div>

      {error ? (
        <div className="rounded-3xl border border-red-200 bg-red-50 px-4 py-4 text-sm text-red-700 shadow-soft">
          {error}
        </div>
      ) : null}

      <Card className="overflow-hidden p-0">
        <Table className="min-w-full text-left text-sm text-slate-700">
          <TableHeader className="bg-slate-50 text-slate-900">
            <TableRow>
              <TableHead className="px-4 py-4">Order</TableHead>
              <TableHead className="px-4 py-4">Buyer</TableHead>
              <TableHead className="px-4 py-4">Total</TableHead>
              <TableHead className="px-4 py-4">Status</TableHead>
              <TableHead className="px-4 py-4">Created</TableHead>
              <TableHead className="px-4 py-4">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={6} className="px-4 py-8 text-center text-slate-500">
                  Loading orders...
                </TableCell>
              </TableRow>
            ) : orders.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} className="px-4 py-8 text-center text-slate-500">
                  No orders found. Create a new order to get started.
                </TableCell>
              </TableRow>
            ) : (
              orders.map((order) => (
                <TableRow key={order.uuid ?? order.id}>
                  <TableCell className="px-4 py-4 font-medium text-slate-900">
                    {order.account_number || order.uuid}
                  </TableCell>
                  <TableCell className="px-4 py-4">{order.buyer_phone || '—'}</TableCell>
                  <TableCell className="px-4 py-4">{formatCurrency(Number(order.total_amount ?? 0))}</TableCell>
                  <TableCell className="px-4 py-4">
                    <Badge className={getOrderStatusClasses(order.status)}>
                      {getOrderStatusLabel(order.status)}
                    </Badge>
                  </TableCell>
                  <TableCell className="px-4 py-4">{formatDate(order.created_at)}</TableCell>
                  <TableCell className="px-4 py-4">
                    <Link to={order.uuid ? `${order.uuid}` : '#'} className="text-emerald-600 hover:text-emerald-700">
                      View
                    </Link>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </Card>
    </div>
  );
}

