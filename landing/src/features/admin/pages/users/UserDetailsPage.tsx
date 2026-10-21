import { ArrowLeft, Pencil, ShieldCheck, UserRound } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'

import { StatCard } from '../../../../shared/components/cards'
import { Avatar, Button, ConfirmDialog } from '../../../../shared/components/ui'
import { AdminPageLayout } from '../../components'
import { ADMIN_ENDPOINTS, apiClient } from '../../../../core/api'
import { activateAdminUser, getAdminUser, suspendAdminUser } from '../../../../core/lib'
import type { AdminUserDetail } from '../../../../core/lib/types/admin'
import type { Order } from '../../../../core/lib/types/orders'
import type { Payout } from '../../../../core/lib/types/payouts'
import { AdminVerificationDocumentsPanel } from './components/AdminVerificationDocumentsPanel'
import { UserEditModal } from './components/UserEditModal'

function formatValue(value: unknown): string {
	if (value === null || value === undefined || value === '') return 'Not provided'
	if (typeof value === 'boolean') return value ? 'Yes' : 'No'
	if (Array.isArray(value)) return value.map(formatValue).join(', ')
	return String(value)
}

function label(value: string) {
	return value.replaceAll('_', ' ').replace(/\b\w/g, (letter) => letter.toUpperCase())
}

type PagedResponse<T> = { results?: T[]; next?: string | null }

