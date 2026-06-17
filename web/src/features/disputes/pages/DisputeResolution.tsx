import { useMemo, useState } from 'react';
import Card from '../../../shared/components/cards/Card';
import Button from '../../../shared/components/ui/Button';
import { useDisputes } from '../hooks/useDisputes';
import type { DisputeRecord, DisputeResolutionForm, DisputeWorkflowStatus } from '../types';

export default function DisputeResolution() {
  const [filter, setFilter] = useState<DisputeWorkflowStatus>('open');
  const [selectedDispute, setSelectedDispute] = useState<DisputeRecord | null>(null);
  const [resolving, setResolving] = useState<string | null>(null);
  const [form, setForm] = useState<DisputeResolutionForm>({
    resolution_type: 'full_refund',
  });
  const [error, setError] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);
  const { disputes, loading, refetch, resolveDispute: submitResolution } = useDisputes(
    { status: filter },
    'admin',
  );

  const safeDisputes = Array.isArray(disputes) ? disputes : [];

  const counts = useMemo(
    () => ({
      open: safeDisputes.filter((dispute) => dispute.status === 'open').length,
      under_review: safeDisputes.filter((dispute) => dispute.status === 'under_review').length,
      resolved: safeDisputes.filter((dispute) => dispute.status === 'resolved').length,
    }),
    [safeDisputes],
  );

  const handleSubmitResolution = async (disputeUuid: string) => {
    setError(null);
    setResolving(disputeUuid);
    try {
      await submitResolution(disputeUuid, form);
      setSuccessMsg('Dispute resolved successfully');
      setTimeout(() => setSuccessMsg(null), 3000);
      setSelectedDispute(null);
      await refetch();
    } catch (err) {
      setError('Failed to resolve dispute');
      console.error('Error:', err);
    } finally {
      setResolving(null);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Dispute Resolution</h1>
        <p className="mt-2 text-sm text-slate-600">
          Review and resolve open disputes between buyers and farmers/providers.
        </p>
      </div>

      <div className="flex gap-2">
        <Button variant={filter === 'open' ? 'primary' : 'outline'} onClick={() => setFilter('open')}>
          Open ({counts.open})
        </Button>
        <Button
          variant={filter === 'under_review' ? 'primary' : 'outline'}
          onClick={() => setFilter('under_review')}
        >
          Under Review ({counts.under_review})
        </Button>
        <Button
          variant={filter === 'resolved' ? 'primary' : 'outline'}
          onClick={() => setFilter('resolved')}
        >
          Resolved ({counts.resolved})
        </Button>
      </div>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{error}</div>}
      {successMsg && <div className="rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700">{successMsg}</div>}

      <div className="grid gap-6 lg:grid-cols-3">
        <div className="lg:col-span-1">
          {loading ? (
            <Card className="p-6 text-center">Loading disputes...</Card>
          ) : safeDisputes.length === 0 ? (
            <Card className="p-6 text-center text-slate-600">No disputes found</Card>
          ) : (
            <div className="space-y-2">
              {safeDisputes.map((dispute) => (
                <Card
                  key={dispute.uuid}
                  className={`cursor-pointer p-4 transition ${
                    selectedDispute?.uuid === dispute.uuid
                      ? 'border-blue-300 bg-blue-50'
                      : 'hover:bg-slate-50'
                  }`}
                  onClick={() => setSelectedDispute(dispute)}
                >
                  <p className="font-medium text-slate-900">Order #{dispute.order_number || dispute.order_id || dispute.uuid}</p>
                  <p className="text-xs text-slate-600">{dispute.reason}</p>
                  <span
                    className={`mt-2 inline-block rounded px-2 py-1 text-xs font-medium ${
                      dispute.status === 'open'
                        ? 'bg-red-100 text-red-700'
                        : dispute.status === 'under_review'
                          ? 'bg-yellow-100 text-yellow-700'
                          : 'bg-green-100 text-green-700'
                    }`}
                  >
                    {dispute.status.replace(/_/g, ' ')}
                  </span>
                </Card>
              ))}
            </div>
          )}
        </div>

        <div className="lg:col-span-2">
          {selectedDispute ? (
            <div className="space-y-4">
              <Card className="p-6">
                <h3 className="text-lg font-semibold text-slate-900">Dispute Details</h3>
                <div className="mt-4 space-y-3 border-t border-slate-200 pt-4">
                  <div>
                    <p className="text-xs font-medium text-slate-600">ORDER</p>
                    <p className="text-sm text-slate-900">#{selectedDispute.order_number || selectedDispute.order_id || selectedDispute.uuid}</p>
                  </div>
                  <div>
                    <p className="text-xs font-medium text-slate-600">RAISED BY</p>
                    <p className="text-sm text-slate-900">{selectedDispute.raised_by || '—'}</p>
                    <p className="text-xs text-slate-600">{selectedDispute.raised_by_phone || '—'}</p>
                  </div>
                  <div>
                    <p className="text-xs font-medium text-slate-600">REASON</p>
                    <p className="text-sm text-slate-900">{selectedDispute.reason}</p>
                  </div>
                  <div>
                    <p className="text-xs font-medium text-slate-600">DESCRIPTION</p>
                    <p className="text-sm text-slate-600">{selectedDispute.description || '—'}</p>
                  </div>
                  <div>
                    <p className="text-xs font-medium text-slate-600">CREATED</p>
                    <p className="text-sm text-slate-600">
                      {selectedDispute.created_at ? new Date(selectedDispute.created_at).toLocaleString() : '—'}
                    </p>
                  </div>
                </div>
              </Card>

              {selectedDispute.status !== 'resolved' && selectedDispute.status !== 'closed' && (
                <Card className="p-6">
                  <h3 className="text-lg font-semibold text-slate-900">Resolve Dispute</h3>
                  <div className="mt-4 space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-900">Resolution Type</label>
                      <select
                        className="mt-1 block w-full rounded border border-slate-300 px-3 py-2 text-slate-900"
                        value={form.resolution_type}
                        onChange={(e) =>
                          setForm({
                            ...form,
                            resolution_type: e.target.value as DisputeResolutionForm['resolution_type'],
                          })
                        }
                      >
                        <option value="full_refund">Full Refund</option>
                        <option value="partial_refund">Partial Refund</option>
                        <option value="penalty">Apply Penalty</option>
                        <option value="no_action">No Action</option>
                      </select>
                    </div>

                    {(form.resolution_type === 'partial_refund' || form.resolution_type === 'penalty') && (
                      <div>
                        <label className="block text-sm font-medium text-slate-900">Amount (KES)</label>
                        <input
                          type="number"
                          className="mt-1 block w-full rounded border border-slate-300 px-3 py-2 text-slate-900"
                          placeholder="Enter amount"
                          value={form.resolved_amount || ''}
                          onChange={(e) =>
                            setForm({
                              ...form,
                              resolved_amount: e.target.value ? Number(e.target.value) : undefined,
                            })
                          }
                        />
                      </div>
                    )}

                    <div>
                      <label className="block text-sm font-medium text-slate-900">Resolution Notes</label>
                      <textarea
                        className="mt-1 block w-full rounded border border-slate-300 px-3 py-2 text-slate-900"
                        placeholder="Add notes about this resolution"
                        rows={3}
                        value={form.notes || ''}
                        onChange={(e) =>
                          setForm({
                            ...form,
                            notes: e.target.value,
                          })
                        }
                      />
                    </div>

                    <Button
                      onClick={() => handleSubmitResolution(selectedDispute.uuid)}
                      disabled={resolving === selectedDispute.uuid}
                      className="w-full"
                    >
                      {resolving === selectedDispute.uuid ? 'Resolving...' : 'Resolve Dispute'}
                    </Button>
                  </div>
                </Card>
              )}

              {(selectedDispute.status === 'resolved' || selectedDispute.status === 'closed') && (
                <Card className="border-green-200 bg-green-50 p-6">
                  <h3 className="font-semibold text-green-900">Dispute Resolved</h3>
                  <div className="mt-3 space-y-2 text-sm text-green-800">
                    <p>Resolution Type: {selectedDispute.resolution_type}</p>
                    {selectedDispute.resolved_amount && <p>Amount: KES {selectedDispute.resolved_amount}</p>}
                    <p>
                      Resolved At:{' '}
                      {selectedDispute.resolved_at ? new Date(selectedDispute.resolved_at).toLocaleString() : '—'}
                    </p>
                  </div>
                </Card>
              )}
            </div>
          ) : (
            <Card className="flex h-64 items-center justify-center p-6 text-slate-600">
              Select a dispute to view details and resolve
            </Card>
          )}
        </div>
      </div>
    </div>
  );
}

