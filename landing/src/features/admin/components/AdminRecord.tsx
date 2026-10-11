import type { ReactNode } from 'react'

export function AdminRecord({ title, detail, action }: { title: string; detail: string; action?: ReactNode }) {
	return <article className="flex flex-col gap-4 border-b border-border py-4 sm:flex-row sm:items-center sm:justify-between"><div className="min-w-0"><h2 className="break-words font-semibold text-foreground">{title}</h2><p className="mt-1 break-words text-sm text-muted-foreground">{detail}</p></div>{action && <div className="shrink-0">{action}</div>}</article>
}