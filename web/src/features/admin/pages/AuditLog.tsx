import { useEffect, useState } from 'react';
import Card from '../../../shared/components/cards/Card';
import { listAuditLogs } from '../services/adminService';

type AuditRow = {
  uuid: string;
  action?: string;
  model_name?: string;
  object_repr?: string;
  timestamp?: string;
};

export default function AuditLog() {
  const [logs, setLogs] = useState<AuditRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadLogs = async () => {
      setLoading(true);
      setError(null);
      try {
        setLogs(await listAuditLogs());
      } catch {
        setError('Unable to load audit logs.');
      } finally {
        setLoading(false);
      }
    };

    loadLogs();
  }, []);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Audit log</h1>
        <p className="mt-2 text-sm text-slate-600">Review privileged actions from the admin-only audit API.</p>
      </div>

      {error ? <div className="rounded-3xl border border-red-200 bg-red-50 px-4 py-4 text-sm text-red-700">{error}</div> : null}

      {loading ? (
        <Card className="p-6">Loading audit logs...</Card>
      ) : (
        <div className="grid gap-4">
          {logs.map((log) => (
            <Card key={log.uuid} className="p-4">
              <p className="font-semibold text-slate-900">{log.action || 'Action'}</p>
              <p className="text-sm text-slate-600">{log.model_name || 'Model'} • {log.object_repr || 'Object'}</p>
              <p className="mt-2 text-xs text-slate-500">{log.timestamp || ''}</p>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}

