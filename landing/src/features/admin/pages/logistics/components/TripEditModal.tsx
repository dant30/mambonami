import { useEffect, useState, type FormEvent } from 'react'

import { updateAdminTrip } from '../../../../../core/lib'
import type { Trip } from '../../../../../core/lib/types/logisticts'
import { Button, Modal, Textarea } from '../../../../../shared/components/ui'

export function TripEditModal({ trip, onClose, onSaved }: { trip: Trip | null; onClose: () => void; onSaved: () => void }) {
	const [saving, setSaving] = useState(false)
	const [error, setError] = useState('')
	const [deliveryNotes, setDeliveryNotes] = useState('')
	const [failureReason, setFailureReason] = useState('')
	const [cancelReason, setCancelReason] = useState('')

	useEffect(() => {
		setDeliveryNotes(trip?.delivery_notes || '')
		setFailureReason(trip?.failure_reason || '')
		setCancelReason(trip?.cancel_reason || '')
	}, [trip?.uuid, trip?.delivery_notes, trip?.failure_reason, trip?.cancel_reason])

	const submit = async (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		if (!trip) return
		setSaving(true)
		setError('')
		try {
			await updateAdminTrip(trip.uuid, { delivery_notes: deliveryNotes, failure_reason: failureReason, cancel_reason: cancelReason })
			onSaved()
		} catch (requestError) {
			setError(requestError instanceof Error ? requestError.message : 'Could not update trip notes.')
		} finally {
			setSaving(false)
		}
	}

	return <Modal isOpen={Boolean(trip)} onClose={() => saving ? undefined : onClose()} title="Edit trip notes" subtitle={trip?.order_id || `Trip ${trip?.id}`} maxWidth="lg">
		{trip && <form onSubmit={(event) => void submit(event)} className="space-y-4">
			<p className="text-sm text-muted-foreground">This form updates administrative notes only. Trip status changes should follow the trip workflow.</p>
			<label className="block text-sm font-semibold">Delivery notes<Textarea rows={3} value={deliveryNotes} onChange={(event) => setDeliveryNotes(event.target.value)} className="mt-1" /></label>
			<label className="block text-sm font-semibold">Failure reason<Textarea rows={2} value={failureReason} onChange={(event) => setFailureReason(event.target.value)} className="mt-1" /></label>
			<label className="block text-sm font-semibold">Cancellation reason<Textarea rows={2} value={cancelReason} onChange={(event) => setCancelReason(event.target.value)} className="mt-1" /></label>
			{error && <p role="alert" className="text-sm text-destructive">{error}</p>}
			<div className="flex justify-end gap-2 border-t border-border pt-4"><Button type="button" variant="outline" disabled={saving} onClick={onClose}>Cancel</Button><Button type="submit" isLoading={saving}>Save notes</Button></div>
		</form>}
	</Modal>
}