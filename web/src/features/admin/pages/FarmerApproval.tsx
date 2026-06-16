import { useState } from 'react';
import Card from '../../../shared/components/cards/Card';
import Button from '../../../shared/components/ui/Button';
import { useFarmers } from '../hooks/useAdminData';
import { approveFarmer } from '../services/adminService';

export default function FarmerApproval() {
  const [filter, setFilter] = useState<'pending' | 'approved'>('pending');
  const [approving, setApproving] = useState<number | null>(null);
  const [selectedFarmers, setSelectedFarmers] = useState<number[]>([]);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);
  const { farmers, loading, error, refetch } = useFarmers(filter);

  const handleApprove = async (farmerId: number) => {
    setApproving(farmerId);
    try {
      await approveFarmer(farmerId);
      setSuccessMsg('Farmer approved successfully');
      setTimeout(() => setSuccessMsg(null), 3000);
      await refetch();
    } catch (err) {
      console.error('Failed to approve farmer:', err);
    } finally {
      setApproving(null);
    }
  };

  const toggleFarmer = (farmerId: number) => {
    setSelectedFarmers((prev) =>
      prev.includes(farmerId) ? prev.filter((id) => id !== farmerId) : [...prev, farmerId],
    );
  };

  const toggleSelectAll = () => {
    const pendingIds = farmers.filter((farmer) => !farmer.coop_verified).map((farmer) => farmer.id);
    setSelectedFarmers((prev) =>
      prev.length === pendingIds.length ? [] : pendingIds,
    );
  };

  const handleBulkApprove = async () => {
    if (selectedFarmers.length === 0) return;
    setApproving(-1);
    try {
      await Promise.all(selectedFarmers.map((id) => approveFarmer(id)));
      setSuccessMsg('Selected farmers approved successfully');
      setTimeout(() => setSuccessMsg(null), 3000);
      setSelectedFarmers([]);
      await refetch();
    } catch (err) {
      console.error('Failed bulk approve farmers:', err);
    } finally {
      setApproving(null);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Farmer Approval</h1>
        <p className="mt-2 text-sm text-slate-600">
          Review and approve farmers with verified farm information and cooperative membership.
        </p>
      </div>

      {/* Filter buttons */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex gap-2">
          <Button
            variant={filter === 'pending' ? 'secondary' : 'ghost'}
            onClick={() => setFilter('pending')}
          >
            Pending ({farmers.filter((f) => !f.coop_verified).length})
          </Button>
          <Button
            variant={filter === 'approved' ? 'secondary' : 'ghost'}
            onClick={() => setFilter('approved')}
          >
            Approved ({farmers.filter((f) => f.coop_verified).length})
          </Button>
        </div>
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            onClick={toggleSelectAll}
            disabled={farmers.filter((f) => !f.coop_verified).length === 0}
          >
            {selectedFarmers.length === farmers.filter((f) => !f.coop_verified).length ? 'Clear selection' : 'Select all pending'}
          </Button>
          <Button
            variant="secondary"
            onClick={handleBulkApprove}
            disabled={selectedFarmers.length === 0 || approving !== null}
          >
            {approving === -1 ? 'Approving...' : `Approve selected (${selectedFarmers.length})`}
          </Button>
        </div>
      </div>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{error}</div>}
      {successMsg && <div className="rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700">{successMsg}</div>}

      {loading ? (
        <Card className="p-6 text-center">Loading farmers...</Card>
      ) : farmers.length === 0 ? (
        <Card className="p-6 text-center text-slate-600">No farmers found</Card>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="border-b border-slate-200">
              <tr className="text-sm font-semibold text-slate-700">
                <th className="px-4 py-3 text-left">
                  <input
                    type="checkbox"
                    checked={selectedFarmers.length === farmers.filter((f) => !f.coop_verified).length && farmers.filter((f) => !f.coop_verified).length > 0}
                    onChange={toggleSelectAll}
                  />
                </th>
                <th className="px-4 py-3 text-left">Farmer</th>
                <th className="px-4 py-3 text-left">Phone</th>
                <th className="px-4 py-3 text-left">Cooperative</th>
                <th className="px-4 py-3 text-left">Farm GPS</th>
                <th className="px-4 py-3 text-left">M-Pesa</th>
                <th className="px-4 py-3 text-left">Rating</th>
                <th className="px-4 py-3 text-left">Sales</th>
                <th className="px-4 py-3 text-left">Status</th>
                <th className="px-4 py-3 text-left">Action</th>
              </tr>
            </thead>
            <tbody>
              {farmers.map((farmer) => (
                <tr key={farmer.id} className="border-b border-slate-100 hover:bg-slate-50">
                  <td className="px-4 py-3">
                    <input
                      type="checkbox"
                      checked={selectedFarmers.includes(farmer.id)}
                      disabled={farmer.coop_verified}
                      onChange={() => toggleFarmer(farmer.id)}
                    />
                  </td>
                  <td className="px-4 py-3">
                    <p className="font-medium text-slate-900">{farmer.user_username || 'Unknown'}</p>
                    <p className="text-xs text-slate-600">{farmer.user_email}</p>
                  </td>
                  <td className="px-4 py-3 text-sm text-slate-600">{farmer.user_phone}</td>
                  <td className="px-4 py-3 text-sm text-slate-600">{farmer.coop_name || '-'}</td>
                  <td className="px-4 py-3 text-xs text-slate-600">{farmer.farm_gps || '-'}</td>
                  <td className="px-4 py-3 text-sm text-slate-600">{farmer.mpesa_number || '-'}</td>
                  <td className="px-4 py-3 text-sm text-slate-900">
                    {farmer.rating ? `${farmer.rating.toFixed(1)} ⭐` : '-'}
                  </td>
                  <td className="px-4 py-3 text-sm text-slate-600">KES {farmer.total_sales?.toLocaleString() || 0}</td>
                  <td className="px-4 py-3">
                    <span className={`inline-block rounded-full px-3 py-1 text-xs font-medium ${
                      farmer.coop_verified
                        ? 'bg-green-100 text-green-700'
                        : 'bg-yellow-100 text-yellow-700'
                    }`}>
                      {farmer.coop_verified ? 'Verified' : 'Pending'}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    {!farmer.coop_verified && (
                      <Button
                        size="sm"
                        onClick={() => handleApprove(farmer.id)}
                        disabled={approving === farmer.id}
                      >
                        {approving === farmer.id ? 'Approving...' : 'Approve'}
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

