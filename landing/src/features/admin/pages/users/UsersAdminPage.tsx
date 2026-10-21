import { Eye, Pencil } from 'lucide-react'
import { useRef, useState, type FormEvent } from 'react'

import {
	activateAdminUser,
	adminResourceCaches,
	getAdminUser,
	listAdminUsers,
	suspendAdminUser,
	updateAdminUser,
	useAdminResource,
} from '../../../../core/lib'
import type { AdminUser } from '../../../../core/lib/types/admin'
import type { Order } from '../../../../core/lib/types/orders'
import type { Payout } from '../../../../core/lib/types/payouts'
import { ADMIN_ENDPOINTS, apiClient } from '../../../../core/api'
import { Avatar, Modal } from '../../../../shared/components/ui'
import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { UserStatusAction } from './components/UserStatusAction'
import { AdminVerificationDocumentsPanel } from './components/AdminVerificationDocumentsPanel'

type UserMetrics = {
	orders: Order[]
	payouts: Payout[]
}

type PagedResponse<T> = {
	results?: T[]
	next?: string | null
}

async function loadAllPages<T>(path: string): Promise<T[]> {
	const records: T[] = []
	const visitedPages = new Set<number>()
	let page = 1

	while (!visitedPages.has(page)) {
		visitedPages.add(page)
		const response = await apiClient.get<T[] | PagedResponse<T>>(path, { params: { page } })
		if (Array.isArray(response)) return response
		records.push(...(response.results ?? []))
		if (!response.next) return records

		const nextPage = Number(new URL(response.next, window.location.origin).searchParams.get('page'))
		if (!Number.isInteger(nextPage) || nextPage < 1) return records
		page = nextPage
	}

	return records
}

const formatKes = (amount: number) => new Intl.NumberFormat('en-KE', {
	style: 'currency',
	currency: 'KES',
	maximumFractionDigits: 2,
}).format(amount)

