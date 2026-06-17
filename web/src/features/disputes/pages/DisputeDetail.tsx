import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import Card from '../../../shared/components/cards/Card';
import { useDisputes } from '../hooks/useDisputes';

export default function DisputeDetail() {
  const { uuid } = useParams();
  const { selectedDispute, selectDispute, loading, error } = useDisputes(undefined, 'public');
  const [localError, setLocalError] = useState<string | null>(null);

  useEffect(() => {
    const load = async () => {
      if (!uuid) return;
      setLocalError(null);
      try {
        await selectDispute(uuid);
      } catch {
        setLocalError('Failed to load dispute details');
      }
    };

    void load();
  }, [selectDispute, uuid]);

  const dispute = selectedDispute;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Dispute Detail</h1>
        <p className="mt-2 text-sm text-slate-600">Inspect the current dispute record and review its status.</p>
      </div>

      {(error || localError) && (
        <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {error || localError}
        </div>
      )}

      {loading ? (
        <Card className="p-6 text-center">Loading dispute...</Card>
      ) : dispute ? (
        <Card className="p-6">
          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <p className="text-sm text-slate-600">UUID</p>
              <p className="font-medium text-slate-900">{dispute.uuid}</p>
            </div>
            <div>
              <p className="text-sm text-slate-600">Status</p>
              <p className="font-medium text-slate-900">{dispute.status.replace(/_/g, ' ')}</p>
            </div>
            <div>
              <p className="text-sm text-slate-600">Order</p>
              <p className="font-medium text-slate-900">{dispute.order_number || dispute.order_id || '—'}</p>
            </div>
            <div>
              <p className="text-sm text-slate-600">Raised By</p>
              <p className="font-medium text-slate-900">{dispute.raised_by || '—'}</p>
            </div>
          </div>
          {dispute.description && <p className="mt-4 text-sm text-slate-600">{dispute.description}</p>}
        </Card>
      ) : (
        <Card className="p-6 text-center text-slate-600">No dispute selected.</Card>
      )}
    </div>
  );
}

