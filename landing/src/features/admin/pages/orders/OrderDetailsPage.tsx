import { ArrowLeft, MapPin, Pencil, ReceiptText, Truck } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'

import { StatCard } from '../../../../shared/components/cards'
import { Card } from '../../../../shared/components/cards/Card'
import { Button } from '../../../../shared/components/ui'
import { AdminPageLayout } from '../../components'
import { getAdminOrder, updateAdminOrderStatus } from '../../../../core/lib'
import type { Order, OrderStatus } from '../../../../core/lib/types/orders'
import { OrderStatusBadge } from './components/OrderStatusBadge'
import { OrderStatusModal } from './components/OrderStatusModal'

function formatKes(value: string | number) {
	return `KES ${Number(value).toLocaleString('en-KE', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
}

export function OrderDetailsPage() {
	const { uuid = '' } = useParams()
	const [order, setOrder] = useState<Order | null>(null)
	const [loading, setLoading] = useState(true)
	const [error, setError] = useState('')
	const [notice, setNotice] = useState('')
	const [editing, setEditing] = useState(false)
	const [saving, setSaving] = useState(false)
	const [statusError, setStatusError] = useState('')
	const [reloadKey, setReloadKey] = useState(0)

	useEffect(() => {
		let active = true
		setLoading(true)
		setError('')
		getAdminOrder(uuid).then((result) => {
			if (active) setOrder(result)
		}).catch((requestError) => {
			if (active) setError(requestError instanceof Error ? requestError.message : 'Could not load order details.')
		}).finally(() => {
			if (active) setLoading(false)
		})
		return () => { active = false }
	}, [uuid, reloadKey])

	const refresh = () => setReloadKey((current) => current + 1)
	const updateStatus = async (status: OrderStatus) => {
		if (!order) return
		setSaving(true)
		setStatusError('')
		try {
			await updateAdminOrderStatus(order.uuid, status)
			setEditing(false)
			setNotice('Order status updated.')
			refresh()
		} catch (requestError) {
			setStatusError(requestError instanceof Error ? requestError.message : 'The order status could not be updated.')
		} finally {
			setSaving(false)
		}
	}

	const accountNumber = order?.account_number || (order ? `ORD-${order.id}` : 'Order details')
	const subOrders = order?.sub_orders ?? []
	const itemCount = subOrders.reduce((count, subOrder) => count + subOrder.items.length, 0)

	return <AdminPageLayout section="orders" title={accountNumber} loading={loading} error={error} notice={notice} onRefresh={refresh}>
		{order && <div className="space-y-5">
			<div className="flex flex-wrap items-center justify-between gap-3">
				<Link to="/app/admin/orders" className="inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-primary hover:text-primary-dark"><ArrowLeft className="h-4 w-4" />All orders</Link>
				<div className="flex items-center gap-2"><OrderStatusBadge status={order.status} /><Button type="button" size="sm" leftIcon={<Pencil className="h-4 w-4" />} onClick={() => { setStatusError(''); setEditing(true) }}>Update status</Button></div>
			</div>
			<div className="grid grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-4">
				<StatCard title="Order total" value={formatKes(order.total_amount)} subtitle={`${formatKes(order.delivery_fee)} delivery`} variant="flat" />
				<StatCard title="Line items" value={itemCount} subtitle={`${subOrders.length} farmer suborders`} variant="flat" />
				<StatCard title="Payment" value={order.stk_payment_status || (order.paid_at ? 'paid' : 'unpaid')} subtitle={order.stk_payment_message || (order.paid_at ? `Paid ${new Date(order.paid_at).toLocaleDateString()}` : 'Payment not confirmed')} variant="flat" />
				<StatCard title="Fulfilment" value={order.fulfillment_type === 'self_pickup' ? 'Pickup' : 'Delivery'} subtitle={order.scheduled_date ? new Date(`${order.scheduled_date}T00:00:00`).toLocaleDateString() : 'Not scheduled'} variant="flat" />
			</div>
			<div className="grid gap-4 lg:grid-cols-2">
				<Card padding="md">
					<h2 className="flex items-center gap-2 text-base font-semibold text-primary-dark"><ReceiptText className="h-4 w-4" />Order details</h2>
					<dl className="mt-4 grid grid-cols-2 gap-x-4 gap-y-4 text-sm">
						<Detail label="Order reference" value={accountNumber} />
						<Detail label="Buyer" value={order.buyer_name || order.buyer_phone || `Buyer ${order.buyer}`} />
						<Detail label="Buyer phone" value={order.buyer_phone || 'Not available'} />
						<Detail label="Created" value={new Date(order.created_at).toLocaleString()} />
						<Detail label="Scheduled window" value={`${order.scheduled_date} · ${order.scheduled_time_window}`} />
						<Detail label="Fulfilment" value={order.fulfillment_type === 'self_pickup' ? 'Customer pickup' : 'Delivery'} />
						<Detail label="Discount" value={formatKes(order.discount_amount)} />
						<Detail label="Platform commission" value={formatKes(order.platform_commission)} />
					</dl>
				</Card>
				<Card padding="md">
					<h2 className="flex items-center gap-2 text-base font-semibold text-primary-dark"><MapPin className="h-4 w-4" />Delivery and payment</h2>
					<p className="mt-4 text-sm leading-6 text-foreground">{order.delivery_address || [order.delivery_street, order.delivery_city, order.delivery_postal_code, order.delivery_landmark].filter(Boolean).join(', ') || 'No delivery address recorded.'}</p>
					<div className="mt-4 grid grid-cols-2 gap-4 text-sm">
						<Detail label="Payment reference" value={order.account_number || 'Not available'} />
						<Detail label="PayBill" value={order.paybill_number || 'Not available'} />
						<Detail label="Paid at" value={order.paid_at ? new Date(order.paid_at).toLocaleString() : 'Not paid'} />
						<Detail label="Delivered at" value={order.delivered_at ? new Date(order.delivered_at).toLocaleString() : 'Not delivered'} />
					</div>
				</Card>
			</div>
			<section aria-labelledby="admin-order-suborders">
				<h2 id="admin-order-suborders" className="mb-3 flex items-center gap-2 text-base font-semibold text-primary-dark"><Truck className="h-4 w-4" />Farmer suborders</h2>
				{subOrders.length ? <div className="space-y-3">{subOrders.map((subOrder) => <Card key={subOrder.id} padding="md">
					<div className="flex flex-wrap items-start justify-between gap-3"><div><p className="font-semibold text-primary-dark">Farmer {subOrder.farmer}{subOrder.farmer_phone ? ` · ${subOrder.farmer_phone}` : ''}</p><p className="mt-1 text-xs text-muted-foreground">Suborder #{subOrder.id} · {subOrder.status.replaceAll('_', ' ')}</p></div><p className="font-semibold">{formatKes(subOrder.subtotal)}</p></div>
					<div className="mt-3 divide-y divide-border border-t border-border">{subOrder.items.map((item) => <div key={item.id} className="flex flex-wrap items-center justify-between gap-2 py-3 text-sm"><span>{item.product_detail?.name || `Product ${item.product}`} · {item.quantity}</span><span>{formatKes(item.total_price)}</span></div>)}</div>
				</Card>)}</div> : <p className="rounded-lg border border-dashed border-border p-5 text-sm text-muted-foreground">No farmer suborders recorded.</p>}
			</section>
		</div>}
		<OrderStatusModal order={editing ? order : null} busy={saving} error={statusError} onClose={() => setEditing(false)} onSave={(status) => void updateStatus(status)} />
	</AdminPageLayout>
}

function Detail({ label, value }: { label: string; value: string }) {
	return <div className="min-w-0"><dt className="text-xs text-muted-foreground">{label}</dt><dd className="mt-1 break-words font-medium text-foreground">{value}</dd></div>
}
