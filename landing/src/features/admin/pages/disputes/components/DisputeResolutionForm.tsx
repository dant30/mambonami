import { Button } from '../../../../../shared/components/ui/Button'
import type { DisputeResolutionInput } from '../../../../../core/lib/types/disputes'

const resolutions: DisputeResolutionInput['resolution'][] = [
	'full_refund', 'partial_refund', 'replacement', 'store_credit', 'compensate_farmer', 'compensate_provider', 'no_action',
]

export function DisputeResolutionForm({ busy, onResolve }: { busy: boolean; onResolve: (input: DisputeResolutionInput) => void }) {
	return <form className="grid gap-3 border-t border-border pt-4 md:grid-cols-[1fr_1fr_2fr_auto]" onSubmit={(event) => {
		event.preventDefault()
		const fields = new FormData(event.currentTarget)
		const input: DisputeResolutionInput = {
			resolution: String(fields.get('resolution')) as DisputeResolutionInput['resolution'],
			resolution_notes: String(fields.get('resolution_notes') ?? '').trim(),
		}
		const amount = String(fields.get('refund_amount') ?? '').trim()
		if (amount) input.refund_amount = amount
		onResolve(input)
	}}>
		<select name="resolution" aria-label="Resolution" className="min-h-10 rounded-md border border-border bg-background px-3 text-sm">{resolutions.map((resolution) => <option key={resolution} value={resolution}>{resolution.replaceAll('_', ' ')}</option>)}</select>
		<input name="refund_amount" inputMode="decimal" placeholder="Refund amount (KES)" aria-label="Refund amount in KES" className="min-h-10 rounded-md border border-border bg-background px-3 text-sm" />
		<input name="resolution_notes" placeholder="Resolution notes" aria-label="Resolution notes" className="min-h-10 rounded-md border border-border bg-background px-3 text-sm" />
		<Button type="submit" size="sm" disabled={busy}>{busy ? 'Saving' : 'Resolve'}</Button>
	</form>
}