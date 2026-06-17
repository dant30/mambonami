import { useMemo, useState } from 'react';
import Card from '../../../shared/components/cards/Card';
import Button from '../../../shared/components/ui/Button';
import { useDisputes } from '../hooks/useDisputes';
import type { DisputeWorkflowStatus } from '../types';

const statusOptions: Array<'all' | DisputeWorkflowStatus> = ['all', 'open', 'under_review', 'resolved', 'closed'];

export default function DisputeList() {
  const [status, setStatus] = useState<'all' | DisputeWorkflowStatus>('all');
  const [search, setSearch] = useState('');
  const trimmedSearch = search.trim();
  const filters = useMemo(
    () => ({
      status: status === 'all' ? undefined : status,
      search: trimmedSearch,
    }),
    [status, trimmedSearch],
  );
  const { disputes, loading, error, summary, refetch } = useDisputes(filters, 'public');

  const safeDisputes = Array.isArray(disputes) ? disputes : [];
  const stats = useMemo(
    () => ({
      total: summary?.total ?? safeDisputes.length,
      open: summary?.open ?? 0,
      under_review: summary?.under_review ?? 0,
      resolved: summary?.resolved ?? 0,
      closed: summary?.closed ?? 0,
    }),
    [safeDisputes.length, summary],
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Disputes</h1>
        <p className="mt-2 text-sm text-slate-600">Review dispute records sourced from the backend dispute API.</p>
      </div>

      <div className="grid gap-4 sm:grid-cols-4">
        <Card className="p-4"><p className="text-sm text-slate-600">Total</p><p className="mt-2 text-2xl font-semibold text-slate-900">{stats.total}</p></Card>
        <Card className="p-4"><p className="text-sm text-slate-600">Open</p><p className="mt-2 text-2xl font-semibold text-slate-900">{stats.open}</p></Card>
        <Card className="p-4"><p className="text-sm text-slate-600">Resolved</p><p className="mt-2 text-2xl font-semibold text-slate-900">{stats.resolved}</p></Card>
        <Card className="p-4"><p className="text-sm text-slate-600">Closed</p><p className="mt-2 text-2xl font-semibold text-slate-900">{stats.closed}</p></Card>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <div>
          <label className="block text-sm font-medium text-slate-900">Search</label>
          <input
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            className="mt-1 block w-full rounded border border-slate-300 px-3 py-2 text-slate-900"
            placeholder="UUID, order number, reason..."
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-900">Status</label>
          <select
            value={status}
            onChange={(event) => setStatus(event.target.value as 'all' | DisputeWorkflowStatus)}
            className="mt-1 block w-full rounded border border-slate-300 bg-white px-3 py-2 text-slate-900"
          >
            {statusOptions.map((option) => (
              <option key={option} value={option}>
                {option === 'all' ? 'All statuses' : option.replace(/_/g, ' ')}
              </option>
            ))}
          </select>
        </div>
        <div className="flex items-end">
          <Button type="button" variant="secondary" onClick={() => refetch()} className="w-full">
            Refresh
          </Button>
        </div>
      </div>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{error}</div>}

      {loading ? (
        <Card className="p-6 text-center">Loading disputes...</Card>
      ) : safeDisputes.length === 0 ? (
        <Card className="p-6 text-center text-slate-600">No disputes found</Card>
      ) : (
        <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
          {safeDisputes.map((dispute) => (
            <Card key={dispute.uuid} className="p-4">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <p className="font-medium text-slate-900">Order #{dispute.order_number || dispute.order_id || dispute.uuid}</p>
                  <p className="text-sm text-slate-600">{dispute.reason}</p>
                  <p className="mt-2 text-xs text-slate-500">
                    {dispute.raised_by || 'Unknown'} {dispute.raised_by_phone ? `• ${dispute.raised_by_phone}` : ''}
                  </p>
                </div>
                <span className="rounded-full bg-slate-100 px-2 py-1 text-xs font-medium text-slate-700">
                  {dispute.status.replace(/_/g, ' ')}
                </span>
              </div>
              {dispute.description && <p className="mt-3 text-sm text-slate-600">{dispute.description}</p>}
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}