async function loadAllPages<T>(path: string): Promise<T[]> {
	const records: T[] = []
	const visited = new Set<number>()
	let page = 1
	while (!visited.has(page)) {
		visited.add(page)
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

function formatKes(amount: number) {
	return new Intl.NumberFormat('en-KE', { style: 'currency', currency: 'KES', maximumFractionDigits: 2 }).format(amount)
}

export function UserDetailsPage() {
	const { id = '' } = useParams()
	const userId = Number(id)
	const [user, setUser] = useState<AdminUserDetail | null>(null)
	const [loading, setLoading] = useState(true)
	const [error, setError] = useState('')
	const [notice, setNotice] = useState('')
	const [orders, setOrders] = useState<Order[]>([])
	const [payouts, setPayouts] = useState<Payout[]>([])
	const [editing, setEditing] = useState(false)
	const [confirmingSuspend, setConfirmingSuspend] = useState(false)
	const [statusBusy, setStatusBusy] = useState(false)
	const [reloadKey, setReloadKey] = useState(0)

	useEffect(() => {
		let active = true
		setLoading(true)
		setError('')
		Promise.all([
			getAdminUser(userId),
			loadAllPages<Order>(ADMIN_ENDPOINTS.orders.list),
			loadAllPages<Payout>(ADMIN_ENDPOINTS.payouts.list),
		]).then(([result, allOrders, allPayouts]) => {
			if (!active) return
			setUser(result)
			setOrders(allOrders.filter((order) => order.buyer === userId))
			setPayouts(allPayouts.filter((payout) => payout.recipient_user === userId))
		}).catch((requestError) => {
			if (active) setError(requestError instanceof Error ? requestError.message : 'Could not load user details.')
		}).finally(() => {
			if (active) setLoading(false)
		})
		return () => { active = false }
	}, [userId, reloadKey])

	const refresh = () => setReloadKey((current) => current + 1)
	const changeStatus = async (suspend: boolean) => {
		if (!user) return
		setStatusBusy(true)
		setError('')
		setNotice('')
		try {
			if (suspend) await suspendAdminUser(user.id)
			else await activateAdminUser(user.id)
			setConfirmingSuspend(false)
			setNotice(suspend ? 'User suspended.' : 'User activated.')
			refresh()
		} catch (requestError) {
			setError(requestError instanceof Error ? requestError.message : 'The account status could not be updated.')
		} finally {
			setStatusBusy(false)
		}
	}

	const profileEntries = Object.entries(user?.role_profile ?? {}).filter(([, value]) => value !== null && value !== undefined && value !== '')
	const roleLabel = user?.role.replaceAll('_', ' ') || 'user'
	const orderValue = orders.reduce((total, order) => total + Number(order.total_amount || 0), 0)
	const payoutValue = payouts.reduce((total, payout) => total + Number(payout.amount || 0), 0)

	return <AdminPageLayout section="users" title={user?.display_name || user?.username || user?.phone || 'User details'} loading={loading} error={error} notice={notice} onRefresh={refresh}>
		{user && <div className="space-y-5">
			<div className="flex flex-wrap items-center justify-between gap-4">
				<Link to="/app/admin/users" className="inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-primary hover:text-primary-dark"><ArrowLeft className="h-4 w-4" />All users</Link>
				<div className="flex flex-wrap items-center gap-2"><Button type="button" variant="outline" size="sm" leftIcon={<Pencil className="h-4 w-4" />} disabled={user.is_superuser} onClick={() => setEditing(true)}>Edit user</Button>{user.is_active ? <Button type="button" variant="danger" size="sm" leftIcon={<ShieldCheck className="h-4 w-4" />} disabled={user.is_superuser} onClick={() => setConfirmingSuspend(true)}>Suspend</Button> : <Button type="button" size="sm" isLoading={statusBusy} onClick={() => void changeStatus(false)}>Activate</Button>}</div>
			</div>
			<div className="flex items-center gap-4 rounded-xl border border-border bg-card p-4 sm:p-5"><Avatar src={user.avatar_url} name={user.display_name || user.phone} size="xl" /><div className="min-w-0"><p className="text-xs font-bold uppercase text-primary">{roleLabel}</p><h2 className="mt-1 break-words text-xl font-semibold text-primary-dark">{user.display_name || user.username || user.phone}</h2><p className="mt-1 break-all text-sm text-muted-foreground">{user.email || 'No email'} · {user.phone}</p></div></div>
			<div className="grid grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-4"><StatCard title="Account" value={user.is_active ? 'Active' : 'Suspended'} subtitle={user.account_status || 'Status not recorded'} variant="flat" /><StatCard title="KYC" value={user.kyc_status || 'Pending'} subtitle={user.is_phone_verified ? 'Phone verified' : 'Phone unverified'} variant="flat" /><StatCard title="Joined" value={user.date_joined ? new Date(user.date_joined).toLocaleDateString() : 'Unknown'} subtitle={user.last_seen ? `Last seen ${new Date(user.last_seen).toLocaleDateString()}` : 'No recent activity'} variant="flat" /><StatCard title="Access" value={user.is_superuser ? 'Superuser' : user.is_staff ? 'Staff' : 'User'} subtitle={`User ID ${user.id}`} variant="flat" /></div>
			<div className="grid grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-4"><StatCard title="Buyer orders" value={orders.length} subtitle={`${orders.filter((order) => order.status === 'delivered').length} completed`} variant="flat" /><StatCard title="Order value" value={formatKes(orderValue)} subtitle="Buyer purchases" variant="flat" /><StatCard title="Payouts received" value={payouts.length} subtitle="Farmer or transporter payouts" variant="flat" /><StatCard title="Payout total" value={formatKes(payoutValue)} subtitle="Total payout value" variant="flat" /></div>
			<section className="rounded-xl border border-border bg-card p-4 sm:p-5">
				<h2 className="flex items-center gap-2 text-base font-semibold text-primary-dark"><UserRound className="h-4 w-4" />Account details</h2>
				<dl className="mt-4 grid gap-x-6 gap-y-4 text-sm sm:grid-cols-2 lg:grid-cols-3">
					<Detail label="First name" value={user.first_name} /><Detail label="Middle name" value={user.middle_name} /><Detail label="Last name" value={user.last_name} /><Detail label="National ID" value={user.national_id} /><Detail label="Referral code" value={user.referral_code} /><Detail label="Username" value={user.username} /><Detail label="Phone" value={user.phone} /><Detail label="Email" value={user.email} /><Detail label="Phone verification" value={user.is_phone_verified ? 'Verified' : 'Pending'} /><Detail label="Email verification" value={user.is_email_verified ? 'Verified' : 'Pending'} /><Detail label="Last login IP" value={user.last_login_ip} /><Detail label="Date joined" value={user.date_joined ? new Date(user.date_joined).toLocaleString() : undefined} /><Detail label="Last seen" value={user.last_seen ? new Date(user.last_seen).toLocaleString() : undefined} />
				</dl>
			</section>
			<section className="rounded-xl border border-border bg-card p-4 sm:p-5">
				<h2 className="text-base font-semibold text-primary-dark">{label(roleLabel)} profile</h2>
				{profileEntries.length ? <dl className="mt-4 grid gap-x-6 gap-y-4 text-sm sm:grid-cols-2 lg:grid-cols-3">{profileEntries.map(([key, value]) => <Detail key={key} label={label(key)} value={formatValue(value)} />)}</dl> : <p className="mt-3 text-sm text-muted-foreground">No additional role profile details are available.</p>}
			</section>
			<AdminVerificationDocumentsPanel userId={user.id} />
		</div>}
		<UserEditModal user={editing ? user : null} onClose={() => setEditing(false)} onSaved={() => { setEditing(false); refresh() }} />
		<ConfirmDialog isOpen={confirmingSuspend} title="Suspend user account" message={<>Suspend {user?.display_name || user?.phone}? They will no longer be able to use their account.</>} confirmLabel="Suspend account" variant="danger" loading={statusBusy} onCancel={() => !statusBusy && setConfirmingSuspend(false)} onConfirm={() => void changeStatus(true)} />
	</AdminPageLayout>
}

function Detail({ label: title, value }: { label: string; value?: string | null }) {
	return <div className="min-w-0"><dt className="text-xs text-muted-foreground">{title}</dt><dd className="mt-1 break-words font-medium text-foreground">{value || 'Not provided'}</dd></div>
}
