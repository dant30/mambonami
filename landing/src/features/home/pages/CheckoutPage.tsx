import { ArrowLeft, ArrowRight, CheckCircle2, Clipboard, Clock3, Copy, CreditCard, MapPin, ShieldCheck } from 'lucide-react'
import { Link, Navigate } from 'react-router-dom'
import { useEffect, useState } from 'react'

import { useAuth } from '../../../core/contexts/AuthContext'
import { buildCreateOrderInputFromCart, createOrder, getCart, getCartSummary, getOrder, initiateOrderStkPush } from '../../../core/lib'
import type { CreateOrderResponse, Order } from '../../../core/lib'
import { MapPicker, Select } from '../../../shared/components/ui'
import { getErrorMessage } from '../../../core/utils'
import type { Coordinates } from '../../../core/utils'

function formatMoney(value: string | number) { return `KSh ${Number(value).toLocaleString()}` }
function isPaid(status: Order['status'] | string | undefined) { return ['paid_escrow', 'transport_assigned', 'picked_up', 'delivered', 'disputed'].includes(String(status || '').toLowerCase()) }

export function CheckoutPage() {
	const { isAuthenticated, user } = useAuth()
	const items = getCart()
	const summary = getCartSummary(items)
	const [address, setAddress] = useState('')
	const [city, setCity] = useState('Nairobi')
	const [timeWindow, setTimeWindow] = useState('09:00-12:00')
	const [deliveryLocation, setDeliveryLocation] = useState<Coordinates | null>(null)
	const [payment, setPayment] = useState<CreateOrderResponse | null>(null)
	const [paymentOrder, setPaymentOrder] = useState<Order | null>(null)
	const [isSubmitting, setIsSubmitting] = useState(false)
	const [isSendingPrompt, setIsSendingPrompt] = useState(false)
	const [isChecking, setIsChecking] = useState(false)
	const [error, setError] = useState('')
	const [notice, setNotice] = useState('')

	const copy = async (value: string) => { try { await navigator.clipboard.writeText(value); setNotice('Copied to clipboard.') } catch { setNotice('Select and copy the payment reference manually.') } }
	const syncPaymentStatus = async (orderUuid: string) => {
		try {
			const latest = await getOrder(orderUuid)
			setPaymentOrder(latest)
			return latest
		} catch {
			return null
		}
	}
	const submit = async (event: React.FormEvent) => {
		event.preventDefault(); setError('')
		if (!deliveryLocation) { setError('Choose your delivery point on the map before placing the order.'); return }
		setIsSubmitting(true)
		try {
			const result = await createOrder(buildCreateOrderInputFromCart(items, { delivery_address: address, delivery_city: city, scheduled_time_window: timeWindow, delivery_lat: deliveryLocation.latitude, delivery_lng: deliveryLocation.longitude, payment_method: 'mpesa_paybill' }))
			setPayment(result)
			setPaymentOrder({ id: result.id, uuid: result.uuid, buyer: 0, total_amount: result.total_amount, delivery_fee: result.delivery_fee, platform_commission: result.platform_commission, discount_amount: result.discount_amount, status: 'placed', sub_orders: [], scheduled_date: new Date().toISOString().slice(0, 10), scheduled_time_window: timeWindow, created_at: new Date().toISOString() })
			if (user?.phone) {
				setNotice('Sending an M-Pesa prompt to your account phone...')
				setIsSendingPrompt(true)
				void initiateOrderStkPush(result.uuid, user.phone)
					.then((stkResult) => {
						setPaymentOrder((current) => current ? { ...current, stk_payment_status: 'pending', stk_payment_message: stkResult.message } : current)
						setNotice(`${stkResult.message} Check your phone and enter your M-Pesa PIN. You can use the PayBill fallback below instead.`)
						void syncPaymentStatus(result.uuid)
					})
					.catch(async (stkError: unknown) => {
						const latest = await syncPaymentStatus(result.uuid)
						const message = latest?.stk_payment_message || getErrorMessage(stkError, 'The M-Pesa prompt could not be sent.')
						setNotice(`${message} ${latest?.stk_payment_status === 'pending' || latest?.stk_payment_status === 'initiating' ? 'Check your phone before requesting another prompt.' : 'Use the PayBill fallback below or try again.'}`)
					})
					.finally(() => setIsSendingPrompt(false))
			} else {
				setNotice('Your order is ready. Use the PayBill fallback below to pay.')
			}
		} catch { setError('We could not create your order. Your cart is still available so you can retry.') } finally { setIsSubmitting(false) }
	}
	const checkPayment = async () => {
		if (!payment) return
		setIsChecking(true); setError(''); setNotice('Checking M-Pesa payment status...')
		try {
			const latest = await getOrder(payment.uuid)
			setPaymentOrder(latest)
			setNotice(
				isPaid(latest.status)
					? 'Payment confirmed and held in escrow.'
					: latest.stk_payment_status === 'failed'
						? latest.stk_payment_message || 'The M-Pesa request was not completed. Send a new prompt or use PayBill.'
						: 'Payment is not confirmed yet. Complete the PayBill payment, then check again.',
			)
		} catch {
			setError('We could not check payment status. Please try again.')
		} finally {
			setIsChecking(false)
		}
	}
	const resendPrompt = async (phone: string) => {
		if (!payment) return
		setError('')
		setNotice('Sending a new M-Pesa prompt...')
		setIsSendingPrompt(true)
		try {
			const result = await initiateOrderStkPush(payment.uuid, phone)
			setPaymentOrder((current) => current ? { ...current, stk_payment_status: 'pending', stk_payment_message: result.message } : current)
			setNotice(`${result.message} Check your phone and enter your M-Pesa PIN.`)
			void syncPaymentStatus(payment.uuid)
		} catch (requestError) {
			const latest = await syncPaymentStatus(payment.uuid)
			setError(latest?.stk_payment_message || getErrorMessage(requestError, 'Could not send a new M-Pesa prompt. Use the PayBill details below.'))
		} finally {
			setIsSendingPrompt(false)
		}
	}
	useEffect(() => {
		if (!payment || isPaid(paymentOrder?.status)) return
		let active = true
		const refreshStatus = async () => {
			try {
				const latest = await getOrder(payment.uuid)
				if (!active) return
				setPaymentOrder(latest)
				if (isPaid(latest.status)) {
					setNotice('Payment confirmed and held in escrow.')
				} else if (latest.stk_payment_status === 'failed') {
					setNotice(latest.stk_payment_message || 'The M-Pesa request was not completed. You can send a new prompt or pay with PayBill.')
				}
			} catch {
				// Keep payment instructions available if a status check temporarily fails.
			}
		}
		void refreshStatus()
		const interval = window.setInterval(() => void refreshStatus(), 5000)
		const timeout = window.setTimeout(() => window.clearInterval(interval), 120000)
		return () => {
			active = false
			window.clearInterval(interval)
			window.clearTimeout(timeout)
		}
	}, [payment?.uuid, paymentOrder?.status, paymentOrder?.stk_payment_status])

	if (!isAuthenticated) return <Navigate to="/login" replace state={{ returnTo: '/checkout' }} />
	if (items.length === 0 && !payment) return <Navigate to="/app/buyer/cart" replace />
	const promptBlocksRetry = ['initiating', 'pending', 'succeeded'].includes(paymentOrder?.stk_payment_status || '')
	if (payment) return <><PaymentStep payment={payment} paymentOrder={paymentOrder} isChecking={isChecking} error={error} notice={notice} onCopy={copy} onCheck={() => void checkPayment()} />{!isPaid(paymentOrder?.status) && !promptBlocksRetry && !isSendingPrompt && <PaymentRetryForm initialPhone={user?.phone || ''} sending={isSendingPrompt} onResend={resendPrompt} />}</>
	return <main className="min-h-full bg-background"><div className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8"><div className="border-b border-border pb-6"><p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Secure checkout</p><h1 className="mt-2 text-3xl font-semibold text-primary-dark sm:text-4xl">Choose where your harvest should arrive.</h1><p className="mt-3 text-sm text-muted-foreground">Add delivery details, then pay securely through M-Pesa PayBill.</p></div><div className="mt-8 grid gap-8 lg:grid-cols-[1fr_22rem]"><form onSubmit={submit} className="rounded-2xl border border-border bg-card p-6 shadow-sm sm:p-8"><div className="flex items-center gap-3"><MapPin className="h-5 w-5 text-primary" /><h2 className="text-xl font-semibold text-primary-dark">Delivery details</h2></div>{error && <p role="alert" className="mt-5 rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}<MapPicker value={deliveryLocation} onChange={setDeliveryLocation} className="mt-7" /><label className="mt-6 block text-sm font-semibold text-primary-dark">Street address<input required value={address} onChange={(event) => setAddress(event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 font-normal outline-none focus:ring-2 focus:ring-primary" placeholder="House, street, or landmark" /></label><label className="mt-5 block text-sm font-semibold text-primary-dark">City<input required value={city} onChange={(event) => setCity(event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 font-normal outline-none focus:ring-2 focus:ring-primary" /></label><label className="mt-5 block text-sm font-semibold text-primary-dark">Delivery time window<Select aria-label="Delivery time window" value={timeWindow} onChange={setTimeWindow} className="mt-2" options={[{ value: '09:00-12:00', label: '09:00-12:00' }, { value: '12:00-15:00', label: '12:00-15:00' }, { value: '15:00-18:00', label: '15:00-18:00' }]} /></label><p className="mt-6 flex items-start gap-2 rounded-xl bg-muted p-4 text-sm leading-6 text-muted-foreground"><ShieldCheck className="mt-1 h-4 w-4 shrink-0 text-primary" />Your payment is held in escrow until delivery is confirmed.</p><button disabled={isSubmitting} className="mt-7 w-full rounded-full bg-primary px-5 py-3.5 text-sm font-bold text-primary-foreground disabled:opacity-60">{isSubmitting ? 'Creating order...' : 'Continue to payment'}</button><Link to="/app/buyer/cart" className="mt-4 inline-flex items-center gap-2 text-sm font-semibold text-primary"><ArrowLeft className="h-4 w-4" />Back to cart</Link></form><aside className="h-fit rounded-2xl border border-border bg-primary-dark p-6 text-primary-foreground lg:sticky lg:top-24"><p className="text-xs font-bold uppercase tracking-[0.18em] text-secondary">Order summary</p><div className="mt-6 space-y-3 text-sm"><div className="flex justify-between text-primary-foreground/75"><span>{summary.totalQuantity} items</span><span>{formatMoney(summary.subtotal)}</span></div><div className="flex justify-between text-primary-foreground/75"><span>Delivery</span><span>Calculated</span></div><div className="flex justify-between border-t border-primary-foreground/20 pt-4 text-lg font-bold"><span>Total</span><span>{formatMoney(summary.total)}</span></div></div><p className="mt-6 flex items-start gap-2 text-xs leading-5 text-primary-foreground/60"><Clipboard className="mt-0.5 h-4 w-4 shrink-0" />After placing the order, you will receive a unique PayBill account number.</p></aside></div></div></main>
}

function PaymentStep({ payment, paymentOrder, isChecking, error, notice, onCopy, onCheck }: { payment: CreateOrderResponse; paymentOrder: Order | null; isChecking: boolean; error: string; notice: string; onCopy: (value: string) => void; onCheck: () => void }) {
	const paid = isPaid(paymentOrder?.status)
	return <main className="min-h-full bg-background"><div className="mx-auto max-w-3xl px-4 py-8 sm:px-6 lg:px-8"><div className="text-center"><div className={`mx-auto flex h-14 w-14 items-center justify-center rounded-2xl ${paid ? 'bg-primary/10 text-primary' : 'bg-secondary/20 text-primary-dark'}`}>{paid ? <CheckCircle2 className="h-8 w-8" /> : <Clock3 className="h-8 w-8" />}</div><p className="mt-5 text-xs font-bold uppercase tracking-[0.18em] text-primary">Order #{payment.account_number}</p><h1 className="mt-2 text-3xl font-semibold text-primary-dark">{paid ? 'Payment confirmed' : 'Complete your payment'}</h1><p className="mx-auto mt-3 max-w-xl text-sm leading-6 text-muted-foreground">{paid ? 'Your payment is held securely in escrow while the farmers prepare your order.' : 'Use M-Pesa PayBill to secure this order. Fulfilment starts after callback confirmation.'}</p></div><section className="mt-8 rounded-2xl border border-border bg-card p-6 shadow-sm sm:p-8"><div className="flex items-center justify-between"><div><p className="text-xs font-bold uppercase tracking-[0.16em] text-primary">M-Pesa PayBill</p><h2 className="mt-1 text-xl font-semibold text-primary-dark">Payment instructions</h2></div><ShieldCheck className="h-6 w-6 text-primary" /></div><div className="mt-6 space-y-3">{[['PayBill number', payment.paybill_number], ['Account number', payment.account_number]].map(([label, value]) => <div key={label} className="flex items-center justify-between gap-4 rounded-xl bg-muted px-4 py-3"><span className="text-sm text-muted-foreground">{label}</span><strong className="text-primary-dark">{value}</strong><button type="button" onClick={() => onCopy(value)} aria-label={`Copy ${label}`} className="rounded-full p-2 text-primary hover:bg-background"><Copy className="h-4 w-4" /></button></div>)}<div className="flex items-center justify-between rounded-xl border border-primary/20 bg-primary/5 px-4 py-3"><span className="text-sm font-semibold text-primary-dark">Amount to pay</span><strong className="text-lg text-primary">{formatMoney(payment.total_amount)}</strong></div></div><p className="mt-5 text-sm leading-6 text-muted-foreground">{payment.instructions}</p>{notice && <p role="status" className="mt-4 text-sm text-primary">{notice}</p>}{error && <p role="alert" className="mt-4 text-sm text-destructive">{error}</p>}<div className="mt-6 flex flex-col gap-3 sm:flex-row"><button type="button" onClick={onCheck} disabled={isChecking || paid} className="inline-flex flex-1 items-center justify-center gap-2 rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground disabled:opacity-60">{isChecking ? 'Checking...' : paid ? 'Payment confirmed' : 'Check payment status'}<CheckCircle2 className="h-4 w-4" /></button><Link to={`/app/buyer/orders/${payment.uuid}`} className="inline-flex items-center justify-center gap-2 rounded-full border border-border px-5 py-3 text-sm font-bold text-primary">View order <ArrowRight className="h-4 w-4" /></Link></div></section></div></main>
}

function PaymentRetryForm({ initialPhone, sending, onResend }: { initialPhone: string; sending: boolean; onResend: (phone: string) => void }) {
	const [phone, setPhone] = useState(initialPhone)
	return (
		<div className="bg-background px-4 pb-8 sm:px-6">
			<section className="mx-auto max-w-3xl rounded-2xl border border-border bg-card p-5 shadow-sm sm:p-6">
				<h2 className="font-semibold text-primary-dark">Try the M-Pesa prompt again</h2>
				<p className="mt-1 text-sm text-muted-foreground">Use the number registered with M-Pesa. If you already approved a prompt, wait for payment confirmation before retrying.</p>
				<form onSubmit={(event) => { event.preventDefault(); onResend(phone) }} className="mt-4 flex flex-col gap-3 sm:flex-row">
					<label className="sr-only" htmlFor="checkout-payment-phone">M-Pesa phone number</label>
					<input id="checkout-payment-phone" type="tel" inputMode="tel" autoComplete="tel" required value={phone} onChange={(event) => setPhone(event.target.value)} placeholder="0712345678" className="min-w-0 flex-1 rounded-xl border border-border bg-background px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary" />
					<button type="submit" disabled={sending || !phone.trim()} className="inline-flex items-center justify-center gap-2 rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground disabled:opacity-50">
						<CreditCard className="h-4 w-4" />{sending ? 'Sending prompt...' : 'Resend M-Pesa prompt'}
					</button>
				</form>
			</section>
		</div>
	)
}
