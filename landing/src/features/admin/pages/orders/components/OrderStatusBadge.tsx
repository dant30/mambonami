import { Badge } from '../../../../../shared/components/ui'
import type { OrderStatus } from '../../../../../core/lib/types/orders'

const statusLabels: Record<OrderStatus, string> = {
	cart: 'Cart',
	placed: 'Awaiting payment',
	paid_escrow: 'Paid',
	transport_assigned: 'Transport assigned',
	picked_up: 'Picked up',
	delivered: 'Delivered',
	cancelled: 'Cancelled',
	disputed: 'Disputed',
}

const statusVariants: Record<OrderStatus, 'success' | 'warning' | 'info' | 'neutral' | 'danger'> = {
	cart: 'neutral',
	placed: 'warning',
	paid_escrow: 'success',
	transport_assigned: 'info',
	picked_up: 'info',
	delivered: 'success',
	cancelled: 'danger',
	disputed: 'danger',
}

export function OrderStatusBadge({ status }: { status: OrderStatus }) {
	return <Badge variant={statusVariants[status]} size="sm">{statusLabels[status]}</Badge>
}