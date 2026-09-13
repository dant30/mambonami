import { ArrowLeft, CheckCircle2, Clock3, MapPin, PackageCheck } from 'lucide-react'
import { Link, useParams } from 'react-router-dom'

import { useOrder } from '../../../core/lib'

const steps = ['placed', 'paid_escrow', 'transport_assigned', 'picked_up', 'delivered']

function formatStatus(status: string | null | undefined) {
	return String(status || 'processing').replaceAll('_', ' ')
}

export function BuyerOrderDetailPage() {
	const { id = '' } = useParams()
	const { order, isLoading, error } = useOrder(id)
	if (isLoading) return <main className="mx-auto max-w-4xl px-4 py-16 sm:px-6 lg:px-8"><div className="h-80 animate-pulse rounded-2xl bg-muted" /></main>
	if (error || !order) return <main className="mx-auto max-w-2xl px-4 py-20 text-center"><h1 className="text-3xl font-semibold text-primary-dark">Order unavailable</h1><Link to="/app/buyer/orders" className="mt-6 inline-flex rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground">Back to orders</Link></main>
	const status = String(order.status || 'placed')
	const currentStep = Math.max(0, steps.indexOf(status))

	return <main className="mx-auto max-w-4xl px-4 py-8 sm:px-6 lg:px-8"><Link to="/app/buyer/orders" className="inline-flex items-center gap-2 text-sm font-bold text-primary"><ArrowLeft className="h-4 w-4" />Back to orders</Link><div className="mt-8 flex flex-col gap-5 sm:flex-row sm:items-end sm:justify-between"><div><p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Order #{order.account_number || order.uuid.slice(0, 8)}</p><h1 className="mt-2 text-3xl font-semibold capitalize text-primary-dark">Your order is {formatStatus(status)}</h1></div><p className="text-2xl font-bold text-primary-dark">KSh {Number(order.total_amount).toLocaleString()}</p></div><section className="mt-8 rounded-2xl border border-border bg-card p-6 sm:p-8"><div className="space-y-6">{steps.map((step, index) => { const complete = index <= currentStep; return <div key={step} className="flex gap-4"><span className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-full ${complete ? 'bg-primary text-primary-foreground' : 'bg-muted text-muted-foreground'}`}>{complete ? <CheckCircle2 className="h-4 w-4" /> : <Clock3 className="h-4 w-4" />}</span><div><p className={`font-semibold capitalize ${complete ? 'text-primary-dark' : 'text-muted-foreground'}`}>{formatStatus(step)}</p><p className="mt-1 text-sm text-muted-foreground">{complete ? 'This step has been recorded.' : 'We will update you as the order progresses.'}</p></div></div> })}</div></section><section className="mt-6 grid gap-6 sm:grid-cols-2"><div className="rounded-2xl border border-border bg-card p-6"><MapPin className="h-5 w-5 text-primary" /><h2 className="mt-4 font-semibold text-primary-dark">Delivery destination</h2><p className="mt-2 text-sm leading-6 text-muted-foreground">{order.delivery_address || order.delivery_city || 'Delivery details pending'}</p></div><div className="rounded-2xl border border-border bg-card p-6"><PackageCheck className="h-5 w-5 text-primary" /><h2 className="mt-4 font-semibold text-primary-dark">Items</h2><p className="mt-2 text-sm leading-6 text-muted-foreground">{order.item_summary || `${order.sub_orders?.length ?? 0} product groups`}</p></div></section></main>
}
