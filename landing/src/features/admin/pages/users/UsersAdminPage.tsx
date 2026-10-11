import { useState } from 'react'

import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { activateAdminUser, adminResourceCaches, listAdminUsers, suspendAdminUser, useAdminResource } from '../../../../core/lib'
import type { AdminUser } from '../../../../core/lib/types/admin'
import { UserStatusAction } from './components/UserStatusAction'

export function UsersAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminUsers, adminResourceCaches.users)
	const [query, setQuery] = useState('')
	const users = (data ?? []).filter((user) => `${user.display_name ?? ''} ${user.phone} ${user.email ?? ''} ${user.role}`.toLowerCase().includes(query.trim().toLowerCase()))
	const toggle = (user: AdminUser) => {
		const suspend = user.is_active
		if (!window.confirm(`${suspend ? 'Suspend' : 'Activate'} ${user.display_name || user.phone}?`)) return
		void runAction(String(user.id), () => suspend ? suspendAdminUser(user.id) : activateAdminUser(user.id), suspend ? 'User suspended.' : 'User activated.')
	}
	const columns = [
		{ header: 'User', render: (user: AdminUser) => <div><p className="font-semibold">{user.display_name || user.phone}</p><p className="text-xs text-muted-foreground">{user.email || 'No email'} · {user.phone}</p></div> },
		{ header: 'Role', render: (user: AdminUser) => user.role.replaceAll('_', ' ') },
		{ header: 'Account', render: (user: AdminUser) => <span>{user.is_active ? 'Active' : 'Suspended'} · {user.kyc_status || 'KYC pending'}{user.is_staff ? ' · Staff' : ''}</span> },
		{ header: 'Joined', render: (user: AdminUser) => user.date_joined ? new Date(user.date_joined).toLocaleDateString() : 'Not recorded' },
		{ header: 'Actions', render: (user: AdminUser) => <UserStatusAction user={user} busy={busy === String(user.id)} onToggle={() => toggle(user)} /> },
	]

	return <AdminPageLayout section="users" title="Users" loading={loading} error={error} notice={notice} onRefresh={refresh}>
		<div className="mb-4 flex flex-wrap items-center justify-between gap-3"><p className="text-sm text-muted-foreground">{data?.length ?? 0} accounts · Superuser accounts are protected.</p><input aria-label="Search users" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search name, phone, email" className="min-h-10 w-full max-w-sm rounded-md border border-border bg-background px-3 text-sm" /></div>
		<DataTable data={users} columns={columns} keyExtractor={(user) => String(user.id)} emptyMessage="No matching users found." />
	</AdminPageLayout>
}