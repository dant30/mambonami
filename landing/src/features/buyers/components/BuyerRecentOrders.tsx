import { ArrowRight, Package } from 'lucide-react'
import { Link } from 'react-router-dom'

import type { Order } from '../../../core/lib'
import { Skeleton } from '../../../shared/components/ui'

function formatStatus(status: string | null | undefined) { return String(status || 'processing').replaceAll('_', ' ') }
function money(value: string | number) { return `KSh ${Number(value).toLocaleString()}` }

export function BuyerRecentOrders({ orders, isLoading }: { orders: Order[]; isLoading?: boolean }) {
	return <section className="mt-8"><div className="flex items-end justify-between"><div><p className="text-xs font-bold uppercase tracking-[0.16em] text-primary">Activity</p><h2 className="mt-1 text-lg font-semibold text-primary-dark">Recent orders</h2></div><Link to="/app/buyer/orders" className="text-sm font-bold text-primary">View all</Link></div><div className="mt-4 overflow-hidden rounded-2xl border border-border bg-card">{isLoading ? [1, 2, 3].map((item) => <div key={item} className="border-b border-border p-5"><Skeleton className="h-4 w-40" /><Skeleton className="mt-2 h-3 w-24" /></div>) : orders.length === 0 ? <div className="p-8 text-center"><Package className="mx-auto h-7 w-7 text-muted-foreground" /><p className="mt-3 text-sm text-muted-foreground">Your orders will appear here.</p></div> : orders.slice(0, 4).map((order) => <div key={order.uuid} className="flex items-center justify-between gap-4 border-b border-border p-4 last:border-0 sm:p-5"><div className="flex min-w-0 items-center gap-3"><div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary/10"><Package className="h-4 w-4 text-primary" /></div><div className="min-w-0"><p className="truncate font-semibold text-primary-dark">{order.item_summary || 'Marketplace order'}</p><p className="mt-1 text-xs capitalize text-muted-foreground">{formatStatus(order.status)} · {money(order.total_amount)}</p></div></div><Link to={`/app/buyer/orders/${order.uuid}`} className="inline-flex shrink-0 items-center gap-1 text-xs font-bold text-primary">View <ArrowRight className="h-3 w-3" /></Link></div>)}</div></section>
}
