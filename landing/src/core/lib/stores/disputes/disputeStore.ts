import type { Dispute } from '../../types'

let cachedDisputes: Dispute[] = []
let currentDispute: Dispute | null = null

export const disputeStore = {
	getDisputes(): Dispute[] {
		return cachedDisputes
	},
	setDisputes(disputes: Dispute[]) {
		cachedDisputes = disputes
	},
	getCurrentDispute(): Dispute | null {
		return currentDispute
	},
	setCurrentDispute(dispute: Dispute | null) {
		currentDispute = dispute
	},
	clear() {
		cachedDisputes = []
		currentDispute = null
	},
}
