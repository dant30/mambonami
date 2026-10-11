import { Button } from '../../../../../shared/components/ui/Button'
import type { AdminUser } from '../../../../../core/lib/types/admin'

export function UserStatusAction({ user, busy, onToggle }: { user: AdminUser; busy: boolean; onToggle: () => void }) {
	const protectedAccount = user.is_superuser
	return <Button size="sm" variant={user.is_active ? 'danger' : 'outline'} disabled={busy || protectedAccount} onClick={onToggle}>
		{busy ? 'Saving' : protectedAccount ? 'Superuser' : user.is_active ? 'Suspend' : 'Activate'}
	</Button>
}