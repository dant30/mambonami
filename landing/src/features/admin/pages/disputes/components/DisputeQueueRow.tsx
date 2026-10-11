import { Badge } from '../../../../../shared/components/ui/Badge'
import { Button } from '../../../../../shared/components/ui/Button'
import type { Dispute } from '../../../../../core/lib/types/disputes'

const statusTone: Record<string, 'success' | 'warning' | 'danger' | 'info' | 'neutral'> = {
	open: 'danger',
	under_review: 'warning',
	resolved: 'success',
	rejected: 'neutral',
	closed: 'neutral',
	escalated: 'danger',
}

export function DisputeQueueRow({ dispute, onReview }: { dispute: Dispute; onReview: () => void }) {
	const canResolve = ['open', 'under_review'].includes(dispute.status)
	return <div className="flex min-w-[680px] items-center gap-5">
		<div className="min-w-0 flex-1">
			<p className="font-semibold text-foreground">{dispute.reason.replaceAll('_', ' ')}</p>
			<p className="mt-1 line-clamp-2 max-w-xl text-sm text-muted-foreground">{dispute.description}</p>
		</div>
		<div className="w-36 shrink-0">
			<p className="text-sm font-medium">Order #{dispute.order}</p>
			<p className="mt-1 text-xs text-muted-foreground">{dispute.raised_by_phone || `User #${dispute.raised_by}`}</p>
		</div>
		<div className="w-36 shrink-0 space-y-1.5">
			<Badge variant={statusTone[dispute.status] ?? 'neutral'} size="sm">{dispute.status.replaceAll('_', ' ')}</Badge>
			<p className="text-xs capitalize text-muted-foreground">{dispute.priority || 'medium'} priority</p>
		</div>
		<div className="w-28 shrink-0 text-xs text-muted-foreground">{dispute.created_at ? new Date(dispute.created_at).toLocaleDateString() : 'Date unavailable'}</div>
		<Button size="sm" variant={canResolve ? 'primary' : 'outline'} onClick={onReview}>{canResolve ? 'Review' : 'View'}</Button>
	</div>
}