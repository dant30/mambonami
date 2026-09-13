import type { AuthUser, TransportProfile } from '../auth'
import type { Payout, PayoutSummary } from '../payouts'
import type { Trip } from '../logisticts'

export type TransportJob = Trip

export interface TransportVehicle extends TransportProfile {
	vehicle_type: string
	capacity_kg: number
	license_plate: string
	driver_license: string
}

export interface TransportDashboardData {
	availableJobs: TransportJob[]
	trips: Trip[]
	payouts: Payout[]
	payoutSummary: PayoutSummary | null
	profile: AuthUser | null
}

export interface TransportDashboardSummary {
	availableJobCount: number
	activeTripCount: number
	completedTodayCount: number
	todayEarnings: number
	isAvailable: boolean
}

export interface TransportAvailabilityUpdate {
	is_online: boolean
	available: boolean
}