export function UsersAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminUsers, adminResourceCaches.users)
	const [query, setQuery] = useState('')
	const [viewingUser, setViewingUser] = useState<AdminUser | null>(null)
	const [userMetrics, setUserMetrics] = useState<UserMetrics | null>(null)
	const [detailsLoading, setDetailsLoading] = useState(false)
	const [detailsError, setDetailsError] = useState('')
	const [editingUser, setEditingUser] = useState<AdminUser | null>(null)
	const [savingUser, setSavingUser] = useState(false)
	const [editError, setEditError] = useState('')
	const viewingUserIdRef = useRef<number | null>(null)
	const users = (data ?? []).filter((user) => `${user.display_name ?? ''} ${user.phone} ${user.email ?? ''} ${user.role}`.toLowerCase().includes(query.trim().toLowerCase()))

	const toggle = (user: AdminUser) => {
		const suspend = user.is_active
		if (!window.confirm(`${suspend ? 'Suspend' : 'Activate'} ${user.display_name || user.phone}?`)) return
		void runAction(String(user.id), () => suspend ? suspendAdminUser(user.id) : activateAdminUser(user.id), suspend ? 'User suspended.' : 'User activated.')
	}

	const openDetails = async (user: AdminUser) => {
		viewingUserIdRef.current = user.id
		setViewingUser(user)
		setUserMetrics(null)
		setDetailsError('')
		setDetailsLoading(true)
		try {
			const [freshUser, orders, payouts] = await Promise.all([
				getAdminUser(user.id),
				loadAllPages<Order>(ADMIN_ENDPOINTS.orders.list),
				loadAllPages<Payout>(ADMIN_ENDPOINTS.payouts.list),
			])
			if (viewingUserIdRef.current !== user.id) return
			setViewingUser(freshUser)
			setUserMetrics({
				orders: orders.filter((order) => order.buyer === user.id),
				payouts: payouts.filter((payout) => payout.recipient_user === user.id),
			})
		} catch (requestError) {
			if (viewingUserIdRef.current !== user.id) return
			setDetailsError(requestError instanceof Error ? requestError.message : 'Could not load user details.')
		} finally {
			if (viewingUserIdRef.current === user.id) setDetailsLoading(false)
		}
	}

	const closeDetails = () => {
		viewingUserIdRef.current = null
		setViewingUser(null)
	}

	const saveUser = async (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		if (!editingUser) return
		const formData = new FormData(event.currentTarget)
		setSavingUser(true)
		setEditError('')
		try {
			await updateAdminUser(editingUser.id, {
				first_name: String(formData.get('first_name') || '').trim(),
				middle_name: String(formData.get('middle_name') || '').trim(),
				last_name: String(formData.get('last_name') || '').trim(),
				username: String(formData.get('username') || '').trim(),
				email: String(formData.get('email') || '').trim(),
			})
			setEditingUser(null)
			refresh()
		} catch (requestError) {
			setEditError(requestError instanceof Error ? requestError.message : 'Could not save user changes.')
		} finally {
			setSavingUser(false)
		}
	}

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
				<button type="button" aria-label={`View ${user.display_name || user.phone}`} title="View user" onClick={() => void openDetails(user)} className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border text-muted-foreground transition hover:bg-muted hover:text-foreground"><Eye className="h-4 w-4" aria-hidden="true" /></button>
				<button type="button" aria-label={`Edit ${user.display_name || user.phone}`} title="Edit user" onClick={() => { setEditError(''); setEditingUser(user) }} disabled={user.is_superuser} className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border text-muted-foreground transition hover:bg-muted hover:text-foreground disabled:cursor-not-allowed disabled:opacity-40"><Pencil className="h-4 w-4" aria-hidden="true" /></button>
				<UserStatusAction user={user} busy={busy === String(user.id)} disabled={user.is_superuser} onToggle={() => toggle(user)} />
			</div>,
		},
	]

	const orderValue = userMetrics?.orders.reduce((total, order) => total + Number(order.total_amount || 0), 0) ?? 0
	const payoutValue = userMetrics?.payouts.reduce((total, payout) => total + Number(payout.amount || 0), 0) ?? 0

	return <AdminPageLayout section="users" title="Users" loading={loading} error={error} notice={notice} onRefresh={refresh}>
		<div className="mb-4 flex flex-wrap items-center justify-between gap-3"><p className="text-sm text-muted-foreground">{data?.length ?? 0} accounts · Superuser accounts are protected.</p><input aria-label="Search users" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search name, phone, email" className="min-h-10 w-full max-w-sm rounded-md border border-border bg-background px-3 text-sm" /></div>
		<DataTable data={users} columns={columns} keyExtractor={(user) => String(user.id)} emptyMessage="No matching users found." />

		<Modal isOpen={Boolean(viewingUser)} onClose={closeDetails} title="User details" subtitle={viewingUser?.phone} maxWidth="lg">
			{viewingUser && <div className="space-y-5">
				<div className="flex items-center gap-4"><Avatar src={viewingUser.avatar_url} name={viewingUser.display_name || viewingUser.phone} size="xl" /><div><h3 className="text-lg font-bold">{viewingUser.display_name || viewingUser.username || viewingUser.phone}</h3><p className="text-sm capitalize text-muted-foreground">{viewingUser.role.replaceAll('_', ' ')}</p></div></div>
				{detailsLoading ? <p className="text-sm text-muted-foreground">Loading account metrics…</p> : detailsError ? <p role="alert" className="text-sm text-destructive">{detailsError}</p> : userMetrics && <div className="grid grid-cols-2 gap-3">
					<Metric label="Buyer orders" value={String(userMetrics.orders.length)} />
					<Metric label="Completed orders" value={String(userMetrics.orders.filter((order) => order.status === 'delivered').length)} />
					<Metric label="Buyer order value" value={formatKes(orderValue)} />
					<Metric label="Payouts received" value={String(userMetrics.payouts.length)} />
					<Metric label="Payout total" value={formatKes(payoutValue)} />
					<Metric label="Joined" value={viewingUser.date_joined ? new Date(viewingUser.date_joined).toLocaleDateString() : 'Not recorded'} />
				</div>}
				<dl className="grid grid-cols-2 gap-x-4 gap-y-3 border-t border-border pt-4 text-sm">
					<Detail label="Email" value={viewingUser.email || 'Not provided'} />
					<Detail label="Account" value={viewingUser.is_active ? 'Active' : 'Suspended'} />
					<Detail label="KYC" value={viewingUser.kyc_status || 'Pending'} />
					<Detail label="Last seen" value={viewingUser.last_seen ? new Date(viewingUser.last_seen).toLocaleString() : 'Not recorded'} />
				</dl>
				<AdminVerificationDocumentsPanel userId={viewingUser.id} />
			</div>}
		</Modal>

		<Modal isOpen={Boolean(editingUser)} onClose={() => savingUser ? undefined : setEditingUser(null)} title="Edit user" subtitle={editingUser?.phone} maxWidth="md">
			{editingUser && <form className="space-y-4" onSubmit={saveUser}>
				<div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
					<FormField name="first_name" label="First name" value={editingUser.first_name} />
					<FormField name="middle_name" label="Middle name" value={editingUser.middle_name} />
					<FormField name="last_name" label="Last name" value={editingUser.last_name} />
					<FormField name="username" label="Username" value={editingUser.username} />
					<FormField name="email" label="Email" type="email" value={editingUser.email} />
				</div>
				{editError && <p role="alert" className="text-sm text-destructive">{editError}</p>}
				<div className="flex justify-end gap-2 border-t border-border pt-4"><button type="button" onClick={() => setEditingUser(null)} disabled={savingUser} className="min-h-10 rounded-md border border-border px-4 text-sm font-semibold hover:bg-muted">Cancel</button><button type="submit" disabled={savingUser} className="min-h-10 rounded-md bg-primary px-4 text-sm font-semibold text-primary-foreground disabled:opacity-60">{savingUser ? 'Saving…' : 'Save changes'}</button></div>
			</form>}
		</Modal>
	</AdminPageLayout>
}

function Metric({ label, value }: { label: string; value: string }) {
	return <div className="rounded-md border border-border bg-muted/40 p-3"><p className="text-xs text-muted-foreground">{label}</p><p className="mt-1 break-words text-sm font-bold text-foreground">{value}</p></div>
}

function Detail({ label, value }: { label: string; value: string }) {
	return <div><dt className="text-xs text-muted-foreground">{label}</dt><dd className="mt-1 break-words font-medium">{value}</dd></div>
}

function FormField({ name, label, value, type = 'text' }: { name: string; label: string; value?: string; type?: string }) {
	return <label className="block text-sm font-semibold">{label}<input name={name} type={type} defaultValue={value || ''} className="mt-1 min-h-10 w-full rounded-md border border-border bg-background px-3 text-sm font-normal" /></label>
}