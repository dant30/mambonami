import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { adminResourceCaches, approveAdminFarmer, listAdminFarmers, useAdminResource } from '../../../../core/lib'
import type { AdminFarmer } from '../../../../core/lib/types/admin'
import { FarmerApprovalAction } from './components/FarmerApprovalAction'

export function FarmersAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminFarmers, adminResourceCaches.farmers)
	const farmers = data ?? []
	const columns = [
		{ header: 'Farmer', render: (farmer: AdminFarmer) => <div><p className="font-semibold">{farmer.user_username || farmer.user_phone || `Farmer ${farmer.id}`}</p><p className="text-xs text-muted-foreground">{farmer.user_phone || 'Phone unavailable'}</p></div> },
		{ header: 'Location', render: (farmer: AdminFarmer) => [farmer.village, farmer.ward, farmer.sub_county, farmer.county].filter(Boolean).join(', ') || 'Not provided' },
		{ header: 'Cooperative', render: (farmer: AdminFarmer) => farmer.cooperative || 'Not provided' },
		{ header: 'Activity', render: (farmer: AdminFarmer) => `${farmer.total_orders ?? 0} orders · ${farmer.rating ?? 'N/A'} rating` },
		{ header: 'Review', render: (farmer: AdminFarmer) => <FarmerApprovalAction farmer={farmer} busy={busy === String(farmer.id)} onApprove={() => void runAction(String(farmer.id), () => approveAdminFarmer(farmer.id), 'Farmer approved.')} /> },
	]
	return <AdminPageLayout section="farmers" title="Farmers" loading={loading} error={error} notice={notice} onRefresh={refresh}><DataTable data={farmers} columns={columns} keyExtractor={(farmer) => String(farmer.id)} emptyMessage="No farmer profiles found." /></AdminPageLayout>
}