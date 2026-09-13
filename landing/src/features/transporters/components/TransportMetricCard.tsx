import type { ReactNode } from 'react'

export function TransportMetricCard({ label, value, detail, icon }: { label: string; value: string; detail: string; icon: ReactNode }) {
	return <div className="rounded-2xl border border-border bg-card p-5"><div className="flex items-center justify-between"><p className="text-sm text-muted-foreground">{label}</p><span className="text-primary">{icon}</span></div><p className="mt-3 text-3xl font-semibold text-primary-dark">{value}</p><p className="mt-2 text-xs text-muted-foreground">{detail}</p></div>
}
