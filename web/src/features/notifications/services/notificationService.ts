import { apiClient } from '../../../core/api/client';
import type { NotificationFilters, NotificationRecord } from '../types';

const normalizeArray = <T,>(payload: unknown): T[] => {
  if (Array.isArray(payload)) return payload as T[];
  if (!payload || typeof payload !== 'object') return [];

  const record = payload as Record<string, unknown>;
  if (Array.isArray(record.results)) return record.results as T[];
  if (Array.isArray(record.data)) return record.data as T[];
  return [];
};

const normalizeNotification = (payload: any): NotificationRecord => ({
  id: Number(payload.id ?? 0),
  user_id: Number(payload.user_id ?? payload.user ?? 0),
  user_phone: payload.user_phone ?? payload.phone,
  user_email: payload.user_email ?? payload.email,
  title: payload.title ?? '',
  body: payload.body ?? '',
  channel: payload.channel ?? 'push',
  status: payload.status ?? 'pending',
  metadata: payload.metadata ?? null,
  external_id: payload.external_id ?? null,
  error_message: payload.error_message ?? null,
  delivered_at: payload.delivered_at ?? null,
  read_at: payload.read_at ?? null,
  created_at: payload.created_at ?? payload.createdAt ?? new Date().toISOString(),
  updated_at: payload.updated_at ?? payload.updatedAt,
});

const NOTIFICATIONS_ENDPOINTS = {
  list: '/api/notifications/',
  markRead: '/api/notifications/mark-read/',
};

export const listNotifications = async (filters?: NotificationFilters) => {
  const { data } = await apiClient.get(NOTIFICATIONS_ENDPOINTS.list, {
    params: {
      status: filters?.status && filters.status !== 'all' ? filters.status : undefined,
      channel: filters?.channel && filters.channel !== 'all' ? filters.channel : undefined,
      search: filters?.search?.trim() ? filters.search.trim() : undefined,
    },
  });

  return normalizeArray<NotificationRecord>(data).map(normalizeNotification);
};

export const getNotification = async (id: number | string) => {
  const { data } = await apiClient.get(`${NOTIFICATIONS_ENDPOINTS.list}${id}/`);
  return normalizeNotification(data);
};

export const markNotificationsRead = async (notificationIds: Array<number | string>) => {
  const { data } = await apiClient.post(NOTIFICATIONS_ENDPOINTS.markRead, {
    notification_ids: notificationIds.map(Number),
  });
  return data;
};