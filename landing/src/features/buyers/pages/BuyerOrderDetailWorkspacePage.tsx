import { ArrowLeft, CheckCircle2, Clock3, Copy, CreditCard, MapPin, PackageCheck, RefreshCw } from 'lucide-react'
import { Link, useParams } from 'react-router-dom'
import { useEffect, useState } from 'react'

import { initiateOrderStkPush, useOrder } from '../../../core/lib'
import type { Order } from '../../../core/lib'
import { getErrorMessage } from '../../../core/utils'
import { BuyerDeliveryConfirmation } from '../components/BuyerDeliveryConfirmation'

const steps = ['placed', 'paid_escrow', 'transport_assigned', 'picked_up', 'delivered']

function formatStatus(status: string | null | undefined) {
	return String(status || 'processing').replaceAll('_', ' ')
}

export function BuyerOrderDetailPage() {
	const { id = '' } = useParams()
	const { order, isLoading, error, refresh } = useOrder(id)
	useEffect(() => {
		if (order?.status !== 'placed' || !['initiating', 'pending', 'succeeded'].includes(order.stk_payment_status || '')) return
		const interval = window.setInterval(refresh, 5000)
		return () => window.clearInterval(interval)
	}, [order?.status, order?.stk_payment_status, refresh])

	if (isLoading && !order) return <main className="mx-auto max-w-4xl px-4 py-16 sm:px-6 lg:px-8"><div className="h-80 animate-pulse rounded-2xl bg-muted" /></main>
	if (error || !order) return <main className="mx-auto max-w-2xl px-4 py-20 text-center"><h1 className="text-3xl font-semibold text-primary-dark">Order unavailable</h1><Link to="/app/buyer/orders" className="mt-6 inline-flex rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground">Back to orders</Link></main>

	const status = String(order.status || 'placed')
	const currentStep = Math.max(0, steps.indexOf(status))

	return (
		<main className="mx-auto max-w-4xl px-4 py-8 sm:px-6 lg:px-8">
			<Link to="/app/buyer/orders" className="inline-flex items-center gap-2 text-sm font-bold text-primary"><ArrowLeft className="h-4 w-4" />Back to orders</Link>
			<div className="mt-8 flex flex-col gap-5 sm:flex-row sm:items-end sm:justify-between">
				<div><p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Order #{order.account_number || order.uuid.slice(0, 8)}</p><h1 className="mt-2 text-3xl font-semibold capitalize text-primary-dark">Your order is {formatStatus(status)}</h1></div>
				<p className="text-2xl font-bold text-primary-dark">KSh {Number(order.total_amount).toLocaleString()}</p>
			</div>

			{status === 'placed' && <OrderPaymentPanel order={order} onRefresh={refresh} refreshing={isLoading} />}
			{status === 'picked_up' && <BuyerDeliveryConfirmation orderUuid={order.uuid} onConfirmed={refresh} />}

			<section className="mt-8 rounded-2xl border border-border bg-card p-6 sm:p-8">
				<div className="space-y-6">{steps.map((step, index) => { const complete = index <= currentStep; return <div key={step} className="flex gap-4"><span className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-full ${complete ? 'bg-primary text-primary-foreground' : 'bg-muted text-muted-foreground'}`}>{complete ? <CheckCircle2 className="h-4 w-4" /> : <Clock3 className="h-4 w-4" />}</span><div><p className={`font-semibold capitalize ${complete ? 'text-primary-dark' : 'text-muted-foreground'}`}>{formatStatus(step)}</p><p className="mt-1 text-sm text-muted-foreground">{complete ? 'This step has been recorded.' : 'We will update you as the order progresses.'}</p></div></div> })}</div>
			</section>

			<section className="mt-6 grid gap-6 sm:grid-cols-2">
				<div className="rounded-2xl border border-border bg-card p-6"><MapPin className="h-5 w-5 text-primary" /><h2 className="mt-4 font-semibold text-primary-dark">Delivery destination</h2><p className="mt-2 text-sm leading-6 text-muted-foreground">{order.delivery_address || order.delivery_city || 'Delivery details pending'}</p></div>
				<div className="rounded-2xl border border-border bg-card p-6"><PackageCheck className="h-5 w-5 text-primary" /><h2 className="mt-4 font-semibold text-primary-dark">Items</h2><div className="mt-3 space-y-2">{order.sub_orders.flatMap((subOrder) => subOrder.items).map((item) => <p key={item.id} className="flex justify-between gap-3 text-sm"><span className="text-muted-foreground">{item.product_detail?.name || 'Produce'} {item.quantity}{item.product_detail?.unit || ''}</span><span className="shrink-0 font-semibold text-primary-dark">KSh {Number(item.total_price).toLocaleString()}</span></p>)}</div></div>
			</section>
		</main>
	)
}

function OrderPaymentPanel({ order, onRefresh, refreshing }: { order: Order; onRefresh: () => void; refreshing: boolean }) {
	const [phone, setPhone] = useState(order.buyer_phone || '')
	const [isSending, setIsSending] = useState(false)
	const [message, setMessage] = useState('')
	const [error, setError] = useState('')
	const latestStatus = order.stk_payment_status
	const promptPending = ['initiating', 'pending', 'succeeded'].includes(latestStatus || '')

	const sendPrompt = async () => {
		if (promptPending) {
			setMessage('An M-Pesa prompt is already pending. Check your phone or refresh the payment status.')
			return
		}
		setError('')
		setMessage('')
		setIsSending(true)
		try {
			const result = await initiateOrderStkPush(order.uuid, phone)
			setMessage(`${result.message} Check your phone and enter your M-Pesa PIN.`)
			onRefresh()
		} catch (requestError) {
			setError(getErrorMessage(requestError, 'Could not send the M-Pesa prompt. Use the PayBill fallback below.'))
			onRefresh()
		} finally { setIsSending(false) }
	}

	const copyAccount = async () => {
		try {
			await navigator.clipboard.writeText(order.account_number || '')
			setMessage('PayBill account number copied.')
		} catch {
			setMessage('Copy the account number shown below into M-Pesa.')
		}
	}

	return (
		<section className="mt-6 rounded-2xl border border-primary/20 bg-card p-5 sm:p-6">
			<div className="flex items-start gap-3"><CreditCard className="mt-0.5 h-5 w-5 shrink-0 text-primary" /><div><h2 className="font-semibold text-primary-dark">Complete payment</h2><p className="mt-1 text-sm text-muted-foreground">Send an M-Pesa prompt or pay manually with PayBill.</p></div></div>
			<div className="mt-5 grid gap-4 sm:grid-cols-[minmax(0,1fr)_auto] sm:items-end">
				<label className="block text-sm font-semibold text-primary-dark">M-Pesa phone number<input type="tel" inputMode="tel" autoComplete="tel" value={phone} onChange={(event) => setPhone(event.target.value)} placeholder="0712345678" className="mt-2 w-full min-w-0 rounded-xl border border-border bg-background px-4 py-3 font-normal outline-none focus:ring-2 focus:ring-primary" /></label>
				<button type="button" onClick={() => void sendPrompt()} disabled={isSending || promptPending || !phone.trim()} className="inline-flex items-center justify-center gap-2 rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground disabled:opacity-50"><CreditCard className="h-4 w-4" />{isSending ? 'Sending prompt...' : latestStatus === 'succeeded' ? 'Confirming payment...' : promptPending ? 'Prompt already pending' : 'Send M-Pesa prompt'}</button>
			</div>
			{latestStatus && <p className="mt-4 text-sm text-muted-foreground">Latest prompt: <span className="font-semibold capitalize text-primary-dark">{formatStatus(latestStatus)}</span>{order.stk_payment_message ? ` · ${order.stk_payment_message}` : ''}</p>}
			{message && <p role="status" className="mt-4 text-sm text-primary">{message}</p>}
			{error && <p role="alert" className="mt-4 text-sm text-destructive">{error}</p>}
			<div className="mt-5 border-t border-border pt-4">
				<div className="flex flex-wrap items-center justify-between gap-3"><h3 className="text-sm font-semibold text-primary-dark">PayBill fallback</h3><button type="button" onClick={onRefresh} disabled={refreshing} className="inline-flex items-center gap-2 text-sm font-semibold text-primary disabled:opacity-50"><RefreshCw className={`h-4 w-4 ${refreshing ? 'animate-spin' : ''}`} />Refresh payment status</button></div>
				<div className="mt-3 grid gap-3 sm:grid-cols-3">
					<PaymentValue label="PayBill number" value={order.paybill_number || 'Unavailable'} />
					<PaymentValue label="Account number" value={order.account_number || 'Unavailable'} copy={copyAccount} />
					<PaymentValue label="Amount" value={`KSh ${Number(order.total_amount).toLocaleString()}`} />
				</div>
				<p className="mt-3 text-xs leading-5 text-muted-foreground">In M-Pesa, choose Lipa na M-Pesa → PayBill, enter the business number and account number above, then pay the exact amount.</p>
			</div>
		</section>
	)
}

function PaymentValue({ label, value, copy }: { label: string; value: string; copy?: () => void }) {
	return <div className="flex min-w-0 items-center justify-between gap-2 rounded-xl bg-muted px-3 py-3"><div className="min-w-0"><p className="text-xs text-muted-foreground">{label}</p><p className="break-words font-semibold text-primary-dark">{value}</p></div>{copy && <button type="button" onClick={() => void copy()} aria-label="Copy PayBill account number" className="shrink-0 rounded-lg p-2 text-primary hover:bg-background"><Copy className="h-4 w-4" /></button>}</div>
}
