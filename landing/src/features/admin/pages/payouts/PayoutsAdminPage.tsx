import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { adminResourceCaches, listAdminPayouts, useAdminResource } from '../../../../core/lib'
import type { Payout } from '../../../../core/lib/types/payouts'
import { PayoutStatus } from './components/PayoutStatus'

export function PayoutsAdminPage() {
	const { data, loading, error, notice, refresh } = useAdminResource(listAdminPayouts, adminResourceCaches.payouts)
	const payouts = data ?? []
	const columns = [
		{ header: 'Recipient', render: (payout: Payout) => <div><p className="font-semibold">{payout.recipient_type.replaceAll('_', ' ')}</p><p className="text-xs text-muted-foreground">User #{payout.recipient_user}</p></div> },
		{ header: 'Order', render: (payout: Payout) => payout.order_uuid || `#${payout.order}` },
		{ header: 'Amount', render: (payout: Payout) => `KES ${payout.amount}` },
		{ header: 'Status', render: (payout: Payout) => <PayoutStatus status={payout.status} /> },
		{ header: 'Created', render: (payout: Payout) => payout.created_at ? new Date(payout.created_at).toLocaleString() : 'Not recorded' },
		{ header: 'Details', render: (payout: Payout) => payout.error_message || payout.b2c_transaction_id || '—' },
	]
	return <AdminPageLayout section="payouts" title="Payouts" loading={loading} error={error} notice={notice} onRefresh={refresh}><DataTable data={payouts} columns={columns} keyExtractor={(payout) => payout.uuid} emptyMessage="No payouts found." /></AdminPageLayout>
}