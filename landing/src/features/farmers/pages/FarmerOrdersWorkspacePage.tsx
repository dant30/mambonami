import { Check, ClipboardList, MapPin, PackageCheck, X } from 'lucide-react'
import { Link } from 'react-router-dom'

import { useFarmerOrderActions, useFarmerSubOrders } from '../../../core/lib'
import { formatRelativeTime } from '../../../core/utils'

export function FarmerOrdersWorkspacePage() {
	const { subOrders, isLoading, error, refresh } = useFarmerSubOrders()
	const actions = useFarmerOrderActions()

	const run = async (action: () => Promise<unknown>) => {
		try {
			await action()
			refresh()
		} catch {
			return
		}
	}

	return (
		<main className="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
			<header className="border-b border-border pb-8">
				<p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Farm operations</p>
				<h1 className="mt-2 text-3xl font-semibold text-primary-dark sm:text-4xl">Orders received</h1>
				<p className="mt-3 text-sm text-muted-foreground">Confirm buyer orders, prepare stock, and mark each fulfilment ready for collection.</p>
			</header>

			{Boolean(error) && <p role="alert" className="mt-6 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">Unable to load incoming orders. Refresh the page to try again.</p>}
			{Boolean(actions.error) && <p role="alert" className="mt-6 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">That order action could not be completed. Check your connection and try again.</p>}

			{isLoading ? (
				<div className="mt-8 space-y-3" aria-label="Loading orders">{[1, 2, 3].map((item) => <div key={item} className="h-32 animate-pulse rounded-2xl bg-muted" />)}</div>
			) : subOrders.length === 0 ? (
				<div className="mt-8 rounded-2xl border border-dashed border-border p-12 text-center">
					<ClipboardList className="mx-auto h-9 w-9 text-primary" />
					<h2 className="mt-4 text-xl font-semibold text-primary-dark">No incoming orders yet</h2>
					<p className="mt-2 text-sm text-muted-foreground">Published products will appear here when buyers place orders.</p>
					<Link to="/app/farmer/products" className="mt-5 inline-flex rounded-full border border-border px-4 py-2 text-sm font-semibold text-primary-dark">Review my products</Link>
				</div>
			) : (
				<div className="mt-8 grid gap-5 lg:grid-cols-2">
					{subOrders.map((subOrder) => {
						const busy = actions.busyId === subOrder.id
						const paid = subOrder.order_status === 'paid_escrow'
						return (
							<article key={subOrder.id} className="rounded-2xl border border-border bg-card p-6 shadow-sm">
								<div className="flex items-start justify-between gap-4">
									<div>
										<p className="text-xs font-bold uppercase tracking-[0.14em] text-primary">Sub-order #{subOrder.id}</p>
										<h2 className="mt-2 text-xl font-semibold capitalize text-primary-dark">{subOrder.status.replaceAll('_', ' ')}</h2>
									</div>
									<span className="rounded-full bg-muted px-3 py-1 text-xs font-bold capitalize text-muted-foreground">{subOrder.status}</span>
								</div>
								<div className="mt-5 space-y-3 text-sm text-muted-foreground">
									{subOrder.items.map((item) => <p key={item.id} className="flex items-start justify-between gap-4"><span>{item.product_detail?.name || 'Produce'} <span className="text-foreground">× {item.quantity} {item.product_detail?.unit || 'unit'}</span></span><span className="shrink-0 font-semibold text-foreground">KSh {Number(item.total_price).toLocaleString()}</span></p>)}
								</div>
								<div className="mt-5 flex flex-wrap items-center justify-between gap-3 border-t border-border pt-4 text-sm">
									<span className="text-muted-foreground">{formatRelativeTime(subOrder.created_at)}</span>
									<span className="font-bold text-primary-dark">Payout KSh {Number(subOrder.farmer_payout).toLocaleString()}</span>
								</div>
								<div className="mt-5 flex flex-wrap gap-2">
									{subOrder.status === 'pending' && subOrder.order_status === 'placed' && <>
										<p className="w-full text-sm text-muted-foreground">Waiting for the buyer’s payment before you can confirm.</p>
										<button type="button" disabled={busy} onClick={() => void run(() => actions.reject(subOrder.id))} className="inline-flex items-center gap-2 rounded-full border border-destructive/30 px-4 py-2.5 text-sm font-bold text-destructive disabled:opacity-50"><X className="h-4 w-4" />Reject unpaid order</button>
									</>}
									{subOrder.status === 'pending' && paid && <button type="button" disabled={busy} onClick={() => void run(() => actions.confirm(subOrder.id))} className="inline-flex items-center gap-2 rounded-full bg-primary px-4 py-2.5 text-sm font-bold text-primary-foreground disabled:opacity-50"><Check className="h-4 w-4" />Confirm paid order</button>}
									{subOrder.status === 'confirmed' && paid && <button type="button" disabled={busy} onClick={() => void run(() => actions.markReady(subOrder.id))} className="inline-flex items-center gap-2 rounded-full bg-primary px-4 py-2.5 text-sm font-bold text-primary-foreground disabled:opacity-50"><PackageCheck className="h-4 w-4" />Mark ready for pickup</button>}
									{subOrder.status === 'ready' && <p className="flex items-center gap-2 text-sm font-semibold text-primary"><MapPin className="h-4 w-4" />Ready for transporter collection</p>}
									<Link to={`/app/farmer/orders/${subOrder.id}`} className="ml-auto inline-flex items-center rounded-full border border-border px-4 py-2.5 text-sm font-semibold text-primary-dark hover:bg-muted">Order details</Link>
								</div>
							</article>
						)
					})}
				</div>
			)}
		</main>
	)
}
