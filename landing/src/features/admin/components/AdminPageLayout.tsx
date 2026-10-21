import type { ReactNode } from 'react'

import { Button } from '../../../shared/components/ui/Button'

export type AdminSection = 'overview' | 'orders' | 'products' | 'users' | 'retailers' | 'staff' | 'farmers' | 'transport' | 'logistics' | 'disputes' | 'payouts' | 'audit' | 'analytics'

interface AdminPageLayoutProps {
	section: AdminSection
	title: string
	loading?: boolean
	error?: string | null
	notice?: string
	onRefresh: () => void
	children: ReactNode
}

export function AdminPageLayout({ title, loading = false, error, notice, onRefresh, children }: AdminPageLayoutProps) {
	return (
		<main className="mx-auto min-h-full max-w-7xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
			<header className="border-b border-border pb-4 sm:pb-6">
				<p className="text-xs font-bold uppercase tracking-[0.16em] text-primary">Mambonami operations</p>
				<div className="mt-2 flex flex-wrap items-end justify-between gap-4">
					<h1 className="text-2xl font-semibold text-primary-dark sm:text-3xl">{title}</h1>
					<Button variant="outline" size="sm" onClick={onRefresh}>Refresh</Button>
				</div>
			</header>

			{error && <div role="alert" className="mt-6 border-l-4 border-destructive bg-destructive/10 p-4 text-sm text-destructive">{error}</div>}
			{notice && <p role="status" className="mt-6 border-l-4 border-emerald-600 bg-emerald-50 p-4 text-sm text-emerald-900">{notice}</p>}
			{loading ? <div className="mt-5 space-y-3 sm:mt-8" aria-label="Loading admin records"><div className="h-16 animate-pulse bg-muted" /><div className="h-16 animate-pulse bg-muted" /><div className="h-16 animate-pulse bg-muted" /></div> : <section className="mt-4 sm:mt-6">{children}</section>}
		</main>
	)
}