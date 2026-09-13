import type { AuthUser, Payout, PayoutSummary, Trip } from '../../types'
import type { TransportDashboardData, TransportDashboardSummary } from '../../types'

let availableJobs: Trip[] = []
let trips: Trip[] = []
let payouts: Payout[] = []
let payoutSummary: PayoutSummary | null = null
let profile: AuthUser | null = null
let summary: TransportDashboardSummary | null = null
let currentTrip: Trip | null = null

export const transporterStore = {
	getAvailableJobs: () => availableJobs,
	setAvailableJobs: (next: Trip[]) => { availableJobs = next },
	getTrips: () => trips,
	setTrips: (next: Trip[]) => { trips = next },
	getPayouts: () => payouts,
	setPayouts: (next: Payout[]) => { payouts = next },
	getPayoutSummary: () => payoutSummary,
	setPayoutSummary: (next: PayoutSummary | null) => { payoutSummary = next },
	getProfile: () => profile,
	setProfile: (next: AuthUser | null) => { profile = next },
	getSummary: () => summary,
	setSummary: (next: TransportDashboardSummary | null) => { summary = next },
	getCurrentTrip: () => currentTrip,
	setCurrentTrip: (next: Trip | null) => { currentTrip = next },
	setDashboardData: (data: TransportDashboardData, nextSummary: TransportDashboardSummary) => {
		availableJobs = data.availableJobs
		trips = data.trips
		payouts = data.payouts
		payoutSummary = data.payoutSummary
		profile = data.profile
		summary = nextSummary
	},
	clear: () => {
		availableJobs = []
		trips = []
		payouts = []
		payoutSummary = null
		profile = null
		summary = null
		currentTrip = null
	},
}
