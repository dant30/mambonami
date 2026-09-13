import { getProfile, updateTransportProfile } from '../auth/authService'
import { assignTripToMe, declineTrip, getTrip, listAvailableOrders, listMyTrips, updateTripLocation } from '../logisticts/logisticsService'
import { listPayouts, getPayoutSummary } from '../payouts/payoutService'
import type { AuthUser, Payout, PayoutSummary, Trip, TripLocationPayload, TransportProfile } from '../../types'
import type { TransportAvailabilityUpdate, TransportDashboardData, TransportDashboardSummary, TransportVehicle } from '../../types'

export function listTransportJobs(): Promise<Trip[]> { return listAvailableOrders() }
export function listTransportTrips(): Promise<Trip[]> { return listMyTrips() }
export function getTransportTrip(uuid: string): Promise<Trip> { return getTrip(uuid) }
export function acceptTransportJob(uuid: string): Promise<Trip> { return assignTripToMe(uuid) }
export function declineTransportJob(uuid: string, reason?: string): Promise<{ message: string }> { return declineTrip(uuid, reason) }
export function sendTransportLocation(uuid: string, payload: TripLocationPayload): Promise<{ message: string; eta_minutes?: number | null }> { return updateTripLocation(uuid, payload) }
export function listTransportPayouts(): Promise<Payout[]> { return listPayouts() }
export function getTransportPayoutSummary(): Promise<PayoutSummary> { return getPayoutSummary() }
export function getTransportProfile(): Promise<AuthUser> { return getProfile() }
export function updateTransportAvailability(input: TransportAvailabilityUpdate) { return updateTransportProfile(input) }
export function updateTransportVehicle(input: Partial<TransportVehicle>) { return updateTransportProfile(input) }

export async function getTransportDashboardData(): Promise<TransportDashboardData> {
	const [availableJobs, trips, payouts, payoutSummary, profile] = await Promise.all([listAvailableOrders(), listMyTrips(), listPayouts(), getPayoutSummary(), getProfile()])
	return { availableJobs, trips, payouts, payoutSummary, profile }
}

export function summarizeTransportDashboard(data: TransportDashboardData): TransportDashboardSummary {
	const today = new Date().toISOString().slice(0, 10)
	return {
		availableJobCount: data.availableJobs.length,
		activeTripCount: data.trips.filter((trip) => !['delivered', 'cancelled'].includes(trip.status)).length,
		completedTodayCount: data.trips.filter((trip) => trip.status === 'delivered' && trip.completed_at?.slice(0, 10) === today).length,
		todayEarnings: Number(data.payoutSummary?.today_payout_amount ?? 0),
		isAvailable: Boolean(data.profile?.transport_profile && (data.profile.transport_profile as TransportProfile).is_online && (data.profile.transport_profile as TransportProfile).available),
	}
}
