import { DataTable } from '../../../../shared/components/tables/DataTable'
import { StatCard } from '../../../../shared/components/cards'
import { Eye, Pencil } from 'lucide-react'
import { useState } from 'react'
import { Link } from 'react-router-dom'
import { AdminPageLayout } from '../../components'
import { adminResourceCaches, approveAdminFarmer, listAdminFarmers, useAdminResource } from '../../../../core/lib'
import type { AdminFarmer } from '../../../../core/lib/types/admin'
import { FarmerApprovalAction } from './components/FarmerApprovalAction'
import { FarmerEditModal } from './components/FarmerEditModal'

export function FarmersAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminFarmers, adminResourceCaches.farmers)
	const [editingFarmer, setEditingFarmer] = useState<AdminFarmer | null>(null)
	const farmers = data ?? []
	const verifiedCount = farmers.filter((farmer) => farmer.coop_verified).length
	const columns = [
		{ header: 'Farmer', render: (farmer: AdminFarmer) => <div><p className="font-semibold">{farmer.user_username || farmer.user_phone || `Farmer ${farmer.id}`}</p><p className="text-xs text-muted-foreground">{farmer.user_phone || 'Phone unavailable'}</p></div> },
		{ header: 'Location', render: (farmer: AdminFarmer) => [farmer.village, farmer.ward, farmer.sub_county, farmer.county].filter(Boolean).join(', ') || 'Not provided' },
		{ header: 'Cooperative', render: (farmer: AdminFarmer) => farmer.cooperative || 'Not provided' },
		{ header: 'Activity', render: (farmer: AdminFarmer) => `${farmer.total_orders ?? 0} orders · ${farmer.rating ?? 'N/A'} rating` },
		{ header: 'Actions', mobileRole: 'action' as const, render: (farmer: AdminFarmer) => <div className="flex items-center gap-1.5"><Link to={`/app/admin/farmers/${farmer.id}`} aria-label={`View farmer ${farmer.user_username || farmer.user_phone || farmer.id}`} title="View farmer" className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border text-muted-foreground hover:bg-muted"><Eye className="h-4 w-4" /></Link><button type="button" aria-label={`Edit farmer ${farmer.user_username || farmer.id}`} title="Edit farmer" onClick={() => setEditingFarmer(farmer)} className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border text-muted-foreground hover:bg-muted"><Pencil className="h-4 w-4" /></button><FarmerApprovalAction farmer={farmer} busy={busy === String(farmer.id)} onApprove={() => void runAction(String(farmer.id), () => approveAdminFarmer(farmer.id), 'Farmer approved.')} /></div> },
	]
	return <AdminPageLayout section="farmers" title="Farmers" loading={loading} error={error} notice={notice} onRefresh={refresh}><div className="mb-4 grid grid-cols-2 gap-3 sm:mb-6 sm:gap-4 xl:grid-cols-4"><StatCard title="Farmers" value={farmers.length} subtitle="Registered farm accounts" variant="flat" /><StatCard title="Verified groups" value={verifiedCount} subtitle="Cooperative endorsed" variant="flat" /><StatCard title="Awaiting review" value={farmers.length - verifiedCount} subtitle="Cooperative status pending" variant="flat" /><StatCard title="Orders" value={farmers.reduce((total, farmer) => total + (farmer.total_orders ?? 0), 0)} subtitle="Across farmer accounts" variant="flat" /></div><DataTable data={farmers} columns={columns} keyExtractor={(farmer) => String(farmer.id)} emptyMessage="No farmer profiles found." /><FarmerEditModal farmer={editingFarmer} onClose={() => setEditingFarmer(null)} onSaved={() => { setEditingFarmer(null); refresh() }} /></AdminPageLayout>
}