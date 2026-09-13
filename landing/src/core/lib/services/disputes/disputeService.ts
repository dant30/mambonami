import { apiClient } from '../../../api'
import { DISPUTE_ENDPOINTS } from '../../../api/endpoints'
import type {
	Dispute,
	DisputeCreateInput,
	DisputeListResponse,
	DisputeResolutionInput,
} from '../../types'

function normalizeDisputes(response: DisputeListResponse | Dispute[]): Dispute[] {
	return Array.isArray(response) ? response : response.results ?? []
}

export async function listDisputes(): Promise<Dispute[]> {
	const response = await apiClient.get<DisputeListResponse | Dispute[]>(DISPUTE_ENDPOINTS.list)
	return normalizeDisputes(response)
}

export async function createDispute(input: DisputeCreateInput): Promise<Dispute> {
	return apiClient.post<Dispute>(DISPUTE_ENDPOINTS.create, input)
}

export async function getDispute(uuid: string): Promise<Dispute> {
	return apiClient.get<Dispute>(DISPUTE_ENDPOINTS.detail(uuid))
}

export async function resolveDispute(uuid: string, input: DisputeResolutionInput): Promise<Dispute> {
	return apiClient.post<Dispute>(DISPUTE_ENDPOINTS.resolve(uuid), input)
}
