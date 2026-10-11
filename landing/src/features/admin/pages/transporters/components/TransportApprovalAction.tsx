import { Button } from '../../../../../shared/components/ui/Button'
import type { AdminTransportProvider } from '../../../../../core/lib/types/admin'

export function TransportApprovalAction({ provider, busy, onApprove }: { provider: AdminTransportProvider; busy: boolean; onApprove: () => void }) {
	return provider.is_approved ? <span className="text-sm font-semibold text-emerald-700">Approved</span> : <Button size="sm" disabled={busy} onClick={onApprove}>{busy ? 'Saving' : 'Approve provider'}</Button>
}