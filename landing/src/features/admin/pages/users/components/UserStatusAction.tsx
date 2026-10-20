import { ShieldCheck, ShieldOff } from 'lucide-react'
import type { AdminUser } from '../../../../../core/lib/types/admin'

export function UserStatusAction({ user, busy, disabled = false, onToggle }: { user: AdminUser; busy: boolean; disabled?: boolean; onToggle: () => void }) {
	const action = user.is_active ? 'Suspend' : 'Activate'
	const Icon = user.is_active ? ShieldOff : ShieldCheck
	return <button
		type="button"
		aria-label={`${action} ${user.display_name || user.phone}`}
		title={busy ? 'Saving status' : action}
		disabled={busy || disabled}
		onClick={onToggle}
		className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border text-muted-foreground transition hover:bg-muted hover:text-foreground disabled:cursor-not-allowed disabled:opacity-40"
	>
		<Icon className="h-4 w-4" aria-hidden="true" />
	</button>
}