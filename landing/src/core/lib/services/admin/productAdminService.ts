import { apiClient } from '../../../api'
import { ADMIN_ENDPOINTS } from '../../../api/endpoints'
import type { AdminProduct } from '../../types/admin'

function list<T>(response: T[] | { results?: T[] }): T[] {
	return Array.isArray(response) ? response : response.results ?? []
}

export async function listAdminProducts(): Promise<AdminProduct[]> {
	return list(await apiClient.get<AdminProduct[] | { results?: AdminProduct[] }>(ADMIN_ENDPOINTS.products.list))
}

export function setAdminProductActive(uuid: string, isActive: boolean): Promise<AdminProduct> {
	return apiClient.post<AdminProduct>(ADMIN_ENDPOINTS.products.status(uuid), { is_active: isActive })
}