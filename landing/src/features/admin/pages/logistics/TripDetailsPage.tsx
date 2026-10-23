import { useEffect, useState } from 'react'
import { ArrowLeft, MapPin, Pencil, Route, Truck } from 'lucide-react'
import { Link, useParams } from 'react-router-dom'

import { cancelAdminTrip, getAdminTrip } from '../../../../core/lib'
import type { Trip } from '../../../../core/lib/types/logisticts'
import { Card } from '../../../../shared/components/cards/Card'
import { StatCard } from '../../../../shared/components/cards'
import { AdminPageLayout } from '../../components'
import { Avatar, Button, ConfirmDialog } from '../../../../shared/components/ui'
import { TripStatusBadge } from './components/TripStatusBadge'
import { TripEditModal } from './components/TripEditModal'

function value(value?: string | number | null) {
	return value === null || value === undefined || value === '' ? 'Not recorded' : String(value)
}

function money(amount?: string | number) {
	return `KES ${Number(amount ?? 0).toLocaleString()}`
}

function dateLabel(date?: string | null) {
	if (!date) return 'Not recorded'
	const parsed = new Date(date)
	return Number.isNaN(parsed.getTime()) ? 'Not recorded' : parsed.toLocaleString()
}

function coordinatesLink(latitude?: string | number | null, longitude?: string | number | null) {
	if (latitude == null || longitude == null) return null
	const lat = Number(latitude)
	const lng = Number(longitude)
	if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null
	return { label: `${lat.toFixed(5)}, ${lng.toFixed(5)}`, url: `https://www.google.com/maps/search/?api=1&query=${lat},${lng}` }
}

function Detail({ label, children }: { label: string; children: React.ReactNode }) {
	return <div className="min-w-0"><dt className="text-xs text-muted-foreground">{label}</dt><dd className="mt-1 break-words text-sm font-medium text-foreground">{children}</dd></div>
}

