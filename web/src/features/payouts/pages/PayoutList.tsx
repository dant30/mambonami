import { useMemo, useState } from 'react';
import Card from '../../../shared/components/cards/Card';
import Button from '../../../shared/components/ui/Button';
import { usePayouts } from '../hooks/usePayouts';
import type { PayoutListFilters } from '../types';

const statusOptions: Array<NonNullable<PayoutListFilters['status']>> = ['all', 'pending', 'processing', 'completed', 'failed'];

export default function PayoutList() {
  const [status, setStatus] = useState<NonNullable<PayoutListFilters['status']>>('all');
  const [search, setSearch] = useState('');
  const trimmedSearch = search.trim();
  const { payouts, loading, error, summary, refetch, selectPayout, selectedPayout } = usePayouts(
    useMemo(
      () => ({
        status,
        search: trimmedSearch,
      }),
      [status, trimmedSearch],
    ),
  );

  const safePayouts = Array.isArray(payouts) ? payouts : [];

  const totals = useMemo(
    () => ({
      total: summary?.total ?? safePayouts.length,
      pending: summary?.pending ?? 0,
      processing: summary?.processing ?? 0,
      completed: summary?.completed ?? 0,
      failed: summary?.failed ?? 0,
    }),
    [safePayouts.length, summary],
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Payouts Management</h1>
        <p className="mt-2 text-sm text-slate-600">
          Track payout status, transaction references, and payment failures.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-5">
        <Card className="p-4"><p className="text-sm text-slate-600">Total</p><p className="mt-2 text-2xl font-semibold text-slate-900">{totals.total}</p></Card>
        <Card className="p-4"><p className="text-sm text-slate-600">Pending</p><p className="mt-2 text-2xl font-semibold text-slate-900">{totals.pending}</p></Card>
        <Card className="p-4"><p className="text-sm text-slate-600">Processing</p><p className="mt-2 text-2xl font-semibold text-slate-900">{totals.processing}</p></Card>
        <Card className="p-4"><p className="text-sm text-slate-600">Completed</p><p className="mt-2 text-2xl font-semibold text-slate-900">{totals.completed}</p></Card>
        <Card className="p-4"><p className="text-sm text-slate-600">Failed</p><p className="mt-2 text-2xl font-semibold text-slate-900">{totals.failed}</p></Card>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <div>
          <label className="block text-sm font-medium text-slate-900">Search</label>
          <input
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            className="mt-1 block w-full rounded border border-slate-300 px-3 py-2 text-slate-900"
            placeholder="Farmer, phone, reference..."
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-900">Status</label>
          <select
            value={status}
            onChange={(event) => setStatus(event.target.value as NonNullable<PayoutListFilters['status']>)}
            className="mt-1 block w-full rounded border border-slate-300 bg-white px-3 py-2 text-slate-900"
          >
            {statusOptions.map((option) => (
              <option key={option} value={option}>
                {option === 'all' ? 'All statuses' : option.charAt(0).toUpperCase() + option.slice(1)}
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
        <Card className="p-6 text-center">Loading payouts...</Card>
      ) : safePayouts.length === 0 ? (
        <Card className="p-6 text-center text-slate-600">No payouts found</Card>
      ) : (
        <div className="grid gap-3 lg:grid-cols-2">
          {safePayouts.map((payout) => (
            <Card key={payout.uuid} className="p-4">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <p className="font-medium text-slate-900">{payout.farmer_name}</p>
                  <p className="text-sm text-slate-600">{payout.farmer_phone}</p>
                  <p className="mt-2 text-sm font-semibold text-slate-900">KES {payout.amount.toLocaleString()}</p>
                </div>
                <span
                  className={`inline-block rounded-full px-3 py-1 text-xs font-medium ${
                    payout.status === 'completed' || payout.status === 'paid'
                      ? 'bg-green-100 text-green-700'
                      : payout.status === 'failed'
                        ? 'bg-red-100 text-red-700'
                        : payout.status === 'processing'
                          ? 'bg-blue-100 text-blue-700'
                          : 'bg-yellow-100 text-yellow-700'
                  }`}
                >
                  {payout.status.charAt(0).toUpperCase() + payout.status.slice(1)}
                </span>
              </div>

              <div className="mt-4 grid gap-2 text-sm text-slate-600 sm:grid-cols-2">
                <div>
                  <p className="text-xs uppercase tracking-wide text-slate-500">Reference</p>
                  <p>{payout.mpesa_transaction_id || payout.reference || '-'}</p>
                </div>
                <div>
                  <p className="text-xs uppercase tracking-wide text-slate-500">Created</p>
                  <p>{new Date(payout.created_at).toLocaleString()}</p>
                </div>
              </div>

              {payout.error_message && <p className="mt-3 text-sm text-red-600">{payout.error_message}</p>}

              <div className="mt-4 flex gap-2">
                <Button type="button" variant="outline" size="sm" onClick={() => selectPayout(payout.uuid)}>
                  View
                </Button>
                {(payout.status === 'failed' || payout.status === 'pending') && (
                  <Button type="button" variant="secondary" size="sm" onClick={() => refetch()}>
                    Retry refresh
                  </Button>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}

      {selectedPayout && (
        <Card className="p-6">
          <h3 className="text-lg font-semibold text-slate-900">Selected Payout</h3>
          <p className="mt-2 text-sm text-slate-600">{selectedPayout.uuid}</p>
        </Card>
      )}
    </div>
  );
}

