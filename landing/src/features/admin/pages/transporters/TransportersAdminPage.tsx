import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { adminResourceCaches, approveAdminTransportProvider, listAdminTransportProviders, useAdminResource } from '../../../../core/lib'
import type { AdminTransportProvider } from '../../../../core/lib/types/admin'
import { TransportApprovalAction } from './components/TransportApprovalAction'

export function TransportersAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminTransportProviders, adminResourceCaches.transportProviders)
	const providers = data ?? []
	const columns = [
		{ header: 'Provider', render: (provider: AdminTransportProvider) => <div><p className="font-semibold">{provider.user_username || provider.user_phone || `Provider ${provider.id}`}</p><p className="text-xs text-muted-foreground">{provider.user_phone || 'Phone unavailable'}</p></div> },
		{ header: 'Vehicle', render: (provider: AdminTransportProvider) => `${provider.vehicle_type || 'Unspecified'} · ${provider.license_plate || 'No plate'}` },
		{ header: 'Capacity', render: (provider: AdminTransportProvider) => `${provider.capacity_kg ?? 'N/A'} kg` },
		{ header: 'Deposit', render: (provider: AdminTransportProvider) => provider.deposit_paid ? 'Paid' : 'Unpaid' },
		{ header: 'Review', render: (provider: AdminTransportProvider) => <TransportApprovalAction provider={provider} busy={busy === String(provider.id)} onApprove={() => void runAction(String(provider.id), () => approveAdminTransportProvider(provider.id), 'Transport provider approved.')} /> },
	]
	return <AdminPageLayout section="transport" title="Transport providers" loading={loading} error={error} notice={notice} onRefresh={refresh}><DataTable data={providers} columns={columns} keyExtractor={(provider) => String(provider.id)} emptyMessage="No transport providers found." /></AdminPageLayout>
}