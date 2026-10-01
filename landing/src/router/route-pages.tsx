import { Outlet } from 'react-router-dom'

import { useSeo } from '../core/hooks'
import { MainLayout } from '../shared/layouts'

export function PublicLayout() {
	return <MainLayout><Outlet /></MainLayout>
}

export function NotFound() {
	useSeo({ title: 'Page Not Found | MAMBONAMI', path: '/404', noIndex: true })
	return (
		<main className="flex min-h-screen flex-col items-center justify-center gap-4 px-6 text-center">
			<p className="text-sm font-semibold uppercase tracking-[0.18em] text-primary">Page not found</p>
			<h1 className="text-4xl font-semibold">That route does not exist.</h1>
			<a href="/" className="rounded-full bg-primary px-5 py-2 font-semibold text-primary-foreground">Return home</a>
		</main>
	)
}
