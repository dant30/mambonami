import { Button } from '../../../../../shared/components/ui/Button'
import type { AdminUser } from '../../../../../core/lib/types/admin'

export function StaffAccountStatus({ member, busy, onToggle, onEdit }: { member: AdminUser; busy: boolean; onToggle: () => void; onEdit: () => void }) {
	return <div className="flex items-center gap-2"><Button size="sm" variant="outline" onClick={onEdit}>Edit</Button><Button size="sm" variant={member.is_active ? 'danger' : 'outline'} disabled={busy || member.is_superuser} onClick={onToggle}>{busy ? 'Saving' : member.is_superuser ? 'Superuser' : member.is_active ? 'Suspend' : 'Activate'}</Button></div>
}