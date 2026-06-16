import { useState } from 'react';
import Card from '../../../shared/components/cards/Card';
import { useAuditLogs } from '../hooks/useAdminData';

export default function AuditLog() {
  const [searchUser, setSearchUser] = useState('');
  const [searchAction, setSearchAction] = useState('');
  const [searchModel, setSearchModel] = useState('');
  
  const { logs, loading, error } = useAuditLogs({
    user: searchUser || undefined,
    action: searchAction || undefined,
    model: searchModel || undefined,
  });

  const safeLogs = Array.isArray(logs) ? logs : [];
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Audit Log</h1>
        <p className="mt-2 text-sm text-slate-600">
          Review all admin actions performed on the platform. This log is read-only for audit purposes.
        </p>
      </div>

      {/* Search filters */}
      <div className="grid gap-4 sm:grid-cols-3">
        <div>
          <label className="block text-sm font-medium text-slate-900">Search by Admin</label>
          <input
            type="text"
            placeholder="Username..."
            value={searchUser}
            onChange={(e) => setSearchUser(e.target.value)}
            className="mt-1 block w-full rounded border border-slate-300 px-3 py-2 text-slate-900 placeholder-slate-400"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-900">Search by Action</label>
          <input
            type="text"
            placeholder="e.g., approve, suspend..."
            value={searchAction}
            onChange={(e) => setSearchAction(e.target.value)}
            className="mt-1 block w-full rounded border border-slate-300 px-3 py-2 text-slate-900 placeholder-slate-400"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-900">Search by Model</label>
          <input
            type="text"
            placeholder="e.g., Farmer, Dispute..."
            value={searchModel}
            onChange={(e) => setSearchModel(e.target.value)}
            className="mt-1 block w-full rounded border border-slate-300 px-3 py-2 text-slate-900 placeholder-slate-400"
          />
        </div>
      </div>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{error}</div>}

      {loading ? (
        <Card className="p-6 text-center">Loading audit logs...</Card>
      ) : safeLogs.length === 0 ? (
        <Card className="p-6 text-center text-slate-600">No audit logs found</Card>
      ) : (
        <div className="space-y-3">
          {safeLogs.map((log) => (
            <Card key={log.uuid} className="p-4">
              <div className="flex items-start justify-between gap-4">
                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <p className="font-semibold text-slate-900">{log.action}</p>
                    <span className="rounded-full bg-slate-100 px-2 py-1 text-xs font-medium text-slate-700">
                      {log.model_name}
                    </span>
                  </div>
                  <p className="mt-1 text-sm text-slate-600">{log.object_repr || 'Object details'}</p>
                  <div className="mt-2 flex flex-wrap gap-3 text-xs text-slate-500">
                    <span>
                      <strong>Admin:</strong> {log.admin_username}
                    </span>
                    <span>
                      <strong>Time:</strong>{' '}
                      {new Date(log.timestamp).toLocaleString()}
                    </span>
                  </div>
                  {Object.keys(log.changes).length > 0 && (
                    <details className="mt-2">
                      <summary className="cursor-pointer text-xs font-medium text-slate-700">
                        View Changes
                      </summary>
                      <pre className="mt-2 overflow-x-auto rounded bg-slate-50 p-2 text-xs text-slate-600">
                        {JSON.stringify(log.changes, null, 2)}
                      </pre>
                    </details>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      <div className="text-center text-sm text-slate-600">
        Total records: {safeLogs.length}
      </div>
    </div>
  );
}

