import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { adminResourceCaches, listAdminOrders, updateAdminOrderStatus, useAdminResource, type Order, type OrderStatus } from '../../../../core/lib'
import { OrderStatusControl } from './components/OrderStatusControl'

export function OrdersAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminOrders, adminResourceCaches.orders)
	const orders = data ?? []
	const saveStatus = (order: Order, status: OrderStatus) => {
		if (!window.confirm(`Change order ${order.uuid} from ${order.status} to ${status}?`)) return
		void runAction(order.uuid, () => updateAdminOrderStatus(order.uuid, status), 'Order status updated.')
	}
	const columns = [
		{ header: 'Order / Buyer', render: (order: Order) => <div><p className="font-bold text-primary">{order.uuid}</p><p className="mt-1 text-sm text-foreground">{order.buyer_name || order.buyer_phone || `Buyer ${order.buyer}`}</p></div> },
		{ header: 'Amount', render: (order: Order) => <span className="font-semibold">KES {order.total_amount}</span> },
		{ header: 'Items', render: (order: Order) => order.item_summary || `${order.sub_orders?.length ?? 0} farmer suborders` },
		{ header: 'Created', render: (order: Order) => new Date(order.created_at).toLocaleDateString() },
		{ header: 'Status', render: (order: Order) => <OrderStatusControl order={order} busy={busy === order.uuid} onSave={(status) => saveStatus(order, status)} /> },
	]

	return (
		<AdminPageLayout section="orders" title="Orders" loading={loading} error={error} notice={notice} onRefresh={refresh}>
			<DataTable data={orders} columns={columns} keyExtractor={(order) => order.uuid} emptyMessage="No orders found." />
		</AdminPageLayout>
	)
}
