import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { adminResourceCaches, listAdminAuditLogs, useAdminResource } from '../../../../core/lib'
import type { AdminAuditLog } from '../../../../core/lib/types/admin'
import { AuditActionLabel } from './components/AuditActionLabel'

export function AuditAdminPage() {
	const { data, loading, error, notice, refresh } = useAdminResource(listAdminAuditLogs, adminResourceCaches.auditLogs)
	const logs = data ?? []
	const columns = [
		{ header: 'Action', render: (log: AdminAuditLog) => <AuditActionLabel action={log.action} /> },
		{ header: 'Actor', render: (log: AdminAuditLog) => log.actor_phone || `User ${log.actor ?? 'system'}` },
		{ header: 'Resource', render: (log: AdminAuditLog) => `${log.resource_type || 'Resource'} ${log.resource_id ?? ''}` },
		{ header: 'Description', render: (log: AdminAuditLog) => log.description || '—' },
		{ header: 'When', render: (log: AdminAuditLog) => log.created_at ? new Date(log.created_at).toLocaleString() : 'Not recorded' },
	]
	return <AdminPageLayout section="audit" title="Audit log" loading={loading} error={error} notice={notice} onRefresh={refresh}><DataTable data={logs} columns={columns} keyExtractor={(log) => log.uuid} emptyMessage="No audit events found." /></AdminPageLayout>
}