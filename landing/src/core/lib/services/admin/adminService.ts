import { apiClient } from '../../../api'
import { ADMIN_ENDPOINTS } from '../../../api/endpoints'
import type { Dispute, DisputeResolutionInput } from '../../types/disputes'
import type { Payout } from '../../types/payouts'
import type { AdminAuditLog, AdminFarmer, AdminTransportProvider, AdminUser } from '../../types'
import { listAdminOrders } from './orderAdminService'

function list<T>(response: T[] | { results?: T[] }): T[] { return Array.isArray(response) ? response : response.results ?? [] }

export async function listAdminUsers(): Promise<AdminUser[]> { return list(await apiClient.get<AdminUser[] | { results?: AdminUser[] }>(ADMIN_ENDPOINTS.users.list)) }
export function getAdminUser(id: string | number): Promise<AdminUser> { return apiClient.get<AdminUser>(ADMIN_ENDPOINTS.users.detail(id)) }
export async function listAdminFarmers(): Promise<AdminFarmer[]> { return list(await apiClient.get<AdminFarmer[] | { results?: AdminFarmer[] }>(ADMIN_ENDPOINTS.farmers.list)) }
export function approveAdminFarmer(id: string | number): Promise<AdminFarmer> { return apiClient.post<AdminFarmer>(ADMIN_ENDPOINTS.farmers.approve(id)) }
export async function listAdminTransportProviders(): Promise<AdminTransportProvider[]> { return list(await apiClient.get<AdminTransportProvider[] | { results?: AdminTransportProvider[] }>(ADMIN_ENDPOINTS.transportProviders.list)) }
export function approveAdminTransportProvider(id: string | number): Promise<AdminTransportProvider> { return apiClient.post<AdminTransportProvider>(ADMIN_ENDPOINTS.transportProviders.approve(id)) }
export function suspendAdminUser(id: string | number): Promise<AdminUser> { return apiClient.post<AdminUser>(ADMIN_ENDPOINTS.userActions.suspend(id)) }
export function activateAdminUser(id: string | number): Promise<AdminUser> { return apiClient.post<AdminUser>(ADMIN_ENDPOINTS.userActions.activate(id)) }
export async function listAdminDisputes(): Promise<Dispute[]> { return list(await apiClient.get<Dispute[] | { results?: Dispute[] }>(ADMIN_ENDPOINTS.disputes.list)) }
export function getAdminDispute(uuid: string): Promise<Dispute> { return apiClient.get<Dispute>(ADMIN_ENDPOINTS.disputes.detail(uuid)) }
export function resolveAdminDispute(uuid: string, input: DisputeResolutionInput): Promise<Dispute> { return apiClient.post<Dispute>(ADMIN_ENDPOINTS.disputes.resolve(uuid), input) }
export async function listAdminPayouts(): Promise<Payout[]> { return list(await apiClient.get<Payout[] | { results?: Payout[] }>(ADMIN_ENDPOINTS.payouts.list)) }
export async function listAdminAuditLogs(): Promise<AdminAuditLog[]> { return list(await apiClient.get<AdminAuditLog[] | { results?: AdminAuditLog[] }>(ADMIN_ENDPOINTS.audit.list)) }
export function getAdminAuditLog(uuid: string): Promise<AdminAuditLog> { return apiClient.get<AdminAuditLog>(ADMIN_ENDPOINTS.audit.detail(uuid)) }

export async function getAdminDashboardData() {
	const [orders, users, farmers, transportProviders, disputes, payouts, auditLogs] = await Promise.all([
		listAdminOrders(), listAdminUsers(), listAdminFarmers(), listAdminTransportProviders(), listAdminDisputes(), listAdminPayouts(), listAdminAuditLogs(),
	])
	return { orders, users, farmers, transportProviders, disputes, payouts, auditLogs }
}

