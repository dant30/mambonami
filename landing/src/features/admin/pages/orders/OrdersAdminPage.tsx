import { useAdminOrders } from '../../../../core/lib'

export function OrdersAdminPage() {
	const { orders, isLoading, hasError } = useAdminOrders()

	return (
		<main className="mx-auto min-h-screen max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
			<div>
				<p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Operations</p>
				<h1 className="mt-2 text-4xl font-semibold text-primary-dark">Orders</h1>
				<p className="mt-2 text-sm text-muted-foreground">Monitor every marketplace order and its delivery status.</p>
			</div>

			<div className="mt-8 space-y-4">
				{isLoading && <div className="h-36 animate-pulse rounded-2xl bg-muted" />}
				{hasError && <p role="alert" className="rounded-xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive">We could not load admin orders.</p>}
				{!isLoading && !hasError && orders.length === 0 && <p className="rounded-2xl border border-dashed border-border p-10 text-center text-sm text-muted-foreground">No orders found.</p>}
				{orders.map((order) => (
					<div key={order.uuid} className="rounded-2xl border border-border bg-card p-5 shadow-sm">
						<div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
							<div>
								<p className="text-xs font-bold uppercase tracking-[0.16em] text-primary">{order.uuid}</p>
								<h2 className="mt-1 text-lg font-semibold text-primary-dark">{order.buyer_name ?? 'Buyer'}</h2>
							</div>
							<span className="rounded-full border border-primary/30 bg-primary/5 px-3 py-1 text-xs font-semibold uppercase tracking-[0.12em] text-primary">{order.status}</span>
						</div>

						<div className="mt-4 grid gap-3 sm:grid-cols-3">
							<div className="rounded-xl bg-muted/50 p-3">
								<p className="text-xs uppercase tracking-[0.12em] text-muted-foreground">Amount</p>
								<p className="mt-1 font-semibold text-foreground">{order.total_amount}</p>
							</div>
							<div className="rounded-xl bg-muted/50 p-3">
								<p className="text-xs uppercase tracking-[0.12em] text-muted-foreground">Created</p>
								<p className="mt-1 font-semibold text-foreground">{new Date(order.created_at).toLocaleDateString()}</p>
							</div>
							<div className="rounded-xl bg-muted/50 p-3">
								<p className="text-xs uppercase tracking-[0.12em] text-muted-foreground">Items</p>
								<p className="mt-1 font-semibold text-foreground">{order.item_summary ?? 'No summary available'}</p>
							</div>
						</div>
					</div>
				))}
			</div>
		</main>
	)
}
