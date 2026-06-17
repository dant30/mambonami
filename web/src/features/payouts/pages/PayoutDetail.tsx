import { useEffect } from 'react';
import { useParams } from 'react-router-dom';
import Card from '../../../shared/components/cards/Card';
import { usePayouts } from '../hooks/usePayouts';

export default function PayoutDetail() {
  const { uuid } = useParams();
  const { selectedPayout, selectPayout, loading, error } = usePayouts();

  useEffect(() => {
    if (uuid) {
      void selectPayout(uuid);
    }
  }, [selectPayout, uuid]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Payout Detail</h1>
        <p className="mt-2 text-sm text-slate-600">Inspect an individual payout record.</p>
      </div>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{error}</div>}

      {loading ? (
        <Card className="p-6 text-center">Loading payout...</Card>
      ) : selectedPayout ? (
        <Card className="p-6">
          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <p className="text-sm text-slate-600">UUID</p>
              <p className="font-medium text-slate-900">{selectedPayout.uuid}</p>
            </div>
            <div>
              <p className="text-sm text-slate-600">Status</p>
              <p className="font-medium text-slate-900">{selectedPayout.status}</p>
            </div>
            <div>
              <p className="text-sm text-slate-600">Farmer</p>
              <p className="font-medium text-slate-900">{selectedPayout.farmer_name}</p>
            </div>
            <div>
              <p className="text-sm text-slate-600">Phone</p>
              <p className="font-medium text-slate-900">{selectedPayout.farmer_phone}</p>
            </div>
          </div>
        </Card>
      ) : (
        <Card className="p-6 text-center text-slate-600">No payout selected.</Card>
      )}
    </div>
  );
}

