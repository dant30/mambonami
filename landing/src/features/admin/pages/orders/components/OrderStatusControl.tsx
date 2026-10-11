import { useState } from 'react'

import { Button, Select } from '../../../../../shared/components/ui'
import type { Order, OrderStatus } from '../../../../../core/lib/types/orders'

const statuses: OrderStatus[] = ['cart', 'placed', 'paid_escrow', 'transport_assigned', 'picked_up', 'delivered', 'cancelled', 'disputed']

export function OrderStatusControl({ order, busy, onSave }: { order: Order; busy: boolean; onSave: (status: OrderStatus) => void }) {
	const [status, setStatus] = useState<OrderStatus>(order.status)
	return <div className="flex min-w-56 items-center gap-2">
		<Select aria-label={`New status for order ${order.uuid}`} value={status} onChange={(value) => setStatus(value as OrderStatus)} className="min-w-0 flex-1" options={statuses.map((option) => ({ value: option, label: option.replaceAll('_', ' ') }))} />
		<Button size="sm" disabled={busy || status === order.status} onClick={() => onSave(status)}>{busy ? 'Saving' : 'Save'}</Button>
	</div>
}