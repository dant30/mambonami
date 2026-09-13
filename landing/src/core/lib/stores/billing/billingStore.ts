import type { BillingSettlement, BillingTransaction, FloatBalance } from '../../types'

let transactions: BillingTransaction[] = []
let settlements: BillingSettlement[] = []
let floatBalance: FloatBalance | null = null

export const billingStore = {
	getTransactions: () => transactions,
	setTransactions: (next: BillingTransaction[]) => { transactions = next },
	getSettlements: () => settlements,
	setSettlements: (next: BillingSettlement[]) => { settlements = next },
	getFloatBalance: () => floatBalance,
	setFloatBalance: (next: FloatBalance | null) => { floatBalance = next },
	clear: () => {
		transactions = []
		settlements = []
		floatBalance = null
	},
}
