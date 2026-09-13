import type { Payout, PayoutSummary } from '../../types'

let cachedPayouts: Payout[] = []
let currentPayout: Payout | null = null
let summary: PayoutSummary | null = null

export const payoutStore = {
	getPayouts(): Payout[] {
		return cachedPayouts
	},
	setPayouts(payouts: Payout[]) {
		cachedPayouts = payouts
	},
	getCurrentPayout(): Payout | null {
		return currentPayout
	},
	setCurrentPayout(payout: Payout | null) {
		currentPayout = payout
	},
	getSummary(): PayoutSummary | null {
		return summary
	},
	setSummary(nextSummary: PayoutSummary | null) {
		summary = nextSummary
	},
	clear() {
		cachedPayouts = []
		currentPayout = null
		summary = null
	},
}
