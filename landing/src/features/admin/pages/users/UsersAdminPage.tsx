import { Eye, Pencil } from 'lucide-react'
import { useState } from 'react'
import { Link } from 'react-router-dom'

import {
	activateAdminUser,
	adminResourceCaches,
	listAdminUsers,
	suspendAdminUser,
	useAdminResource,
} from '../../../../core/lib'
import { useAuth } from '../../../../core/contexts/AuthContext'
import type { AdminUser } from '../../../../core/lib/types/admin'
import { StatCard } from '../../../../shared/components/cards'
import { Avatar, ConfirmDialog } from '../../../../shared/components/ui'
import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { UserStatusAction } from './components/UserStatusAction'
import { UserEditModal } from './components/UserEditModal'

export function UsersAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminUsers, adminResourceCaches.users)
	const { user: currentUser } = useAuth()
	const [query, setQuery] = useState('')
	const [editingUser, setEditingUser] = useState<AdminUser | null>(null)
	const [confirmingUser, setConfirmingUser] = useState<AdminUser | null>(null)
	const [suspendingId, setSuspendingId] = useState<number | null>(null)
	const [actionError, setActionError] = useState('')
	const [actionNotice, setActionNotice] = useState('')
	const users = (data ?? []).filter((user) => `${user.display_name ?? ''} ${user.phone} ${user.email ?? ''} ${user.role}`.toLowerCase().includes(query.trim().toLowerCase()))

	const toggle = (user: AdminUser) => {
		if (user.is_active) {
			setConfirmingUser(user)
			setActionError('')
			return
		}
		void runAction(String(user.id), () => activateAdminUser(user.id), 'User activated.')
	}

	const confirmSuspend = async () => {
		if (!confirmingUser) return
		setSuspendingId(confirmingUser.id)
		setActionError('')
		setActionNotice('')
		try {
			await suspendAdminUser(confirmingUser.id)
			setConfirmingUser(null)
			setActionNotice('User suspended.')
			refresh()
		} catch (requestError) {
			setActionError(requestError instanceof Error ? requestError.message : 'Could not suspend this user.')
		} finally {
			setSuspendingId(null)
		}
	}

	const totalUsers = data?.length ?? 0
	const activeUsers = (data ?? []).filter((user) => user.is_active).length
	const suspendedUsers = totalUsers - activeUsers
	const pendingKyc = (data ?? []).filter((user) => !['approved', 'verified'].includes(user.kyc_status || '')).length

	const columns = [
		{
			header: 'User',
			mobileRole: 'title' as const,
			render: (user: AdminUser) => <div className="flex min-w-0 items-center gap-3">
				<Avatar src={user.avatar_url} name={user.display_name || user.phone} size="md" />
				<div className="min-w-0"><p className="break-words font-semibold">{user.display_name || user.phone}</p><p className="break-all text-xs text-muted-foreground">{user.email || 'No email'} · {user.phone}</p></div>
			</div>,
		},
		{ header: 'Role', mobileRole: 'summary' as const, render: (user: AdminUser) => user.role.replaceAll('_', ' ') },
		{ header: 'Account', mobileRole: 'status' as const, render: (user: AdminUser) => <span>{user.is_active ? 'Active' : 'Suspended'} · {user.kyc_status || 'KYC pending'}{user.is_staff ? ' · Staff' : ''}</span> },
		{ header: 'Joined', mobileRole: 'detail' as const, render: (user: AdminUser) => user.date_joined ? new Date(user.date_joined).toLocaleDateString() : 'Not recorded' },
		{
			header: 'Actions',
			mobileRole: 'action' as const,
			className: 'w-36',
			render: (user: AdminUser) => <div className="flex items-center gap-1.5">
				<Link to={`/app/admin/users/${user.id}`} aria-label={`View ${user.display_name || user.phone}`} title="View user" className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border text-muted-foreground transition hover:bg-muted hover:text-foreground"><Eye className="h-4 w-4" aria-hidden="true" /></Link>
				<button type="button" aria-label={`Edit ${user.display_name || user.phone}`} title="Edit user" onClick={() => setEditingUser(user)} disabled={user.is_superuser} className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border text-muted-foreground transition hover:bg-muted hover:text-foreground disabled:cursor-not-allowed disabled:opacity-40"><Pencil className="h-4 w-4" aria-hidden="true" /></button>
				<UserStatusAction user={user} busy={busy === String(user.id) || suspendingId === user.id} disabled={user.is_superuser || String(currentUser?.id) === String(user.id)} onToggle={() => toggle(user)} />
			</div>,
		},
	]

	return <AdminPageLayout section="users" title="Users" loading={loading} error={error || actionError} notice={notice || actionNotice} onRefresh={refresh}>
		<div className="mb-4 grid grid-cols-2 gap-3 sm:mb-6 sm:gap-4 xl:grid-cols-4"><StatCard title="User accounts" value={totalUsers} subtitle="All registered roles" variant="flat" /><StatCard title="Active" value={activeUsers} subtitle="Accounts in good standing" variant="flat" /><StatCard title="Suspended" value={suspendedUsers} subtitle="Inactive accounts" variant="flat" /><StatCard title="KYC pending" value={pendingKyc} subtitle="Awaiting approval or verification" variant="flat" /></div>
		<div className="mb-4 flex flex-wrap items-center justify-between gap-3"><p className="text-sm text-muted-foreground">{data?.length ?? 0} accounts · Superuser accounts are protected.</p><input aria-label="Search users" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search name, phone, email" className="min-h-10 w-full max-w-sm rounded-md border border-border bg-background px-3 text-sm" /></div>
		<DataTable data={users} columns={columns} keyExtractor={(user) => String(user.id)} emptyMessage="No matching users found." />
		<UserEditModal user={editingUser} onClose={() => setEditingUser(null)} onSaved={() => { setEditingUser(null); refresh() }} />
		<ConfirmDialog isOpen={Boolean(confirmingUser)} title="Suspend user account" message={<>Suspend {confirmingUser?.display_name || confirmingUser?.phone}? They will no longer be able to use their account.</>} confirmLabel="Suspend account" variant="danger" loading={Boolean(confirmingUser && suspendingId === confirmingUser.id)} onCancel={() => suspendingId === null && setConfirmingUser(null)} onConfirm={() => void confirmSuspend()} />
	</AdminPageLayout>
}