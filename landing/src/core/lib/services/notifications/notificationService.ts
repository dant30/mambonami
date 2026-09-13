import { apiClient } from '../../../api'
import { NOTIFICATION_ENDPOINTS } from '../../../api/endpoints'
import type {
	Notification,
	NotificationListResponse,
	NotificationPreference,
	NotificationPreferenceInput,
	MarkReadInput,
} from '../../types'

function normalizeNotifications(response: NotificationListResponse | Notification[]): Notification[] {
	return Array.isArray(response) ? response : response.results ?? []
}

function normalizeNotificationPreferences(
	response: NotificationPreference[] | { results?: NotificationPreference[] },
): NotificationPreference[] {
	return Array.isArray(response) ? response : response.results ?? []
}

export async function listNotifications(): Promise<Notification[]> {
	const response = await apiClient.get<NotificationListResponse | Notification[]>(NOTIFICATION_ENDPOINTS.list)
	return normalizeNotifications(response)
}

export async function markNotificationsRead(input: MarkReadInput): Promise<{ status: string }> {
	return apiClient.post<{ status: string }>(NOTIFICATION_ENDPOINTS.markRead, input)
}

export async function listNotificationPreferences(): Promise<NotificationPreference[]> {
	const response = await apiClient.get<NotificationPreference[] | { results?: NotificationPreference[] }>(
		NOTIFICATION_ENDPOINTS.preferences,
	)
	return normalizeNotificationPreferences(response)
}

export async function getNotificationPreference(id: number): Promise<NotificationPreference> {
	return apiClient.get<NotificationPreference>(NOTIFICATION_ENDPOINTS.preference(id))
}

export async function createNotificationPreference(input: NotificationPreferenceInput): Promise<NotificationPreference> {
	return apiClient.post<NotificationPreference>(NOTIFICATION_ENDPOINTS.preferences, input)
}

export async function updateNotificationPreference(
	id: number,
	input: NotificationPreferenceInput,
): Promise<NotificationPreference> {
	return apiClient.put<NotificationPreference>(NOTIFICATION_ENDPOINTS.preference(id), input)
}

export async function deleteNotificationPreference(id: number): Promise<void> {
	await apiClient.delete<void>(NOTIFICATION_ENDPOINTS.preference(id))
}
