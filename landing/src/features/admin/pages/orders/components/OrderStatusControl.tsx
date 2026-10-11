import { useState } from 'react'

import { Button } from '../../../../../shared/components/ui/Button'
import type { Order, OrderStatus } from '../../../../../core/lib/types/orders'

const statuses: OrderStatus[] = ['cart', 'placed', 'paid_escrow', 'transport_assigned', 'picked_up', 'delivered', 'cancelled', 'disputed']

export function OrderStatusControl({ order, busy, onSave }: { order: Order; busy: boolean; onSave: (status: OrderStatus) => void }) {
	const [status, setStatus] = useState<OrderStatus>(order.status)
	return <div className="flex min-w-56 items-center gap-2">
		<select aria-label={`New status for order ${order.uuid}`} value={status} onChange={(event) => setStatus(event.target.value as OrderStatus)} className="min-h-10 min-w-0 flex-1 rounded-md border border-border bg-background px-2 text-sm">
			{statuses.map((option) => <option key={option} value={option}>{option.replaceAll('_', ' ')}</option>)}
		</select>
		<Button size="sm" disabled={busy || status === order.status} onClick={() => onSave(status)}>{busy ? 'Saving' : 'Save'}</Button>
	</div>
}