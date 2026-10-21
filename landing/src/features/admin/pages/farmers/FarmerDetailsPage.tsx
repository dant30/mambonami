import { ArrowLeft, MapPin, Pencil, Sprout } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'

import { StatCard } from '../../../../shared/components/cards'
import { Card } from '../../../../shared/components/cards/Card'
import { Avatar, Button, Badge } from '../../../../shared/components/ui'
import { AdminPageLayout } from '../../components'
import { approveAdminFarmer, getAdminFarmer, getAdminUser } from '../../../../core/lib'
import type { AdminFarmer, AdminUserDetail } from '../../../../core/lib/types/admin'
import { AdminVerificationDocumentsPanel } from '../users/components/AdminVerificationDocumentsPanel'
import { FarmerEditModal } from './components/FarmerEditModal'

export function FarmerDetailsPage() {
	const { id = '' } = useParams()
	const farmerId = Number(id)
	const [farmer, setFarmer] = useState<AdminFarmer | null>(null)
	const [user, setUser] = useState<AdminUserDetail | null>(null)
	const [loading, setLoading] = useState(true)
	const [error, setError] = useState('')
	const [notice, setNotice] = useState('')
	const [editing, setEditing] = useState(false)
	const [approving, setApproving] = useState(false)
	const [reloadKey, setReloadKey] = useState(0)

	useEffect(() => {
		let active = true
		setLoading(true)
		setError('')
		getAdminFarmer(farmerId).then(async (farmerResult) => {
			const userResult = await getAdminUser(farmerResult.user)
			if (!active) return
			setFarmer(farmerResult)
			setUser(userResult)
		}).catch((requestError) => {
			if (active) setError(requestError instanceof Error ? requestError.message : 'Could not load farmer details.')
		}).finally(() => {
			if (active) setLoading(false)
		})
		return () => { active = false }
	}, [farmerId, reloadKey])

	const refresh = () => setReloadKey((current) => current + 1)
	const approve = async () => {
		if (!farmer) return
		setApproving(true)
		setError('')
		setNotice('')
		try {
			await approveAdminFarmer(farmer.id)
			setNotice('Farmer cooperative profile approved.')
			refresh()
		} catch (requestError) {
			setError(requestError instanceof Error ? requestError.message : 'Farmer approval could not be completed.')
		} finally {
			setApproving(false)
		}
	}
	const displayName = user?.display_name || farmer?.user_username || farmer?.user_phone || `Farmer ${farmerId}`

	return <AdminPageLayout section="farmers" title={displayName} loading={loading} error={error} notice={notice} onRefresh={refresh}>
		{farmer && <div className="space-y-5">
			<div className="flex flex-wrap items-center justify-between gap-3"><Link to="/app/admin/farmers" className="inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-primary"><ArrowLeft className="h-4 w-4" />All farmers</Link><div className="flex items-center gap-2"><Badge variant={farmer.coop_verified ? 'success' : 'warning'}>{farmer.coop_verified ? 'Cooperative verified' : 'Verification pending'}</Badge><Button type="button" variant="outline" size="sm" leftIcon={<Pencil className="h-4 w-4" />} onClick={() => setEditing(true)}>Edit profile</Button>{!farmer.coop_verified && <Button type="button" size="sm" isLoading={approving} onClick={() => void approve()}>Approve cooperative</Button>}</div></div>
			<div className="flex items-center gap-4 rounded-xl border border-border bg-card p-4 sm:p-5"><Avatar src={user?.avatar_url} name={displayName} size="xl" /><div><p className="text-xs font-bold uppercase text-primary">Farmer</p><h2 className="mt-1 text-xl font-semibold text-primary-dark">{displayName}</h2><p className="mt-1 text-sm text-muted-foreground">{farmer.user_phone || user?.phone} · {user?.email || 'No email'}</p></div></div>
			<div className="grid grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-4"><StatCard title="Orders" value={farmer.total_orders ?? 0} subtitle="Farmer orders" variant="flat" /><StatCard title="Sales" value={`KES ${Number(farmer.total_sales ?? 0).toLocaleString()}`} subtitle="Recorded total sales" variant="flat" /><StatCard title="Rating" value={farmer.rating?.toFixed(1) ?? 'N/A'} subtitle={`${farmer.rating_count ?? 0} reviews`} variant="flat" /><StatCard title="Cooperative" value={farmer.coop_verified ? 'Verified' : 'Pending'} subtitle={farmer.cooperative || 'No cooperative listed'} variant="flat" /></div>
			<div className="grid gap-4 lg:grid-cols-2"><Card padding="md"><h2 className="flex items-center gap-2 text-base font-semibold text-primary-dark"><Sprout className="h-4 w-4" />Farm profile</h2><dl className="mt-4 grid grid-cols-2 gap-4 text-sm"><Detail label="County" value={farmer.county} /><Detail label="Sub-county" value={farmer.sub_county} /><Detail label="Ward" value={farmer.ward} /><Detail label="Village" value={farmer.village} /><Detail label="Cooperative" value={farmer.cooperative} /><Detail label="Farm GPS" value={farmer.farm_gps || (farmer.latitude != null && farmer.longitude != null ? `${farmer.latitude}, ${farmer.longitude}` : undefined)} /><Detail label="M-Pesa number" value={farmer.mpesa_number} /><Detail label="Bank account" value={farmer.bank_account} /><Detail label="National ID" value={user?.national_id} /><Detail label="KYC status" value={user?.kyc_status} /></dl></Card><Card padding="md"><h2 className="flex items-center gap-2 text-base font-semibold text-primary-dark"><MapPin className="h-4 w-4" />Account</h2><dl className="mt-4 grid grid-cols-2 gap-4 text-sm"><Detail label="Phone" value={user?.phone} /><Detail label="Email" value={user?.email} /><Detail label="Account status" value={user?.account_status} /><Detail label="Phone verification" value={user?.is_phone_verified ? 'Verified' : 'Pending'} /><Detail label="Joined" value={user?.date_joined ? new Date(user.date_joined).toLocaleString() : undefined} /><Detail label="Last seen" value={user?.last_seen ? new Date(user.last_seen).toLocaleString() : undefined} /></dl></Card></div>
			{user && <AdminVerificationDocumentsPanel userId={user.id} />}
		</div>}
		<FarmerEditModal farmer={editing ? farmer : null} onClose={() => setEditing(false)} onSaved={() => { setEditing(false); refresh() }} />
	</AdminPageLayout>
}

function Detail({ label, value }: { label: string; value?: string | number | null }) {
	return <div className="min-w-0"><dt className="text-xs text-muted-foreground">{label}</dt><dd className="mt-1 break-words font-medium text-foreground">{value ?? 'Not provided'}</dd></div>
}
