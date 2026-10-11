import type { PayoutStatus as PayoutStatusValue } from '../../../../../core/lib/types/payouts'

export function PayoutStatus({ status }: { status: PayoutStatusValue }) {
	return <span className="inline-flex rounded-sm border border-border px-2 py-1 text-xs font-semibold capitalize">{status.replaceAll('_', ' ')}</span>
}