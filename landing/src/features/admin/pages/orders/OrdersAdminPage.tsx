import { Eye, Pencil } from 'lucide-react'
import { useState } from 'react'
import { Link } from 'react-router-dom'

import { StatCard } from '../../../../shared/components/cards'
import { DataTable } from '../../../../shared/components/tables/DataTable'
import { Modal } from '../../../../shared/components/ui'
import { AdminPageLayout } from '../../components'
import { adminResourceCaches, listAdminOrders, updateAdminOrderStatus, useAdminResource, type Order, type OrderStatus } from '../../../../core/lib'
import { OrderStatusBadge } from './components/OrderStatusBadge'
import { OrderStatusModal } from './components/OrderStatusModal'

export function OrdersAdminPage() {
	const { data, loading, error, notice, refresh } = useAdminResource(listAdminOrders, adminResourceCaches.orders)
	const orders = data ?? []
	const [editingOrder, setEditingOrder] = useState<Order | null>(null)
	const [savingStatus, setSavingStatus] = useState(false)
	const [actionError, setActionError] = useState('')
	const [actionNotice, setActionNotice] = useState('')
	const saveStatus = async (status: OrderStatus) => {
		if (!editingOrder) return
		setSavingStatus(true)
		setActionError('')
		setActionNotice('')
		try {
			await updateAdminOrderStatus(editingOrder.uuid, status)
			setEditingOrder(null)
			setActionNotice('Order status updated.')
			refresh()
		} catch (requestError) {
			setActionError(requestError instanceof Error ? requestError.message : 'The order status could not be updated.')
		} finally {
			setSavingStatus(false)
		}
	}
	const inProgressCount = orders.filter((order) => ['paid_escrow', 'transport_assigned', 'picked_up'].includes(order.status)).length
	const columns = [
		{ header: 'Order / Buyer', mobileRole: 'title' as const, render: (order: Order) => <div><p className="font-bold text-primary">{order.account_number || `ORD-${order.id}`}</p><p className="mt-1 text-sm text-foreground">{order.buyer_name || order.buyer_phone || `Buyer ${order.buyer}`}</p></div> },
		{ header: 'Amount', mobileRole: 'summary' as const, render: (order: Order) => <span className="font-semibold">KES {order.total_amount}</span> },
		{ header: 'Items', mobileRole: 'detail' as const, render: (order: Order) => order.item_summary || `${order.sub_orders?.length ?? 0} farmer suborders` },
		{ header: 'Created', mobileRole: 'detail' as const, render: (order: Order) => new Date(order.created_at).toLocaleDateString() },
		{ header: 'Status', mobileRole: 'status' as const, render: (order: Order) => <OrderStatusBadge status={order.status} /> },
		{ header: 'Actions', mobileRole: 'action' as const, className: 'w-24', render: (order: Order) => <div className="flex items-center gap-1.5"><Link to={`/app/admin/orders/${order.uuid}`} aria-label={`View order ${order.account_number || order.id}`} title="View order" className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border text-muted-foreground transition hover:bg-muted hover:text-foreground"><Eye className="h-4 w-4" aria-hidden="true" /></Link><button type="button" aria-label={`Update order ${order.account_number || order.id}`} title="Update order" onClick={() => { setEditingOrder(order); setActionError('') }} className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border text-muted-foreground transition hover:bg-muted hover:text-foreground"><Pencil className="h-4 w-4" aria-hidden="true" /></button></div> },
	]

	return (
		<AdminPageLayout section="orders" title="Orders" loading={loading} error={error || actionError} notice={notice || actionNotice} onRefresh={refresh}>
			<div className="mb-4 grid grid-cols-2 gap-3 sm:mb-6 sm:gap-4 xl:grid-cols-4"><StatCard title="All orders" value={orders.length} subtitle="Recorded marketplace orders" variant="flat" /><StatCard title="Awaiting payment" value={orders.filter((order) => order.status === 'placed').length} subtitle="Placed and unpaid" variant="flat" /><StatCard title="In progress" value={inProgressCount} subtitle="Paid or being fulfilled" variant="flat" /><StatCard title="Delivered" value={orders.filter((order) => order.status === 'delivered').length} subtitle="Completed orders" variant="flat" /></div>
			<DataTable data={orders} columns={columns} keyExtractor={(order) => order.uuid} emptyMessage="No orders found." />
			<OrderStatusModal order={editingOrder} busy={savingStatus} error={actionError} onClose={() => setEditingOrder(null)} onSave={(status) => void saveStatus(status)} />
		</AdminPageLayout>
	)
}
