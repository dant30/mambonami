import { Eye, Pencil } from 'lucide-react'
import { useState } from 'react'
import { Link } from 'react-router-dom'

import { DataTable } from '../../../../shared/components/tables/DataTable'
import { StatCard } from '../../../../shared/components/cards'
import { AdminPageLayout } from '../../components'
import { activateAdminUser, adminResourceCaches, getAdminUser, listAdminUsers, suspendAdminUser, useAdminResource } from '../../../../core/lib'
import type { AdminUser, AdminUserDetail } from '../../../../core/lib/types/admin'
import { RetailerAccountStatus } from './components/RetailerAccountStatus'
import { RetailerEditModal } from './components/RetailerEditModal'

export function RetailersAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminUsers, adminResourceCaches.users)
	const [editing, setEditing] = useState<AdminUserDetail | null>(null)
	const [editError, setEditError] = useState('')
	const retailers = (data ?? []).filter((user) => user.role === 'retailer')
	const activeCount = retailers.filter((retailer) => retailer.is_active).length
	const verifiedCount = retailers.filter((retailer) => ['approved', 'verified'].includes(retailer.kyc_status || '')).length
	const toggle = (retailer: AdminUser) => {
		const suspend = retailer.is_active
		if (!window.confirm(`${suspend ? 'Suspend' : 'Activate'} retailer ${retailer.display_name || retailer.phone}?`)) return
		void runAction(String(retailer.id), () => suspend ? suspendAdminUser(retailer.id) : activateAdminUser(retailer.id), suspend ? 'Retailer suspended.' : 'Retailer activated.')
	}
	const openEdit = async (retailer: AdminUser) => {
		setEditError('')
		try {
			setEditing(await getAdminUser(retailer.id))
		} catch (requestError) {
			setEditError(requestError instanceof Error ? requestError.message : 'Could not load retailer details for editing.')
		}
	}
	const columns = [
		{ header: 'Retailer', render: (retailer: AdminUser) => <div><p className="font-semibold">{retailer.display_name || retailer.username || retailer.phone}</p><p className="text-xs text-muted-foreground">{retailer.phone} · {retailer.email || 'No email'}</p></div> },
		{ header: 'Verification', render: (retailer: AdminUser) => `${retailer.kyc_status || 'KYC pending'} · ${retailer.is_phone_verified ? 'Phone verified' : 'Phone unverified'}` },
		{ header: 'Account', render: (retailer: AdminUser) => retailer.is_active ? 'Active' : 'Suspended' },
		{ header: 'Joined', render: (retailer: AdminUser) => retailer.date_joined ? new Date(retailer.date_joined).toLocaleDateString() : 'Not recorded' },
		{ header: 'Actions', mobileRole: 'action' as const, render: (retailer: AdminUser) => <div className="flex items-center gap-1.5"><Link to={`/app/admin/retailers/${retailer.id}`} aria-label={`View retailer ${retailer.display_name || retailer.phone}`} title="View retailer" className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border text-muted-foreground hover:bg-muted"><Eye className="h-4 w-4" /></Link><button type="button" onClick={() => void openEdit(retailer)} aria-label={`Edit retailer ${retailer.display_name || retailer.phone}`} title="Edit retailer" className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border text-muted-foreground hover:bg-muted"><Pencil className="h-4 w-4" /></button><RetailerAccountStatus retailer={retailer} busy={busy === String(retailer.id)} onToggle={() => toggle(retailer)} /></div> },
	]
	return <AdminPageLayout section="retailers" title="Retailers" loading={loading} error={error || editError} notice={notice} onRefresh={refresh}><div className="mb-4 grid grid-cols-2 gap-3 sm:mb-6 sm:gap-4 xl:grid-cols-4"><StatCard title="Retailers" value={retailers.length} subtitle="Registered businesses" variant="flat" /><StatCard title="Active" value={activeCount} subtitle="Accounts in service" variant="flat" /><StatCard title="KYC verified" value={verifiedCount} subtitle="Approved or verified" variant="flat" /><StatCard title="KYC pending" value={retailers.length - verifiedCount} subtitle="Needs review" variant="flat" /></div><DataTable data={retailers} columns={columns} keyExtractor={(retailer) => String(retailer.id)} emptyMessage="No retailer accounts found." /><RetailerEditModal user={editing} onClose={() => setEditing(null)} onSaved={() => { setEditing(null); refresh() }} /></AdminPageLayout>
}