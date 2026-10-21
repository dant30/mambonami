import { Badge } from '../../../../../shared/components/ui'
import type { TripStatus } from '../../../../../core/lib/types/logisticts'

const labels: Record<TripStatus, string> = {
	created: 'Created',
	offered: 'Offered',
	accepted: 'Accepted',
	en_route_pickup: 'En route to pickup',
	arrived_pickup: 'At pickup',
	picked_up: 'Picked up',
	en_route_delivery: 'En route to delivery',
	arrived_delivery: 'At delivery',
	otp_pending: 'Awaiting OTP',
	delivered: 'Delivered',
	cancelled: 'Cancelled',
	failed: 'Failed',
	disputed: 'Disputed',
}

const variants: Record<TripStatus, 'success' | 'warning' | 'info' | 'neutral' | 'danger'> = {
	created: 'neutral',
	offered: 'warning',
	accepted: 'info',
	en_route_pickup: 'info',
	arrived_pickup: 'info',
	picked_up: 'info',
	en_route_delivery: 'info',
	arrived_delivery: 'warning',
	otp_pending: 'warning',
	delivered: 'success',
	cancelled: 'danger',
	failed: 'danger',
	disputed: 'danger',
}

export function TripStatusBadge({ status }: { status: TripStatus }) {
	return <Badge variant={variants[status]} size="sm">{labels[status]}</Badge>
}