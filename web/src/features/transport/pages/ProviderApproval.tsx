import { useState } from 'react';
import Card from '../../../shared/components/cards/Card';
import Button from '../../../shared/components/ui/Button';
import { useTransportProviders } from '../hooks/useTransport';

export default function ProviderApproval() {
  const [filter, setFilter] = useState<'pending' | 'approved'>('pending');
  const [approving, setApproving] = useState<number | null>(null);
  const [selectedProviders, setSelectedProviders] = useState<number[]>([]);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);
  const filters = { status: filter } as const;
  const { providers, loading, error, refetch, approveProvider } = useTransportProviders(filters);

  const safeProviders = Array.isArray(providers) ? providers : [];

  const handleApprove = async (providerId: number) => {
    setApproving(providerId);
    try {
      await approveProvider(providerId);
      setSuccessMsg('Transport provider approved successfully');
      setTimeout(() => setSuccessMsg(null), 3000);
      await refetch();
    } catch (err) {
      console.error('Failed to approve provider:', err);
    } finally {
      setApproving(null);
    }
  };

  const toggleProvider = (providerId: number) => {
    setSelectedProviders((prev) =>
      prev.includes(providerId) ? prev.filter((id) => id !== providerId) : [...prev, providerId],
    );
  };

  const toggleSelectAll = () => {
    const pendingIds = safeProviders.filter((provider) => !provider.is_approved && provider.deposit_paid).map((provider) => provider.id);
    setSelectedProviders((prev) => (prev.length === pendingIds.length ? [] : pendingIds));
  };

  const handleBulkApprove = async () => {
    if (selectedProviders.length === 0) return;
    setApproving(-1);
    try {
      await Promise.all(selectedProviders.map((id) => approveProvider(id)));
      setSuccessMsg('Selected providers approved successfully');
      setTimeout(() => setSuccessMsg(null), 3000);
      setSelectedProviders([]);
      await refetch();
    } catch (err) {
      console.error('Failed bulk approve providers:', err);
    } finally {
      setApproving(null);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Transport Provider Approval</h1>
        <p className="mt-2 text-sm text-slate-600">
          Approve transport providers who have paid their deposit and passed verification.
        </p>
      </div>

      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex gap-2">
          <Button variant={filter === 'pending' ? 'secondary' : 'ghost'} onClick={() => setFilter('pending')}>
            Pending ({safeProviders.filter((p) => !p.is_approved).length})
          </Button>
          <Button variant={filter === 'approved' ? 'secondary' : 'ghost'} onClick={() => setFilter('approved')}>
            Approved ({safeProviders.filter((p) => p.is_approved).length})
          </Button>
        </div>
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            onClick={toggleSelectAll}
            disabled={safeProviders.filter((p) => !p.is_approved && p.deposit_paid).length === 0}
          >
            {selectedProviders.length === safeProviders.filter((p) => !p.is_approved && p.deposit_paid).length
              ? 'Clear selection'
              : 'Select all pending'}
          </Button>
          <Button variant="secondary" onClick={handleBulkApprove} disabled={selectedProviders.length === 0 || approving !== null}>
            {approving === -1 ? 'Approving...' : `Approve selected (${selectedProviders.length})`}
          </Button>
        </div>
      </div>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{error}</div>}
      {successMsg && <div className="rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700">{successMsg}</div>}

      {loading ? (
        <Card className="p-6 text-center">Loading transport providers...</Card>
      ) : safeProviders.length === 0 ? (
        <Card className="p-6 text-center text-slate-600">No transport providers found</Card>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="border-b border-slate-200">
              <tr className="text-sm font-semibold text-slate-700">
                <th className="px-4 py-3 text-left">Provider</th>
                <th className="px-4 py-3 text-left">Vehicle Type</th>
                <th className="px-4 py-3 text-left">License Plate</th>
                <th className="px-4 py-3 text-left">Deposit</th>
                <th className="px-4 py-3 text-left">Transaction ID</th>
                <th className="px-4 py-3 text-left">Status</th>
                <th className="px-4 py-3 text-left">Action</th>
              </tr>
            </thead>
            <tbody>
              {safeProviders.map((provider) => (
                <tr key={provider.id} className="border-b border-slate-100 hover:bg-slate-50">
                  <td className="px-4 py-3">
                    <input
                      type="checkbox"
                      checked={selectedProviders.includes(provider.id)}
                      disabled={provider.is_approved || !provider.deposit_paid}
                      onChange={() => toggleProvider(provider.id)}
                    />
                  </td>
                  <td className="px-4 py-3">
                    <div>
                      <p className="font-medium text-slate-900">{provider.user_username || 'Unknown'}</p>
                      <p className="text-xs text-slate-600">{provider.user_phone}</p>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm text-slate-600">{provider.vehicle_type}</td>
                  <td className="px-4 py-3 text-sm text-slate-600">{provider.license_plate}</td>
                  <td className="px-4 py-3 text-sm text-slate-600">
                    {provider.deposit_paid ? `KES ${provider.deposit_amount}` : 'Not paid'}
                  </td>
                  <td className="px-4 py-3 text-xs text-slate-600">{provider.deposit_transaction_id || '-'}</td>
                  <td className="px-4 py-3">
                    <span
                      className={`inline-block rounded-full px-3 py-1 text-xs font-medium ${
                        provider.is_approved ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'
                      }`}
                    >
                      {provider.is_approved ? 'Approved' : 'Pending'}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    {!provider.is_approved && (
                      <Button size="sm" onClick={() => handleApprove(provider.id)} disabled={approving === provider.id}>
                        {approving === provider.id ? 'Approving...' : 'Approve'}
                      </Button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

