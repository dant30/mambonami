import { useEffect, useMemo, useState } from 'react';
import { Download } from 'lucide-react';
import Card from '../../../shared/components/cards/Card';
import Button from '../../../shared/components/ui/Button';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../../shared/components/tables/Table';
import { formatCurrency, formatDate } from '../../../core/utils';
import { listOrders } from '../services/adminService';
import { downloadCsv, downloadPdf } from '../utils/reportExport';
import type { Order, OrderStatus } from '../../../core/types';

const statusOptions: Array<OrderStatus | 'all'> = [
  'all',
  'cart',
  'placed',
  'paid_escrow',
  'transport_assigned',
  'picked_up',
  'delivered',
  'cancelled',
  'disputed',
];

export default function AdminOrderOverview() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [statusFilter, setStatusFilter] = useState<OrderStatus | 'all'>('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadOrders = async () => {
      setLoading(true);
      setError(null);
      try {
        const data = await listOrders({ page_size: 100 });
        setOrders(data as Order[]);
      } catch (err) {
        console.error(err);
        setError('Unable to load orders.');
      } finally {
        setLoading(false);
      }
    };

    loadOrders();
  }, []);

  const filteredOrders = useMemo(() => {
    const normalizedSearch = searchTerm.trim().toLowerCase();
    return orders
      .filter((order) =>
        statusFilter === 'all' ? true : order.status === statusFilter,
      )
      .filter((order) => {
        if (!normalizedSearch) return true;
        return [
          order.uuid,
          order.account_number,
          order.buyer_phone,
          order.delivery_address,
          order.status,
        ]
          .filter(Boolean)
          .some((value) => String(value).toLowerCase().includes(normalizedSearch));
      });
  }, [orders, searchTerm, statusFilter]);

  const exportRows = filteredOrders.map((order) => ({
    'Order ID': order.uuid,
    'Account Number': order.account_number || '',
    'Buyer Phone': order.buyer_phone || '',
    'Total Amount': formatCurrency(Number(order.total_amount ?? 0)),
    Status: order.status,
    Created: formatDate(order.created_at),
    'Delivery Address': order.delivery_address || '',
  }));

  const handleExportCsv = () => {
    downloadCsv('admin-orders.csv', exportRows, [
      'Order ID',
      'Account Number',
      'Buyer Phone',
      'Total Amount',
      'Status',
      'Created',
      'Delivery Address',
    ]);
  };

  const handleExportPdf = () => {
    downloadPdf('admin-orders.pdf', 'Admin Order Overview', exportRows, [
      'Order ID',
      'Account Number',
      'Buyer Phone',
      'Total Amount',
      'Status',
      'Created',
    ]);
  };

  const totals = useMemo(() => {
    return {
      total: filteredOrders.length,
      delivered: filteredOrders.filter((order) => order.status === 'delivered').length,
      pending: filteredOrders.filter((order) => order.status === 'placed' || order.status === 'paid_escrow' || order.status === 'transport_assigned' || order.status === 'picked_up').length,
      disputed: filteredOrders.filter((order) => order.status === 'disputed').length,
    };
  }, [filteredOrders]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Order Overview</h1>
        <p className="mt-2 text-sm text-slate-600">
          Search orders by ID, buyer phone, status and review order performance in one place.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Card className="p-4">
          <p className="text-sm text-slate-600">Filtered Orders</p>
          <p className="mt-3 text-3xl font-semibold text-slate-900">{totals.total}</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-slate-600">Delivered</p>
          <p className="mt-3 text-3xl font-semibold text-emerald-600">{totals.delivered}</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-slate-600">In Progress</p>
          <p className="mt-3 text-3xl font-semibold text-amber-600">{totals.pending}</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-slate-600">Disputed</p>
          <p className="mt-3 text-3xl font-semibold text-red-600">{totals.disputed}</p>
        </Card>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <div>
          <label className="block text-sm font-medium text-slate-900">Search orders</label>
          <input
            type="text"
            placeholder="Order UUID, phone, address..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="mt-1 block w-full rounded border border-slate-300 px-3 py-2 text-slate-900"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-900">Filter by status</label>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as OrderStatus | 'all')}
            className="mt-1 block w-full rounded border border-slate-300 bg-white px-3 py-2 text-slate-900"
          >
            {statusOptions.map((status) => (
              <option key={status} value={status}>
                {status === 'all' ? 'All statuses' : status.replace(/_/g, ' ')}
              </option>
            ))}
          </select>
        </div>
        <div className="flex items-end gap-2">
          <Button type="button" variant="secondary" onClick={handleExportCsv} className="w-full">
            <Download className="mr-2 h-4 w-4" /> CSV Export
          </Button>
          <Button type="button" variant="secondary" onClick={handleExportPdf} className="w-full">
            <Download className="mr-2 h-4 w-4" /> PDF Export
          </Button>
        </div>
      </div>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{error}</div>}

      {loading ? (
        <Card className="p-6 text-center">Loading orders...</Card>
      ) : filteredOrders.length === 0 ? (
        <Card className="p-6 text-center text-slate-600">No orders match the current filters.</Card>
      ) : (
        <Card className="overflow-hidden p-0">
          <Table className="min-w-full text-left text-sm text-slate-700">
            <TableHeader className="bg-slate-50 text-slate-900">
              <TableRow>
                <TableHead className="px-4 py-4">Order</TableHead>
                <TableHead className="px-4 py-4">Buyer</TableHead>
                <TableHead className="px-4 py-4">Total</TableHead>
                <TableHead className="px-4 py-4">Status</TableHead>
                <TableHead className="px-4 py-4">Created</TableHead>
                <TableHead className="px-4 py-4">Delivery</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredOrders.map((order) => (
                <TableRow key={order.uuid ?? order.id}>
                  <TableCell className="px-4 py-4 font-medium text-slate-900">{order.uuid || order.id}</TableCell>
                  <TableCell className="px-4 py-4 text-slate-600">{order.buyer_phone || '—'}</TableCell>
                  <TableCell className="px-4 py-4 font-medium text-slate-900">{formatCurrency(Number(order.total_amount ?? 0))}</TableCell>
                  <TableCell className="px-4 py-4 capitalize text-slate-700">{order.status.replace(/_/g, ' ')}</TableCell>
                  <TableCell className="px-4 py-4 text-slate-600">{formatDate(order.created_at)}</TableCell>
                  <TableCell className="px-4 py-4 text-slate-600">{order.delivery_address || '—'}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Card>
      )}
    </div>
  );
}
