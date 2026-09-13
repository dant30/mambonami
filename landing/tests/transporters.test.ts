import { beforeEach, describe, expect, it } from 'vitest'

import { summarizeTransportDashboard } from '../src/core/lib/services/transporters/transporterService'
import { transporterStore } from '../src/core/lib/stores/transporters/transporterStore'
import type { TransportDashboardData } from '../src/core/lib/types/transporters/transporter'

const data: TransportDashboardData = {
	availableJobs: [{ id: 1, uuid: 'job-1', order: 1, status: 'offered', provider: null }],
	trips: [
		{ id: 2, uuid: 'active-1', order: 2, status: 'en_route_delivery', provider: 1 },
		{ id: 3, uuid: 'done-1', order: 3, status: 'delivered', provider: 1, completed_at: '2026-09-11T09:00:00Z' },
	],
	payouts: [],
	payoutSummary: { total_payout_amount: 1000, completed_payout_amount: 800, pending_payout_amount: 200, today_payout_amount: 150, completed_payout_count: 1, pending_payout_count: 1 },
	profile: { role: 'transport_provider', transport_profile: { is_online: true, available: true } },
}

describe('transporter library', () => {
	beforeEach(() => transporterStore.clear())

	it('summarizes jobs, active trips, completed deliveries, and availability', () => {
		expect(summarizeTransportDashboard(data)).toEqual({ availableJobCount: 1, activeTripCount: 1, completedTodayCount: 1, todayEarnings: 150, isAvailable: true })
	})

	it('stores and clears the transporter dashboard snapshot', () => {
		const summary = summarizeTransportDashboard(data)
		transporterStore.setDashboardData(data, summary)
		expect(transporterStore.getTrips()).toHaveLength(2)
		expect(transporterStore.getSummary()).toEqual(summary)
		transporterStore.clear()
		expect(transporterStore.getTrips()).toEqual([])
		expect(transporterStore.getSummary()).toBeNull()
	})
})
