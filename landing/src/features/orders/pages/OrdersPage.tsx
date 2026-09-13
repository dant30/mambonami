import { Link } from 'react-router-dom'

export function OrdersPage() {
	return (
		<main className="mx-auto min-h-screen max-w-5xl px-4 py-10 sm:px-6 lg:px-8">
			<div className="rounded-2xl border border-dashed border-border bg-muted/40 p-10 text-center">
				<p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Your marketplace activity</p>
				<h1 className="mt-2 text-4xl font-semibold text-primary-dark">Orders</h1>
				<p className="mt-3 text-sm text-muted-foreground">
					Orders are moving to the role dashboards as part of the feature cleanup.
				</p>
				<Link to="/" className="mt-5 inline-flex rounded-full bg-primary px-5 py-2.5 text-sm font-bold text-primary-foreground">
					Return home
				</Link>
			</div>
		</main>
	)
}