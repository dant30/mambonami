import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { ArrowUpRight, Search } from 'lucide-react'

import { listAdminTrips, useAdminResource } from '../../../../core/lib'
import type { Trip, TripStatus } from '../../../../core/lib/types/logisticts'
import { StatCard } from '../../../../shared/components/cards'
import { DataTable } from '../../../../shared/components/tables/DataTable'
import { Button, Input, Select } from '../../../../shared/components/ui'
import { AdminPageLayout } from '../../components'
import { TripStatusBadge } from './components/TripStatusBadge'

const statusOptions: Array<{ value: string; label: string }> = [
	{ value: 'all', label: 'All trip statuses' },
	{ value: 'created', label: 'Created' },
	{ value: 'offered', label: 'Offered' },
	{ value: 'accepted', label: 'Accepted' },
	{ value: 'en_route_pickup', label: 'En route to pickup' },
	{ value: 'arrived_pickup', label: 'At pickup' },
	{ value: 'picked_up', label: 'Picked up' },
	{ value: 'en_route_delivery', label: 'En route to delivery' },
	{ value: 'arrived_delivery', label: 'At delivery' },
	{ value: 'otp_pending', label: 'Awaiting OTP' },
	{ value: 'delivered', label: 'Delivered' },
	{ value: 'cancelled', label: 'Cancelled' },
	{ value: 'failed', label: 'Failed' },
	{ value: 'disputed', label: 'Disputed' },
]

function providerName(trip: Trip) {
	return trip.driver_name || trip.provider_detail?.phone || trip.driver_phone || (trip.provider ? `Provider ${trip.provider}` : 'Unassigned')
}

function routeSummary(trip: Trip) {
	return `${trip.pickup_address || 'Farm pickup'} to ${trip.delivery_address || 'Buyer delivery'}`
}

function money(value: string | number | undefined) {
	return `KES ${Number(value ?? 0).toLocaleString()}`
}

function dateLabel(value?: string | null) {
	if (!value) return 'Not recorded'
	const date = new Date(value)
	return Number.isNaN(date.getTime()) ? 'Not recorded' : date.toLocaleString()
}

export function TripsAdminPage() {
	const { data, loading, error, refresh } = useAdminResource(listAdminTrips)
	const trips = data ?? []
	const [statusFilter, setStatusFilter] = useState('all')
	const [search, setSearch] = useState('')

	const filteredTrips = useMemo(() => {
		const normalizedSearch = search.trim().toLowerCase()
		return trips.filter((trip) => {
			if (statusFilter !== 'all' && trip.status !== statusFilter) return false
			if (!normalizedSearch) return true
			return [trip.order_id, trip.order, trip.uuid, providerName(trip), trip.driver_phone, trip.pickup_address, trip.delivery_address]
				.some((value) => String(value ?? '').toLowerCase().includes(normalizedSearch))
		})
	}, [trips, statusFilter, search])

	const activeCount = trips.filter((trip) => !['delivered', 'cancelled', 'failed'].includes(trip.status)).length
	const deliveredCount = trips.filter((trip) => trip.status === 'delivered').length
	const needsAttentionCount = trips.filter((trip) => ['failed', 'disputed'].includes(trip.status)).length

	const columns = [
		{ header: 'Trip / order', mobileRole: 'title' as const, render: (trip: Trip) => <div><p className="font-semibold">Trip #{trip.id}</p><p className="text-xs text-muted-foreground">{trip.order_id || `Order ${trip.order}`}</p></div> },
		{ header: 'Route', render: (trip: Trip) => <span className="line-clamp-2 max-w-sm">{routeSummary(trip)}</span> },
		{ header: 'Provider', render: providerName },
		{ header: 'Status', mobileRole: 'status' as const, render: (trip: Trip) => <TripStatusBadge status={trip.status as TripStatus} /> },
		{ header: 'Trip fee', mobileRole: 'summary' as const, render: (trip: Trip) => money(trip.buyer_total ?? trip.agreed_fee ?? trip.provider_payout) },
		{ header: 'Created', render: (trip: Trip) => dateLabel(trip.created_at_trip || trip.created_at) },
		{ header: 'Details', mobileRole: 'action' as const, render: (trip: Trip) => <Link to={`/app/admin/logistics/${trip.uuid}`} aria-label={`Open trip ${trip.id}`} title="Open trip details" className="inline-flex min-h-10 items-center gap-2 rounded-lg border border-border px-3 text-xs font-semibold text-primary hover:bg-muted">View trip <ArrowUpRight className="h-4 w-4" aria-hidden="true" /></Link> },
	]

	return <AdminPageLayout section="logistics" title="Logistics and trips" loading={loading} error={error instanceof Error ? error.message : error ? 'Could not load trips.' : ''} onRefresh={refresh}>
		<div className="grid grid-cols-2 gap-3 sm:grid-cols-3 sm:gap-4">
			<StatCard title="All trips" value={trips.length} subtitle="Recorded deliveries" variant="flat" />
			<StatCard title="In progress" value={activeCount} subtitle="Awaiting completion" variant="flat" />
			<StatCard title="Needs attention" value={needsAttentionCount} subtitle={`${deliveredCount} delivered`} variant="flat" />
		</div>
		<section aria-label="Trip filters" className="mt-5 flex flex-col gap-3 rounded-xl border border-border bg-card p-3 sm:flex-row sm:items-center sm:p-4">
			<Input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search trip, order, provider, or route" aria-label="Search trips" leftIcon={<Search className="h-4 w-4" />} />
			<Select value={statusFilter} onChange={setStatusFilter} options={statusOptions} aria-label="Filter trips by status" className="sm:w-64 sm:shrink-0" />
			{(search || statusFilter !== 'all') && <Button type="button" variant="ghost" onClick={() => { setSearch(''); setStatusFilter('all') }}>Clear filters</Button>}
		</section>
		<div className="mt-5">
			<DataTable data={filteredTrips} columns={columns} keyExtractor={(trip) => trip.uuid} emptyMessage={trips.length ? 'No trips match these filters.' : 'No logistics trips have been recorded yet.'} />
		</div>
	</AdminPageLayout>
}
