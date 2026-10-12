import type { ReactNode } from 'react'
import { Link } from 'react-router-dom'

import { Button } from '../../../shared/components/ui/Button'

export const adminSections = [
	{ id: 'overview', label: 'Overview', path: '/app/admin' },
	{ id: 'orders', label: 'Orders', path: '/app/admin/orders' },
	{ id: 'products', label: 'Products', path: '/app/admin/products' },
	{ id: 'users', label: 'Users', path: '/app/admin/users' },
	{ id: 'retailers', label: 'Retailers', path: '/app/admin/retailers' },
	{ id: 'staff', label: 'Staff', path: '/app/admin/staff' },
	{ id: 'farmers', label: 'Farmers', path: '/app/admin/farmers' },
	{ id: 'transport', label: 'Transport', path: '/app/admin/transport' },
	{ id: 'disputes', label: 'Disputes', path: '/app/admin/disputes' },
	{ id: 'payouts', label: 'Payouts', path: '/app/admin/payouts' },
	{ id: 'audit', label: 'Audit log', path: '/app/admin/audit' },
 	{ id: 'analytics', label: 'Analytics', path: '/app/admin/analytics' },
] as const

export type AdminSection = (typeof adminSections)[number]['id']

interface AdminPageLayoutProps {
	section: AdminSection
	title: string
	loading?: boolean
	error?: string | null
	notice?: string
	onRefresh: () => void
	children: ReactNode
}

export function AdminPageLayout({ section, title, loading = false, error, notice, onRefresh, children }: AdminPageLayoutProps) {
	return (
		<main className="mx-auto min-h-full max-w-7xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
			<header className="border-b border-border pb-4 sm:pb-6">
				<p className="text-xs font-bold uppercase tracking-[0.16em] text-primary">Mambonami operations</p>
				<div className="mt-2 flex flex-wrap items-end justify-between gap-4">
					<h1 className="text-2xl font-semibold text-primary-dark sm:text-3xl">{title}</h1>
					<Button variant="outline" size="sm" onClick={onRefresh}>Refresh</Button>
				</div>
				<nav className="-mb-4 mt-4 flex gap-1 overflow-x-auto sm:-mb-6 sm:mt-6" aria-label="Admin sections">
					{adminSections.map(({ id, label, path }) => <Link key={id} to={path} aria-current={id === section ? 'page' : undefined} className={`min-h-11 whitespace-nowrap border-b-2 px-3 py-3 text-xs font-semibold transition sm:text-sm ${id === section ? 'border-primary text-primary' : 'border-transparent text-muted-foreground hover:text-foreground'}`}>{label}</Link>)}
				</nav>
			</header>

			{error && <div role="alert" className="mt-6 border-l-4 border-destructive bg-destructive/10 p-4 text-sm text-destructive">{error}</div>}
			{notice && <p role="status" className="mt-6 border-l-4 border-emerald-600 bg-emerald-50 p-4 text-sm text-emerald-900">{notice}</p>}
			{loading ? <div className="mt-5 space-y-3 sm:mt-8" aria-label="Loading admin records"><div className="h-16 animate-pulse bg-muted" /><div className="h-16 animate-pulse bg-muted" /><div className="h-16 animate-pulse bg-muted" /></div> : <section className="mt-4 sm:mt-6">{children}</section>}
		</main>
	)
}