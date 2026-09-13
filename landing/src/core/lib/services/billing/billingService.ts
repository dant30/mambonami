import { apiClient } from '../../../api'
import { PAYBILL_ENDPOINTS } from '../../../api/endpoints'
import type { BillingSettlement, BillingTransaction, FloatBalance, PayBillSimulationInput, PayBillSimulationResult } from '../../types'

function normalizeList<T>(response: T[] | { results?: T[] }): T[] {
	return Array.isArray(response) ? response : response.results ?? []
}

export async function listBillingTransactions(): Promise<BillingTransaction[]> {
	const response = await apiClient.get<BillingTransaction[] | { results?: BillingTransaction[] }>(PAYBILL_ENDPOINTS.transactions)
	return normalizeList(response)
}

export async function listBillingSettlements(): Promise<BillingSettlement[]> {
	const response = await apiClient.get<BillingSettlement[] | { results?: BillingSettlement[] }>(PAYBILL_ENDPOINTS.settlements)
	return normalizeList(response)
}

export function getFloatBalance(): Promise<FloatBalance> {
	return apiClient.get<FloatBalance>(PAYBILL_ENDPOINTS.floatBalance)
}

export function simulatePayBillPayment(input: PayBillSimulationInput): Promise<PayBillSimulationResult> {
	return apiClient.post<PayBillSimulationResult>(PAYBILL_ENDPOINTS.simulate, input)
}
