export function AuditActionLabel({ action }: { action?: string }) {
	return <span className="font-semibold capitalize text-foreground">{(action || 'activity').replaceAll('_', ' ')}</span>
}