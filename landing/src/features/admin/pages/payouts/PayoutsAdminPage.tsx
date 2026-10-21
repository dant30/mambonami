import { DataTable } from '../../../../shared/components/tables/DataTable'
import { StatCard } from '../../../../shared/components/cards'
import { AdminPageLayout } from '../../components'
import { adminResourceCaches, listAdminPayouts, useAdminResource } from '../../../../core/lib'
import type { Payout } from '../../../../core/lib/types/payouts'
import { PayoutStatus } from './components/PayoutStatus'

export function PayoutsAdminPage() {
	const { data, loading, error, notice, refresh } = useAdminResource(listAdminPayouts, adminResourceCaches.payouts)
	const payouts = data ?? []
	const completedCount = payouts.filter((payout) => payout.status === 'completed').length
	const failedCount = payouts.filter((payout) => payout.status === 'failed').length
	const columns = [
		{ header: 'Recipient', mobileRole: 'title' as const, render: (payout: Payout) => <div><p className="font-semibold">{payout.recipient_type.replaceAll('_', ' ')}</p><p className="text-xs text-muted-foreground">User #{payout.recipient_user}</p></div> },
		{ header: 'Order', mobileRole: 'detail' as const, render: (payout: Payout) => payout.order_uuid || `#${payout.order}` },
		{ header: 'Amount', mobileRole: 'summary' as const, render: (payout: Payout) => `KES ${payout.amount}` },
		{ header: 'Status', mobileRole: 'status' as const, render: (payout: Payout) => <PayoutStatus status={payout.status} /> },
		{ header: 'Created', mobileRole: 'detail' as const, render: (payout: Payout) => payout.created_at ? new Date(payout.created_at).toLocaleString() : 'Not recorded' },
		{ header: 'Details', mobileRole: 'detail' as const, render: (payout: Payout) => payout.error_message || payout.b2c_transaction_id || '—' },
	]
	return <AdminPageLayout section="payouts" title="Payouts" loading={loading} error={error} notice={notice} onRefresh={refresh}><div className="mb-4 grid grid-cols-2 gap-3 sm:mb-6 sm:gap-4 xl:grid-cols-4"><StatCard title="Payouts" value={payouts.length} subtitle="All payout records" variant="flat" /><StatCard title="Completed" value={completedCount} subtitle={`KES ${payouts.filter((payout) => payout.status === 'completed').reduce((total, payout) => total + Number(payout.amount), 0).toLocaleString()}`} variant="flat" /><StatCard title="Pending" value={payouts.filter((payout) => ['pending', 'processing', 'retry'].includes(payout.status)).length} subtitle="Awaiting settlement or retry" variant="flat" /><StatCard title="Failed" value={failedCount} subtitle="Require investigation" variant="flat" /></div><DataTable data={payouts} columns={columns} keyExtractor={(payout) => payout.uuid} emptyMessage="No payouts found." /></AdminPageLayout>
}