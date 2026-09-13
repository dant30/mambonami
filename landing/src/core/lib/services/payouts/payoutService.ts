import { apiClient } from '../../../api'
import { PAYOUT_ENDPOINTS } from '../../../api/endpoints'
import type { Payout, PayoutListResponse, PayoutSummary } from '../../types'

function normalizePayouts(response: PayoutListResponse | Payout[]): Payout[] {
	return Array.isArray(response) ? response : response.results ?? []
}

export async function listPayouts(): Promise<Payout[]> {
	const response = await apiClient.get<PayoutListResponse | Payout[]>(PAYOUT_ENDPOINTS.list)
	return normalizePayouts(response)
}

export async function getPayout(uuid: string): Promise<Payout> {
	return apiClient.get<Payout>(PAYOUT_ENDPOINTS.detail(uuid))
}

export async function getPayoutSummary(): Promise<PayoutSummary> {
	return apiClient.get<PayoutSummary>(PAYOUT_ENDPOINTS.summary)
}
