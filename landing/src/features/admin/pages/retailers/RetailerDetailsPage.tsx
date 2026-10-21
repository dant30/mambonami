import { ArrowLeft, BriefcaseBusiness, Pencil } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'

import { StatCard } from '../../../../shared/components/cards'
import { Avatar, Badge, Button } from '../../../../shared/components/ui'
import { AdminPageLayout } from '../../components'
import { getAdminUser } from '../../../../core/lib'
import type { AdminUserDetail } from '../../../../core/lib/types/admin'
import { AdminVerificationDocumentsPanel } from '../users/components/AdminVerificationDocumentsPanel'
import { RetailerEditModal } from './components/RetailerEditModal'

function text(value: unknown) {
	if (value === null || value === undefined || value === '') return 'Not provided'
	return String(value)
}

export function RetailerDetailsPage() {
	const { id = '' } = useParams()
	const [user, setUser] = useState<AdminUserDetail | null>(null)
	const [loading, setLoading] = useState(true)
	const [error, setError] = useState('')
	const [editing, setEditing] = useState(false)
	const [reloadKey, setReloadKey] = useState(0)
	const userId = Number(id)

	useEffect(() => {
		let active = true
		setLoading(true)
		setError('')
		getAdminUser(userId).then((result) => {
			if (active) setUser(result)
		}).catch((requestError) => {
			if (active) setError(requestError instanceof Error ? requestError.message : 'Could not load retailer details.')
		}).finally(() => {
			if (active) setLoading(false)
		})
		return () => { active = false }
	}, [userId, reloadKey])

	const refresh = () => setReloadKey((current) => current + 1)
	const profile = user?.role_profile ?? {}

	return <AdminPageLayout section="retailers" title={text(user?.role_profile?.business_name) === 'Not provided' ? user?.display_name || 'Retailer details' : text(user?.role_profile?.business_name)} loading={loading} error={error} onRefresh={refresh}>
		{user && <div className="space-y-5">
			<div className="flex flex-wrap items-center justify-between gap-3"><Link to="/app/admin/retailers" className="inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-primary"><ArrowLeft className="h-4 w-4" />All retailers</Link><div className="flex items-center gap-2"><Badge variant={user.is_active ? 'success' : 'danger'}>{user.is_active ? 'Active account' : 'Suspended'}</Badge><Button type="button" size="sm" variant="outline" leftIcon={<Pencil className="h-4 w-4" />} onClick={() => setEditing(true)}>Edit details</Button></div></div>
			<div className="flex items-center gap-4 rounded-xl border border-border bg-card p-4 sm:p-5"><Avatar src={user.avatar_url} name={user.display_name || user.phone} size="xl" /><div className="min-w-0"><p className="text-xs font-bold uppercase text-primary">Retailer</p><h2 className="mt-1 break-words text-xl font-semibold text-primary-dark">{text(profile.business_name) === 'Not provided' ? user.display_name || user.username : text(profile.business_name)}</h2><p className="mt-1 break-all text-sm text-muted-foreground">{user.phone} · {user.email || 'No account email'}</p></div></div>
			<div className="grid grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-4"><StatCard title="KYC" value={user.kyc_status || 'Pending'} subtitle={user.is_phone_verified ? 'Phone verified' : 'Phone unverified'} variant="flat" /><StatCard title="Business type" value={text(profile.business_type)} subtitle="Registered category" variant="flat" /><StatCard title="Joined" value={user.date_joined ? new Date(user.date_joined).toLocaleDateString() : 'Unknown'} subtitle="Account creation date" variant="flat" /><StatCard title="Account" value={user.is_active ? 'Active' : 'Suspended'} subtitle={user.account_status || 'Status not recorded'} variant="flat" /></div>
			<section className="rounded-xl border border-border bg-card p-4 sm:p-5"><h2 className="flex items-center gap-2 text-base font-semibold text-primary-dark"><BriefcaseBusiness className="h-4 w-4" />Business profile</h2><dl className="mt-4 grid gap-x-6 gap-y-4 text-sm sm:grid-cols-2 lg:grid-cols-3"><Detail label="Business name" value={text(profile.business_name)} /><Detail label="Owner" value={text(profile.owner_full_name)} /><Detail label="Business phone" value={text(profile.business_phone)} /><Detail label="Business email" value={text(profile.business_email)} /><Detail label="Business type" value={text(profile.business_type)} /><Detail label="Business address" value={text(profile.business_address)} /><Detail label="KRA PIN" value={text(profile.kra_pin)} /><Detail label="Registration number" value={text(profile.business_registration_number)} /><Detail label="Bank account" value={text(profile.bank_account)} /><Detail label="Business coordinates" value={profile.latitude != null && profile.longitude != null ? `${profile.latitude}, ${profile.longitude}` : 'Not provided'} /></dl></section>
			<AdminVerificationDocumentsPanel userId={user.id} />
		</div>}
		<RetailerEditModal user={editing ? user : null} onClose={() => setEditing(false)} onSaved={() => { setEditing(false); refresh() }} />
	</AdminPageLayout>
}

function Detail({ label, value }: { label: string; value: string }) {
	return <div className="min-w-0"><dt className="text-xs text-muted-foreground">{label}</dt><dd className="mt-1 break-words font-medium text-foreground">{value}</dd></div>
}
