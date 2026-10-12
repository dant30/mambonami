import { ClipboardList, Clock3, DollarSign, MapPin, Navigation, Plus, Route, Settings2, Truck, Wallet } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useMemo, useState } from 'react'

import { useAuth } from '../../../core/contexts/AuthContext'
import { updateTransportProfile, useAvailableOrders, useMyTrips, useTransporterEarnings } from '../../../core/lib'
import type { TransportProfile } from '../../../core/lib'
import { getTimeGreeting } from '../../../core/utils'
import { StatCard } from '../../../shared/components/cards'
import { Skeleton } from '../../../shared/components/ui'

export function TransporterDashboardPage() {
	const { user } = useAuth()
	const { orders = [], isLoading: jobsLoading } = useAvailableOrders()
	const { trips = [], isLoading: tripsLoading } = useMyTrips()
	const { payouts, summary, isLoading: payoutLoading } = useTransporterEarnings()
	const profile = user?.transport_profile as TransportProfile | undefined
	const greeting = getTimeGreeting()
	const [isOnline, setIsOnline] = useState(Boolean(profile?.is_online && profile?.available))
	const [availabilityMessage, setAvailabilityMessage] = useState('')
	const [availabilityBusy, setAvailabilityBusy] = useState(false)

	const activeTrips = useMemo(
		() => trips.filter((trip) => !['delivered', 'cancelled'].includes(trip.status)),
		[trips],
	)
	const completedToday = useMemo(
		() =>
			trips.filter(
				(trip) =>
					trip.status === 'delivered' &&
					trip.completed_at?.slice(0, 10) === new Date().toISOString().slice(0, 10),
			).length,
		[trips],
	)
	const metricsLoading = jobsLoading || tripsLoading || payoutLoading
	const recentTrips = trips.slice(0, 4)
	const featuredJobs = orders.slice(0, 3)
	const today = new Date().toISOString().slice(0, 10)
	const todaysPayouts = payouts.filter((payout) => payout.created_at?.slice(0, 10) === today).slice(0, 4)
	const currentTrip = activeTrips[0]
	const vehicleLabel = [profile?.vehicle_type, profile?.license_plate].filter(Boolean).join(' / ') || 'Vehicle details incomplete'
	const routeLabel = currentTrip
		? `${currentTrip.pickup_address || 'Pickup point'} -> ${currentTrip.delivery_address || 'Delivery point'}`
		: 'No active route assigned'

	const toggleAvailability = async () => {
		const next = !isOnline
		setAvailabilityBusy(true)
		setAvailabilityMessage('')
		try {
			await updateTransportProfile({ is_online: next, available: next })
			setIsOnline(next)
		} catch {
			setAvailabilityMessage('Availability could not be updated.')
		} finally {
			setAvailabilityBusy(false)
		}
	}

	const metrics = [
		{
			title: 'Available jobs',
			value: jobsLoading ? '...' : String(orders.length),
			subtitle: 'Open pickups and deliveries',
			icon: <ClipboardList className="h-5 w-5" />,
		},
		{
			title: 'Active trips',
			value: tripsLoading ? '...' : String(activeTrips.length),
			subtitle: 'Trips in progress',
			icon: <Navigation className="h-5 w-5" />,
		},
		{
			title: 'Completed today',
			value: tripsLoading ? '...' : String(completedToday),
			subtitle: 'Successful deliveries',
			icon: <Truck className="h-5 w-5" />,
		},
		{
			title: "Today's earnings",
			value: payoutLoading ? '...' : `KSh ${Number(summary?.today_payout_amount ?? summary?.total_payout_amount ?? 0).toLocaleString()}`,
			subtitle: 'Payouts recorded today',
			icon: <DollarSign className="h-5 w-5" />,
		},
	]

	return (
		<main className="mx-auto max-w-7xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
			<section className="relative overflow-hidden rounded-2xl bg-primary-dark p-5 text-primary-foreground shadow-soft sm:rounded-3xl sm:p-8">
				<div className="relative z-10 max-w-2xl">
					<p className="text-[10px] font-bold uppercase tracking-[0.2em] text-secondary sm:text-xs">Delivery operations</p>
					<h1 className="mt-2 text-2xl font-semibold sm:mt-3 sm:text-4xl">
						{greeting}, {user?.first_name || 'Driver'}.
					</h1>
					<p className="mt-2 max-w-xl text-sm leading-5 text-primary-foreground/75 sm:mt-4 sm:leading-7">
						Find the next route, keep customers informed, and finish every delivery with confidence.
					</p>
					<div className="mt-4 grid grid-cols-2 gap-2 sm:mt-7 sm:flex sm:flex-wrap sm:gap-3">
						<Link to="/app/transport/jobs" className="inline-flex min-h-11 items-center justify-center gap-2 rounded-full bg-secondary px-3 py-2.5 text-xs font-bold text-primary-dark sm:px-5 sm:py-3 sm:text-sm">
							<Plus className="h-4 w-4" />
							Find jobs
						</Link>
						<Link to="/app/transport/active-jobs" className="inline-flex min-h-11 items-center justify-center gap-2 rounded-full border border-primary-foreground/25 px-3 py-2.5 text-center text-xs font-bold text-primary-foreground sm:px-5 sm:py-3 sm:text-sm">
							<Navigation className="h-4 w-4" />
							Active trips
						</Link>
						<Link to="/app/transport/vehicles" className="inline-flex min-h-11 items-center justify-center gap-2 rounded-full border border-primary-foreground/25 px-3 py-2.5 text-center text-xs font-bold text-primary-foreground sm:px-5 sm:py-3 sm:text-sm">
							<Settings2 className="h-4 w-4" />
							Vehicle
						</Link>
					</div>
				</div>
			</section>

			<section className="mt-4 rounded-xl border border-border bg-card p-3 sm:mt-6 sm:rounded-2xl sm:p-5">
					<div className="flex flex-wrap items-center justify-between gap-3 sm:gap-4">
					<div>
						<p className="text-sm font-semibold text-primary-dark">Availability</p>
						<p className="mt-1 text-sm text-muted-foreground">
							{!profile?.deposit_paid ? 'Complete your KSh 500 provider deposit before accepting delivery jobs.' : isOnline ? 'You are visible for new delivery jobs.' : 'You are offline and will not receive new jobs.'}
						</p>
						{!profile?.deposit_paid && profile?.deposit_account_number && <p className="mt-2 text-xs text-muted-foreground">PayBill {profile.paybill_number} · Account {profile.deposit_account_number}</p>}
					</div>
					<button
						type="button"
						role="switch"
						aria-label="Toggle delivery availability"
						aria-checked={isOnline}
						disabled={availabilityBusy || !profile?.deposit_paid}
						onClick={() => void toggleAvailability()}
						className={`relative h-11 w-14 shrink-0 rounded-full transition ${isOnline ? 'bg-primary' : 'bg-muted'} disabled:opacity-60`}
					>
						<span
							className={`absolute top-2.5 h-6 w-6 rounded-full bg-white transition ${isOnline ? 'left-7' : 'left-1'}`}
						/>
					</button>
				</div>
				{availabilityMessage && <p role="alert" className="mt-3 text-sm text-destructive">{availabilityMessage}</p>}
			</section>

			<section className="mt-4 grid grid-cols-2 gap-2 sm:mt-6 sm:grid-cols-2 sm:gap-3 lg:grid-cols-4">
				{metricsLoading
					? Array.from({ length: 4 }).map((_, index) => (
							<div key={index} className="rounded-2xl border border-border bg-card p-4 shadow-sm">
								<Skeleton className="h-4 w-20 rounded-md" />
								<Skeleton className="mt-4 h-8 w-16 rounded-md" />
								<Skeleton className="mt-3 h-3 w-24 rounded-md" />
							</div>
						))
					: metrics.map((metric) => (
							<StatCard
								key={metric.title}
								title={metric.title}
								value={metric.value}
								subtitle={metric.subtitle}
								icon={metric.icon}
								variant="default"
								className="min-w-0"
							/>
						))}
			</section>

					<section className="mt-4 grid gap-3 sm:mt-6 sm:gap-6 lg:grid-cols-[1.2fr_0.8fr]">
					<div className="rounded-xl border border-border bg-card p-3 shadow-sm sm:rounded-2xl sm:p-5">
						<div className="flex items-center justify-between gap-4">
							<div>
								<p className="text-xs font-bold uppercase tracking-[0.16em] text-muted-foreground">Dispatch queue</p>
								<h2 className="mt-1 text-xl font-semibold text-primary-dark">Open delivery jobs</h2>
							</div>
							<Link to="/app/transport/jobs" className="text-sm font-bold text-primary hover:underline">View all</Link>
						</div>
						<div className="mt-3 divide-y divide-border sm:mt-5">
							{jobsLoading ? <Skeleton className="h-20 w-full rounded-xl" /> : featuredJobs.length === 0 ? (
								<p className="py-8 text-sm text-muted-foreground">No delivery jobs are available right now.</p>
							) : featuredJobs.map((job) => (
								<div key={job.uuid} className="flex items-start justify-between gap-4 py-4 first:pt-0 last:pb-0">
									<div className="min-w-0">
										<p className="truncate font-semibold text-primary-dark">Job #{job.order_id || job.order}</p>
										<p className="mt-1 flex items-center gap-1 text-sm text-muted-foreground"><MapPin className="h-3.5 w-3.5 shrink-0" />{job.pickup_address || 'Pickup location'} to {job.delivery_address || 'Delivery location'}</p>
									</div>
									<div className="shrink-0 text-right">
										<p className="font-semibold text-primary-dark">KSh {Number(job.provider_payout ?? job.agreed_fee ?? 0).toLocaleString()}</p>
										<p className="mt-1 text-xs capitalize text-muted-foreground">{job.road_km ? `${job.road_km} km` : job.status.replaceAll('_', ' ')}</p>
									</div>
								</div>
							))}
						</div>
					</div>

					<div className="rounded-xl border border-border bg-card p-3 shadow-sm sm:rounded-2xl sm:p-5">
						<div className="flex items-center gap-3">
							<div className="rounded-xl bg-secondary/20 p-2 text-primary"><Truck className="h-5 w-5" /></div>
							<div><p className="text-xs font-bold uppercase tracking-[0.16em] text-muted-foreground">Vehicle status</p><h2 className="mt-1 text-xl font-semibold text-primary-dark">{vehicleLabel}</h2></div>
						</div>
						<div className="mt-5 space-y-4 text-sm">
							<div className="flex items-start gap-3"><Route className="mt-0.5 h-4 w-4 text-primary" /><div><p className="font-semibold text-primary-dark">Current route</p><p className="mt-1 text-muted-foreground">{routeLabel}</p></div></div>
							<div className="flex items-start gap-3"><Clock3 className="mt-0.5 h-4 w-4 text-primary" /><div><p className="font-semibold text-primary-dark">Trip status</p><p className="mt-1 capitalize text-muted-foreground">{currentTrip ? currentTrip.status.replaceAll('_', ' ') : 'Ready for assignment'}</p></div></div>
							<div className="flex items-start gap-3"><Navigation className="mt-0.5 h-4 w-4 text-primary" /><div><p className="font-semibold text-primary-dark">Distance</p><p className="mt-1 text-muted-foreground">{currentTrip?.road_km ? `${currentTrip.road_km} km on current route` : 'Route distance will appear after assignment'}</p></div></div>
						</div>
					</div>
				</section>

				<section className="mt-4 grid gap-3 sm:mt-6 sm:gap-6 lg:grid-cols-2">
					<div className="rounded-xl border border-border bg-card p-3 shadow-sm sm:rounded-2xl sm:p-5">
						<div className="flex items-center justify-between gap-4"><div><p className="text-xs font-bold uppercase tracking-[0.16em] text-muted-foreground">Activity</p><h2 className="mt-1 text-xl font-semibold text-primary-dark">Recent trip activity</h2></div><Link to="/app/transport/completed-jobs" className="text-sm font-bold text-primary hover:underline">History</Link></div>
						<div className="mt-3 divide-y divide-border sm:mt-5">
							{tripsLoading ? <Skeleton className="h-20 w-full rounded-xl" /> : recentTrips.length === 0 ? <p className="py-8 text-sm text-muted-foreground">Your trip activity will appear here.</p> : recentTrips.map((trip) => (
								<div key={trip.uuid} className="flex items-center justify-between gap-4 py-3 first:pt-0 last:pb-0"><div className="min-w-0"><p className="font-semibold text-primary-dark">Trip #{trip.order_id || trip.order}</p><p className="mt-1 truncate text-sm text-muted-foreground">{trip.delivery_address || 'Delivery destination'}</p></div><div className="shrink-0 text-right"><p className="text-sm font-semibold capitalize text-primary-dark">{trip.status.replaceAll('_', ' ')}</p><p className="mt-1 text-xs text-muted-foreground">KSh {Number(trip.provider_payout ?? trip.agreed_fee ?? 0).toLocaleString()}</p></div></div>
							))}
						</div>
					</div>

					<div className="rounded-xl border border-border bg-card p-3 shadow-sm sm:rounded-2xl sm:p-5">
						<div className="flex items-center justify-between gap-4"><div><p className="text-xs font-bold uppercase tracking-[0.16em] text-muted-foreground">Today</p><h2 className="mt-1 text-xl font-semibold text-primary-dark">Payout breakdown</h2></div><Wallet className="h-5 w-5 text-primary" /></div>
						<div className="mt-5 space-y-3">
							<div className="flex items-center justify-between rounded-xl bg-muted/40 px-4 py-3"><span className="text-sm text-muted-foreground">Completed</span><span className="font-semibold text-primary-dark">KSh {Number(summary?.completed_payout_amount ?? 0).toLocaleString()}</span></div>
							<div className="flex items-center justify-between rounded-xl bg-muted/40 px-4 py-3"><span className="text-sm text-muted-foreground">Pending</span><span className="font-semibold text-primary-dark">KSh {Number(summary?.pending_payout_amount ?? 0).toLocaleString()}</span></div>
							{todaysPayouts.length > 0 && <div className="border-t border-border pt-3">{todaysPayouts.map((payout) => <div key={payout.uuid} className="flex items-center justify-between py-2 text-sm"><span className="capitalize text-muted-foreground">{payout.status}</span><span className="font-semibold text-primary-dark">KSh {Number(payout.amount).toLocaleString()}</span></div>)}</div>}
						</div>
					</div>
				</section>
		</main>
	)
}