export function TripDetailsPage() {
	const { uuid = '' } = useParams()
	const [trip, setTrip] = useState<Trip | null>(null)
	const [loading, setLoading] = useState(true)
	const [error, setError] = useState('')
	const [notice, setNotice] = useState('')
	const [editing, setEditing] = useState(false)
	const [confirmingCancel, setConfirmingCancel] = useState(false)
	const [saving, setSaving] = useState(false)
	const [reloadKey, setReloadKey] = useState(0)

	useEffect(() => {
		let active = true
		setLoading(true)
		setError('')
		getAdminTrip(uuid).then((result) => {
			if (active) setTrip(result)
		}).catch((requestError: unknown) => {
			if (active) setError(requestError instanceof Error ? requestError.message : 'Could not load trip details.')
		}).finally(() => {
			if (active) setLoading(false)
		})
		return () => { active = false }
	}, [uuid, reloadKey])

	const refresh = () => setReloadKey((current) => current + 1)
	const cancelTrip = async () => {
		if (!trip) return
		setSaving(true)
		setError('')
		try {
			await cancelAdminTrip(trip.uuid)
			setConfirmingCancel(false)
			setNotice('Trip cancelled.')
			refresh()
		} catch (requestError) {
			setError(requestError instanceof Error ? requestError.message : 'Could not cancel this trip.')
		} finally {
			setSaving(false)
		}
	}

	const pickup = trip ? coordinatesLink(trip.pickup_lat, trip.pickup_lng) : null
	const delivery = trip ? coordinatesLink(trip.delivery_lat, trip.delivery_lng) : null
	const current = trip ? coordinatesLink(trip.current_lat, trip.current_lng) : null
	const terminal = trip ? ['delivered', 'cancelled', 'failed'].includes(trip.status) : true

	return <AdminPageLayout section="logistics" title={trip ? `Trip #${trip.id}` : 'Trip details'} loading={loading} error={error} notice={notice} onRefresh={refresh}>
		{trip && <div className="space-y-5">
			<div className="flex flex-wrap items-center justify-between gap-3">
				<Link to="/app/admin/logistics" className="inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-primary"><ArrowLeft className="h-4 w-4" />All logistics trips</Link>
				<div className="flex flex-wrap items-center gap-2"><TripStatusBadge status={trip.status} /><Button type="button" variant="outline" size="sm" leftIcon={<Pencil className="h-4 w-4" />} onClick={() => setEditing(true)}>Edit notes</Button>{!terminal && <Button type="button" variant="danger" size="sm" disabled={saving} onClick={() => setConfirmingCancel(true)}>Cancel trip</Button>}</div>
			</div>
			<div className="grid grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-4">
				<StatCard title="Order" value={trip.order_id || `#${trip.order}`} subtitle="Linked marketplace order" variant="flat" />
				<StatCard title="Distance" value={`${Number(trip.road_km ?? trip.straight_line_km ?? 0).toFixed(1)} km`} subtitle="Recorded route distance" variant="flat" />
				<StatCard title="ETA" value={trip.eta_minutes == null ? 'Not set' : `${trip.eta_minutes} min`} subtitle="Current estimate" variant="flat" />
				<StatCard title="Buyer total" value={money(trip.buyer_total ?? trip.agreed_fee)} subtitle="Trip delivery charge" variant="flat" />
			</div>
			<div className="grid gap-4 lg:grid-cols-2">
				<Card padding="md">
					<h2 className="flex items-center gap-2 text-base font-semibold text-primary-dark"><Route className="h-4 w-4" />Route and locations</h2>
					<dl className="mt-4 grid gap-4 sm:grid-cols-2">
						<Detail label="Pickup address">{trip.pickup_address || 'Farm pickup'}</Detail>
						<Detail label="Pickup coordinates">{pickup ? <a href={pickup.url} target="_blank" rel="noreferrer" className="text-primary underline">{pickup.label}</a> : 'Not recorded'}</Detail>
						<Detail label="Delivery address">{trip.delivery_address || 'Buyer delivery'}</Detail>
						<Detail label="Delivery coordinates">{delivery ? <a href={delivery.url} target="_blank" rel="noreferrer" className="text-primary underline">{delivery.label}</a> : 'Not recorded'}</Detail>
						<Detail label="Last known location">{current ? <a href={current.url} target="_blank" rel="noreferrer" className="text-primary underline">{current.label}</a> : 'Not recorded'}</Detail>
						<Detail label="Provider">{trip.driver_name || trip.provider_detail?.phone || trip.driver_phone || (trip.provider ? `Provider ${trip.provider}` : 'Unassigned')}</Detail>
						<Detail label="Vehicle">{trip.vehicle_label || trip.vehicle_type || trip.vehicle_make || 'Not recorded'}</Detail>
						<Detail label="License plate">{trip.vehicle_plate || 'Not recorded'}</Detail>
					</dl>
				</Card>
				<Card padding="md">
					<h2 className="flex items-center gap-2 text-base font-semibold text-primary-dark"><Truck className="h-4 w-4" />Fees and trip notes</h2>
					<dl className="mt-4 grid gap-4 sm:grid-cols-2">
						<Detail label="Base fee">{money(trip.base_fee)}</Detail>
						<Detail label="Distance fee">{money(trip.distance_fee)}</Detail>
						<Detail label="Weight fee">{money(trip.weight_fee)}</Detail>
						<Detail label="Waiting fee">{money(trip.waiting_fee ?? trip.waiting_surcharge)}</Detail>
						<Detail label="Provider payout">{money(trip.provider_payout)}</Detail>
						<Detail label="Platform fee">{money(trip.platform_fee ?? trip.commission)}</Detail>
						<Detail label="Delivery notes">{trip.delivery_notes || 'None'}</Detail>
						<Detail label="Failure reason">{trip.failure_reason || 'None'}</Detail>
						<Detail label="Cancellation reason">{trip.cancel_reason || 'None'}</Detail>
					</dl>
				</Card>
			</div>
			<Card padding="md">
				<h2 className="flex items-center gap-2 text-base font-semibold text-primary-dark"><MapPin className="h-4 w-4" />Trip timeline</h2>
				{trip.status_history?.length ? <ol className="mt-4 divide-y divide-border">{trip.status_history.map((event, index) => <li key={`${event.status}-${event.changed_at}-${index}`} className="flex flex-wrap items-start justify-between gap-2 py-3"><div className="flex items-start gap-3"><span className="mt-1 h-2 w-2 rounded-full bg-primary" /><div><p className="text-sm font-semibold">{event.status.replaceAll('_', ' ')}</p><p className="text-xs text-muted-foreground">{event.actor_phone || event.source || 'System'}{event.note ? ` · ${event.note}` : ''}</p></div></div><time className="text-xs text-muted-foreground">{dateLabel(event.changed_at)}</time></li>)}</ol> : <p className="mt-3 text-sm text-muted-foreground">No status history recorded.</p>}
			</Card>
			{Boolean(trip.media?.length) && <Card padding="md"><h2 className="text-base font-semibold text-primary-dark">Trip media</h2><div className="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">{trip.media?.map((media) => <a key={media.id} href={media.image_url || undefined} target="_blank" rel="noreferrer" className="overflow-hidden rounded-lg border border-border bg-muted"><img src={media.image_url || ''} alt={media.caption || media.media_type} className="aspect-video w-full object-cover" /><div className="p-3"><p className="text-sm font-semibold">{media.caption || media.media_type}</p><p className="mt-1 text-xs text-muted-foreground">{media.uploaded_by_phone || 'Unknown uploader'} · {dateLabel(media.uploaded_at)}</p></div></a>)}</div></Card>}
			<TripEditModal trip={editing ? trip : null} onClose={() => setEditing(false)} onSaved={() => { setEditing(false); setNotice('Trip notes updated.'); refresh() }} />
			<ConfirmDialog isOpen={confirmingCancel} title="Cancel this trip?" message={<>This will mark trip #{trip.id} as cancelled. The action will be visible in the trip history.</>} confirmLabel="Cancel trip" variant="danger" loading={saving} onCancel={() => !saving && setConfirmingCancel(false)} onConfirm={() => void cancelTrip()} />
		</div>}
	</AdminPageLayout>
}
