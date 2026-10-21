import { apiClient } from '../../../api'
import { ADMIN_ENDPOINTS } from '../../../api/endpoints'
import type { AdminProduct } from '../../types/admin'
import type { ProductCreateInput } from '../../types/products'

function list<T>(response: T[] | { results?: T[] }): T[] {
	return Array.isArray(response) ? response : response.results ?? []
}

export async function listAdminProducts(): Promise<AdminProduct[]> {
	return list(await apiClient.get<AdminProduct[] | { results?: AdminProduct[] }>(ADMIN_ENDPOINTS.products.list))
}

export function setAdminProductActive(uuid: string, isActive: boolean): Promise<AdminProduct> {
	return apiClient.post<AdminProduct>(ADMIN_ENDPOINTS.products.status(uuid), { is_active: isActive })
}

export function getAdminProduct(uuid: string): Promise<AdminProduct> {
	return apiClient.get<AdminProduct>(ADMIN_ENDPOINTS.products.detail(uuid))
}

export function updateAdminProduct(uuid: string, input: Partial<ProductCreateInput>): Promise<AdminProduct> {
	return apiClient.patch<AdminProduct>(ADMIN_ENDPOINTS.products.detail(uuid), input)
}