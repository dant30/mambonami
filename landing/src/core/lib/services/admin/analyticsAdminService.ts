import { apiClient } from '../../../api'
import { ANALYTICS_ENDPOINTS } from '../../../api/endpoints'
import type { AdminAnalyticsSummary, AdminDailyMetric } from '../../types/admin'

function list<T>(response: T[] | { results?: T[] }): T[] {
	return Array.isArray(response) ? response : response.results ?? []
}

export async function listAdminDailyMetrics(params?: { date?: string }): Promise<AdminDailyMetric[]> {
	return list(await apiClient.get<AdminDailyMetric[] | { results?: AdminDailyMetric[] }>(ANALYTICS_ENDPOINTS.metrics, { params }))
}

export function getAdminAnalyticsSummary(params?: { start_date?: string; end_date?: string }): Promise<AdminAnalyticsSummary> {
	return apiClient.get<AdminAnalyticsSummary>(ANALYTICS_ENDPOINTS.metricsSummary, { params })
}

export function recomputeAdminMetrics(startDate: string, endDate: string): Promise<{ message: string }> {
	return apiClient.post<{ message: string }>(ANALYTICS_ENDPOINTS.recomputeMetrics, { start_date: startDate, end_date: endDate })
}