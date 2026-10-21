import { DataTable } from '../../../../shared/components/tables/DataTable'
import { StatCard } from '../../../../shared/components/cards'
import { AdminPageLayout } from '../../components'
import { adminResourceCaches, approveAdminTransportProvider, listAdminTransportProviders, useAdminResource } from '../../../../core/lib'
import type { AdminTransportProvider } from '../../../../core/lib/types/admin'
import { TransportApprovalAction } from './components/TransportApprovalAction'

export function TransportersAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminTransportProviders, adminResourceCaches.transportProviders)
	const providers = data ?? []
	const approvedCount = providers.filter((provider) => provider.is_approved).length
	const columns = [
		{ header: 'Provider', render: (provider: AdminTransportProvider) => <div><p className="font-semibold">{provider.user_username || provider.user_phone || `Provider ${provider.id}`}</p><p className="text-xs text-muted-foreground">{provider.user_phone || 'Phone unavailable'}</p></div> },
		{ header: 'Vehicle', render: (provider: AdminTransportProvider) => `${provider.vehicle_type || 'Unspecified'} · ${provider.license_plate || 'No plate'}` },
		{ header: 'Capacity', render: (provider: AdminTransportProvider) => `${provider.capacity_kg ?? 'N/A'} kg` },
		{ header: 'Deposit', render: (provider: AdminTransportProvider) => provider.deposit_paid ? 'Paid' : 'Unpaid' },
		{ header: 'Review', render: (provider: AdminTransportProvider) => <TransportApprovalAction provider={provider} busy={busy === String(provider.id)} onApprove={() => void runAction(String(provider.id), () => approveAdminTransportProvider(provider.id), 'Transport provider approved.')} /> },
	]
	return <AdminPageLayout section="transport" title="Transport providers" loading={loading} error={error} notice={notice} onRefresh={refresh}><div className="mb-4 grid grid-cols-2 gap-3 sm:mb-6 sm:gap-4 xl:grid-cols-4"><StatCard title="Providers" value={providers.length} subtitle="Registered transport accounts" variant="flat" /><StatCard title="Approved" value={approvedCount} subtitle="Eligible for dispatch" variant="flat" /><StatCard title="Awaiting review" value={providers.length - approvedCount} subtitle="Approval required" variant="flat" /><StatCard title="Online" value={providers.filter((provider) => provider.is_online && provider.available).length} subtitle="Currently available" variant="flat" /></div><DataTable data={providers} columns={columns} keyExtractor={(provider) => String(provider.id)} emptyMessage="No transport providers found." /></AdminPageLayout>
}