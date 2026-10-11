import { Button } from '../../../../../shared/components/ui/Button'
import type { AdminUser } from '../../../../../core/lib/types/admin'

export function StaffAccountStatus({ member, busy, onToggle }: { member: AdminUser; busy: boolean; onToggle: () => void }) {
	return <Button size="sm" variant={member.is_active ? 'danger' : 'outline'} disabled={busy || member.is_superuser} onClick={onToggle}>{busy ? 'Saving' : member.is_superuser ? 'Superuser' : member.is_active ? 'Suspend' : 'Activate'}</Button>
}