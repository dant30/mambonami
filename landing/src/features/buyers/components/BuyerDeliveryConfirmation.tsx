import { useState } from 'react'
import { CheckCircle2, ShieldCheck } from 'lucide-react'

import { useBuyerTrip, verifyTripOtp } from '../../../core/lib'
import { getErrorMessage } from '../../../core/utils'
import { InputOTP, InputOTPGroup, InputOTPSlot } from '../../../shared/components/ui/Input-otp'
import { EmptyState } from '../../../shared/components/feedback/EmptyState'

export function BuyerDeliveryConfirmation({ orderUuid, onConfirmed }: { orderUuid: string; onConfirmed: () => void }) {
	const { trip, isLoading, error: tripError, refresh: refreshTrip } = useBuyerTrip(orderUuid)
	const [otp, setOtp] = useState('')
	const [photo, setPhoto] = useState<File | null>(null)
	const [submitting, setSubmitting] = useState(false)
	const [message, setMessage] = useState('')
	const [error, setError] = useState('')

	const confirmDelivery = async () => {
		if (!trip || !/^\d{6}$/.test(otp)) {
			setError('Enter the six-digit code sent to your phone.')
			return
		}
		if (!photo) {
			setError('Add a delivery photo to confirm receipt.')
			return
		}
		setSubmitting(true)
		setError('')
		setMessage('')
		try {
			await verifyTripOtp(trip.uuid, { otp, delivery_photo: photo })
			setMessage('Delivery confirmed. The order status is updated and settlement has been queued.')
			setOtp('')
			setPhoto(null)
			refreshTrip()
			onConfirmed()
		} catch (requestError) {
			setError(getErrorMessage(requestError, 'We could not confirm delivery. Check the code and try again.'))
		} finally {
			setSubmitting(false)
		}
	}

	const tripErrorMessage = (() => {
		if (tripError instanceof Error) return tripError.message
		if (typeof tripError === 'string') return tripError
		return 'Refresh this order in a moment to load the delivery confirmation.'
	})()
	const hasTripError = !isLoading && tripError !== null && tripError !== undefined

	return <section className="mt-6 border-y border-border py-5" aria-labelledby="delivery-confirmation-title">
		<div className="flex items-start gap-3"><ShieldCheck className="mt-0.5 h-5 w-5 shrink-0 text-primary" /><div><h2 id="delivery-confirmation-title" className="font-semibold text-primary-dark">Confirm delivery</h2><p className="mt-1 text-sm text-muted-foreground">The transporter sends a one-time code to your registered phone after arriving.</p></div></div>
		{isLoading && <p className="mt-4 text-sm text-muted-foreground">Checking the delivery trip…</p>}
		{hasTripError && <EmptyState size="sm" title="Delivery trip unavailable" description={tripErrorMessage} />}
		{!isLoading && trip && trip.status !== 'otp_pending' && trip.status !== 'delivered' && <p className="mt-4 text-sm text-muted-foreground">Delivery code becomes available when the transporter marks arrival. Current trip status: <span className="font-semibold capitalize">{trip.status.replaceAll('_', ' ')}</span>.</p>}
		{trip?.status === 'otp_pending' && <div className="mt-5 grid gap-4 sm:grid-cols-2">
			<div><label className="mb-2 block text-xs font-bold uppercase text-muted-foreground">Six-digit SMS code</label><InputOTP maxLength={6} value={otp} onChange={setOtp} inputMode="numeric" aria-label="Six digit delivery code"><InputOTPGroup>{[0, 1, 2, 3, 4, 5].map((index) => <InputOTPSlot key={index} index={index} className="h-11 w-11 text-base" />)}</InputOTPGroup></InputOTP></div>
			<label className="block text-xs font-bold uppercase text-muted-foreground">Delivery photo<input type="file" accept="image/jpeg,image/png,image/webp" capture="environment" onChange={(event) => setPhoto(event.target.files?.[0] ?? null)} className="mt-2 block w-full text-sm font-normal text-foreground file:mr-3 file:min-h-10 file:rounded-md file:border-0 file:bg-muted file:px-3 file:font-semibold" />{photo && <span className="mt-1 block truncate text-xs font-medium text-primary">{photo.name}</span>}</label>
			<button type="button" onClick={() => void confirmDelivery()} disabled={submitting} className="inline-flex min-h-11 items-center justify-center gap-2 rounded-md bg-primary px-4 text-sm font-semibold text-primary-foreground hover:brightness-95 disabled:opacity-50 sm:col-span-2">{submitting ? 'Confirming…' : <><CheckCircle2 className="h-4 w-4" />Confirm receipt</>}</button>
		</div>}
		{trip?.status === 'delivered' && <p className="mt-4 text-sm font-semibold text-emerald-700">Delivery has already been confirmed.</p>}
		{message && <p role="status" className="mt-3 text-sm text-emerald-700">{message}</p>}
		{error && <p role="alert" className="mt-3 text-sm text-destructive">{error}</p>}
	</section>
}