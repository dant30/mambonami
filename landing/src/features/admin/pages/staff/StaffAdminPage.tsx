import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { activateAdminUser, adminResourceCaches, listAdminUsers, suspendAdminUser, useAdminResource } from '../../../../core/lib'
import type { AdminUser } from '../../../../core/lib/types/admin'
import { StaffAccountStatus } from './components/StaffAccountStatus'

export function StaffAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminUsers, adminResourceCaches.users)
	const staff = (data ?? []).filter((user) => user.is_staff || user.is_superuser)
	const toggle = (member: AdminUser) => {
		const suspend = member.is_active
		if (!window.confirm(`${suspend ? 'Suspend' : 'Activate'} ${member.display_name || member.phone}?`)) return
		void runAction(String(member.id), () => suspend ? suspendAdminUser(member.id) : activateAdminUser(member.id), suspend ? 'Staff account suspended.' : 'Staff account activated.')
	}
	const columns = [
		{ header: 'Staff member', render: (member: AdminUser) => <div><p className="font-semibold">{member.display_name || member.username || member.phone}</p><p className="text-xs text-muted-foreground">{member.phone} · {member.email || 'No email'}</p></div> },
		{ header: 'Access', render: (member: AdminUser) => member.is_superuser ? 'Superuser' : 'Staff' },
		{ header: 'Account', render: (member: AdminUser) => member.is_active ? 'Active' : 'Suspended' },
		{ header: 'Last seen', render: (member: AdminUser) => member.last_seen ? new Date(member.last_seen).toLocaleString() : 'Not recorded' },
		{ header: 'Action', render: (member: AdminUser) => <StaffAccountStatus member={member} busy={busy === String(member.id)} onToggle={() => toggle(member)} /> },
	]
	return <AdminPageLayout section="staff" title="Staff" loading={loading} error={error} notice={notice} onRefresh={refresh}><DataTable data={staff} columns={columns} keyExtractor={(member) => String(member.id)} emptyMessage="No staff accounts found." /></AdminPageLayout>
}