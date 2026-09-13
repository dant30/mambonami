import { evaluatePasswordStrength } from '../../../core/utils/passwordStrength'

export function PasswordStrength({ password }: { password: string }) {
	if (!password) return null
	const result = evaluatePasswordStrength(password)
	const color = result.level === 'weak' ? 'bg-destructive' : result.level === 'fair' ? 'bg-secondary' : 'bg-primary'
	return <div className="space-y-2 rounded-xl border border-border bg-muted/40 p-3"><div className="flex items-center justify-between text-xs font-semibold"><span>Password strength</span><span className="text-muted-foreground">{result.label}</span></div><div className="h-1.5 overflow-hidden rounded-full bg-border"><div className={`h-full ${color} transition-all`} style={{ width: `${result.percentage}%` }} /></div><div className="grid grid-cols-2 gap-1 text-[11px] text-muted-foreground">{result.criteria.map((criterion) => <span key={criterion.id} className={criterion.met ? 'text-primary' : ''}>{criterion.met ? '✓' : '○'} {criterion.label}</span>)}</div></div>
}