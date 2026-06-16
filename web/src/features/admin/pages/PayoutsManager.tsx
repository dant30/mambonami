import { useState } from 'react';
import Card from '../../../shared/components/cards/Card';
import Button from '../../../shared/components/ui/Button';
import { usePayouts } from '../hooks/useAdminData';

export default function PayoutsManager() {
  const [filter, setFilter] = useState<'pending' | 'processing' | 'completed' | 'failed'>('pending');
  const { payouts, loading, error, refetch } = usePayouts(filter);
  const safePayouts = Array.isArray(payouts) ? payouts : [];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Payouts Management</h1>
        <p className="mt-2 text-sm text-slate-600">
          Manage farmer payouts and track M-Pesa transaction status.
        </p>
      </div>

      {/* Filter buttons */}
      <div className="flex flex-wrap gap-2">
        <Button
          variant={filter === 'pending' ? 'primary' : 'outline'}
          onClick={() => setFilter('pending')}
        >
          Pending ({safePayouts.filter(p => p.status === 'pending').length})
        </Button>
        <Button
          variant={filter === 'processing' ? 'primary' : 'outline'}
          onClick={() => setFilter('processing')}
        >
          Processing ({safePayouts.filter(p => p.status === 'processing').length})
        </Button>
        <Button
          variant={filter === 'completed' ? 'primary' : 'outline'}
          onClick={() => setFilter('completed')}
        >
          Completed ({safePayouts.filter(p => p.status === 'completed').length})
        </Button>
        <Button
          variant={filter === 'failed' ? 'primary' : 'outline'}
          onClick={() => setFilter('failed')}
        >
          Failed ({safePayouts.filter(p => p.status === 'failed').length})
        </Button>
      </div>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{error}</div>}

      {loading ? (
        <Card className="p-6 text-center">Loading payouts...</Card>
      ) : safePayouts.length === 0 ? (
        <Card className="p-6 text-center text-slate-600">No payouts found</Card>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="border-b border-slate-200">
              <tr className="text-sm font-semibold text-slate-700">
                <th className="px-4 py-3 text-left">Farmer</th>
                <th className="px-4 py-3 text-left">Phone</th>
                <th className="px-4 py-3 text-right">Amount</th>
                <th className="px-4 py-3 text-left">Status</th>
                <th className="px-4 py-3 text-left">M-Pesa Transaction</th>
                <th className="px-4 py-3 text-left">Created</th>
                <th className="px-4 py-3 text-left">Action</th>
              </tr>
            </thead>
            <tbody>
              {safePayouts.map((payout) => (
                <tr key={payout.uuid} className="border-b border-slate-100 hover:bg-slate-50">
                  <td className="px-4 py-3 font-medium text-slate-900">{payout.farmer_name}</td>
                  <td className="px-4 py-3 text-sm text-slate-600">{payout.farmer_phone}</td>
                  <td className="px-4 py-3 text-right font-medium text-slate-900">
                    KES {payout.amount.toLocaleString()}
                  </td>
                  <td className="px-4 py-3">
                    <span className={`inline-block rounded-full px-3 py-1 text-xs font-medium ${
                      payout.status === 'completed'
                        ? 'bg-green-100 text-green-700'
                        : payout.status === 'failed'
                          ? 'bg-red-100 text-red-700'
                          : payout.status === 'processing'
                            ? 'bg-blue-100 text-blue-700'
                            : 'bg-yellow-100 text-yellow-700'
                    }`}>
                      {payout.status.charAt(0).toUpperCase() + payout.status.slice(1)}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-xs text-slate-600">
                    {payout.mpesa_transaction_id || '-'}
                  </td>
                  <td className="px-4 py-3 text-sm text-slate-600">
                    {new Date(payout.created_at).toLocaleDateString()}
                  </td>
                  <td className="px-4 py-3">
                    {payout.status === 'failed' && (
                      <>
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => refetch()}
                          className="mb-1"
                        >
                          Retry
                        </Button>
                        {payout.error_message && (
                          <p className="text-xs text-red-600">{payout.error_message}</p>
                        )}
                      </>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Summary cards */}
      <div className="grid gap-4 sm:grid-cols-3">
        <Card className="p-4">
          <p className="text-sm text-slate-600">Total Payouts</p>
          <p className="mt-2 text-2xl font-semibold text-slate-900">
            KES {safePayouts.reduce((sum, p) => sum + p.amount, 0).toLocaleString()}
          </p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-slate-600">Completed</p>
          <p className="mt-2 text-2xl font-semibold text-green-600">
            KES {safePayouts
              .filter(p => p.status === 'completed')
              .reduce((sum, p) => sum + p.amount, 0)
              .toLocaleString()}
          </p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-slate-600">Pending/Failed</p>
          <p className="mt-2 text-2xl font-semibold text-red-600">
            KES {safePayouts
              .filter(p => p.status !== 'completed')
              .reduce((sum, p) => sum + p.amount, 0)
              .toLocaleString()}
          </p>
        </Card>
      </div>
    </div>
  );
}
