import { Button } from '../../../../../shared/components/ui/Button'
import type { AdminFarmer } from '../../../../../core/lib/types/admin'

export function FarmerApprovalAction({ farmer, busy, onApprove }: { farmer: AdminFarmer; busy: boolean; onApprove: () => void }) {
	return farmer.coop_verified ? <span className="text-sm font-semibold text-emerald-700">Approved</span> : <Button size="sm" disabled={busy} onClick={onApprove}>{busy ? 'Saving' : 'Approve farmer'}</Button>
}