export function AuditActionLabel({ action }: { action?: string }) {
	return <span className="font-semibold capitalize text-foreground">{(action || 'activity').replaceAll('_', ' ')}</span>
}

export function SecuritySeverityLabel({ severity }: { severity: string }) {
	const styles: Record<string, string> = {
		low: 'border-emerald-200 bg-emerald-50 text-emerald-800',
		medium: 'border-amber-200 bg-amber-50 text-amber-800',
		high: 'border-orange-200 bg-orange-50 text-orange-800',
		critical: 'border-rose-200 bg-rose-50 text-rose-800',
	}
	return <span className={`inline-flex rounded-full border px-2.5 py-1 text-xs font-bold capitalize ${styles[severity] || 'border-border bg-muted text-foreground'}`}>{severity}</span>
}