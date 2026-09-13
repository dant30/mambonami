import { beforeEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '../src/core/api/apiClient'
import { getFloatBalance, listBillingSettlements, listBillingTransactions, simulatePayBillPayment } from '../src/core/lib/services/billing/billingService'
import { billingStore } from '../src/core/lib/stores/billing/billingStore'

const transaction = { id: 1, uuid: 'txn-1', transaction_code: 'QWE123', amount: '250.00', account_number: 'ORD-1', sender_phone: '+254700000000', currency: 'KES', transaction_time: '2026-09-11T10:00:00Z', status: 'completed', running_balance: '1000.00', created_at: '2026-09-11T10:00:00Z' } as const
const settlement = { id: 1, uuid: 'settlement-1', settlement_date: '2026-09-11', amount: '500.00', status: 'settled', created_at: '2026-09-11T10:00:00Z', updated_at: '2026-09-11T10:00:00Z' } as const

describe('billing library', () => {
	beforeEach(() => {
		billingStore.clear()
	})

	it('normalizes paginated transaction and settlement responses', async () => {
		const get = vi.spyOn(apiClient, 'get')
			.mockResolvedValueOnce({ results: [transaction] })
			.mockResolvedValueOnce({ results: [settlement] })
			.mockResolvedValueOnce({ float_balance: '750.00' })

		expect(await listBillingTransactions()).toEqual([transaction])
		expect(await listBillingSettlements()).toEqual([settlement])
		expect(await getFloatBalance()).toEqual({ float_balance: '750.00' })
		expect(get).toHaveBeenNthCalledWith(1, '/api/paybill/transactions/')
	})

	it('forwards development simulation payloads to the PayBill endpoint', async () => {
		const post = vi.spyOn(apiClient, 'post').mockResolvedValue({ success: true, message: 'Payment matched', order_id: 12 })
		const input = { TransactionCode: 'QWE123', Amount: '250.00', AccountNumber: 'ORD-1', PhoneNumber: '+254700000000', Time: '20260911100000' }

		await expect(simulatePayBillPayment(input)).resolves.toEqual({ success: true, message: 'Payment matched', order_id: 12 })
		expect(post).toHaveBeenCalledWith('/api/paybill/simulate/', input)
	})

	it('clears all cached billing state', () => {
		billingStore.setTransactions([transaction])
		billingStore.setSettlements([settlement])
		billingStore.setFloatBalance({ float_balance: '10' })

		billingStore.clear()

		expect(billingStore.getTransactions()).toEqual([])
		expect(billingStore.getSettlements()).toEqual([])
		expect(billingStore.getFloatBalance()).toBeNull()
	})
})
