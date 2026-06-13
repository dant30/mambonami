import { useEffect, useState } from 'react';
import Card from '../../../shared/components/cards/Card';
import Button from '../../../shared/components/ui/Button';
import { approveFarmer, listFarmers } from '../services/adminService';

type FarmerRow = {
  id: number;
  user_phone?: string;
  user_username?: string;
  farm_gps?: string;
  coop_verified?: boolean;
  total_sales?: number;
};

export default function FarmerApproval() {
  const [farmers, setFarmers] = useState<FarmerRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadFarmers = async () => {
    setLoading(true);
    setError(null);
    try {
      setFarmers(await listFarmers());
    } catch {
      setError('Unable to load farmer approvals.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadFarmers();
  }, []);

  const handleApprove = async (farmerId: number) => {
    await approveFarmer(farmerId);
    await loadFarmers();
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Farmer approval</h1>
        <p className="mt-2 text-sm text-slate-600">Verify farmer profiles using the admin-only API.</p>
      </div>

      {error ? <div className="rounded-3xl border border-red-200 bg-red-50 px-4 py-4 text-sm text-red-700">{error}</div> : null}

      {loading ? (
        <Card className="p-6">Loading farmers...</Card>
      ) : (
        <div className="grid gap-4">
          {farmers.map((farmer) => (
            <Card key={farmer.id} className="flex items-center justify-between gap-4 p-4">
              <div>
                <p className="font-semibold text-slate-900">{farmer.user_username || farmer.user_phone || `Farmer ${farmer.id}`}</p>
                <p className="text-sm text-slate-600">{farmer.user_phone || 'No phone'} • {farmer.coop_verified ? 'Verified' : 'Pending'}</p>
              </div>
              <Button type="button" disabled={Boolean(farmer.coop_verified)} onClick={() => handleApprove(farmer.id)}>
                {farmer.coop_verified ? 'Verified' : 'Verify'}
              </Button>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}

