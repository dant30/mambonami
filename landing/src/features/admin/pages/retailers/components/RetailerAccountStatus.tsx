import { Button } from '../../../../../shared/components/ui/Button'
import type { AdminUser } from '../../../../../core/lib/types/admin'

export function RetailerAccountStatus({ retailer, busy, onToggle }: { retailer: AdminUser; busy: boolean; onToggle: () => void }) {
	return <Button size="sm" variant={retailer.is_active ? 'danger' : 'outline'} disabled={busy || retailer.is_superuser} onClick={onToggle}>{busy ? 'Saving' : retailer.is_active ? 'Suspend' : 'Activate'}</Button>
}