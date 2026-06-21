// web/src/features/notifications/hooks/useNotifications.ts
import { useCallback, useEffect } from 'react';
import { useNotificationStore } from '../stores/notificationStore';
import { getNotification, listNotifications as listNotificationsApi, markNotificationsRead } from '../services/notificationService';
import type { NotificationFilters, NotificationRecord } from '../types';

const buildFilterParams = (filters?: NotificationFilters) => {
  const params: Record<string, string> = {};
  if (filters?.status && filters.status !== 'all') params.status = filters.status;
  if (filters?.channel && filters.channel !== 'all') params.channel = filters.channel;
  if (filters?.search?.trim()) params.search = filters.search.trim();
  return params;
};

const summarize = (notifications: { status: string; read_at?: string | null }[]) => ({
  total: notifications.length,
  unread: notifications.filter((n) => !n.read_at && n.status !== 'read').length,
  sent: notifications.filter((n) => n.status === 'sent').length,
  failed: notifications.filter((n) => n.status === 'failed').length,
});

export const useNotifications = (filters?: NotificationFilters) => {
  // ── Store selectors ──
  const notifications = useNotificationStore((state) => state.notifications);
  const selectedNotification = useNotificationStore((state) => state.selectedNotification);
  const summary = useNotificationStore((state) => state.summary);
  const loading = useNotificationStore((state) => state.loading);
  const error = useNotificationStore((state) => state.error);

  const setNotifications = useNotificationStore((state) => state.setNotifications);
  const setSelectedNotification = useNotificationStore((state) => state.setSelectedNotification);
  const setSummary = useNotificationStore((state) => state.setSummary);
  const setLoading = useNotificationStore((state) => state.setLoading);
  const setError = useNotificationStore((state) => state.setError);

  // ── Core actions ──
  const loadNotifications = useCallback(async (): Promise<NotificationRecord[]> => {
    setLoading(true);
    setError(null);
    try {
      const params = buildFilterParams(filters);
      const data = await listNotificationsApi(params);
      setNotifications(data);
      setSummary(summarize(data));
      return data;
    } catch (err) {
      setError('Failed to load notifications');
      throw err;
    } finally {
      setLoading(false);
    }
  }, [filters, setLoading, setError, setNotifications, setSummary]);

  const selectNotification = useCallback(
    async (id: number | string) => {
      const notification = await getNotification(id);
      setSelectedNotification(notification);
      return notification;
    },
    [setSelectedNotification],
  );

  const markRead = useCallback(
    async (ids: Array<number | string>) => {
      await markNotificationsRead(ids);
      // Refresh list after marking read
      await loadNotifications();
    },
    [loadNotifications],
  );

  const clearError = useCallback(() => setError(null), [setError]);

  // ── Auto‑fetch on mount and when filters change ──
  useEffect(() => {
    void loadNotifications();
  }, [loadNotifications]);

  // ── Backward‑compatible aliases (from core version) ──
  const listNotifications = useCallback(
    async (_params?: Record<string, any>): Promise<NotificationRecord[]> => {
      // If params are provided, they override the hook's filters.
      // For simplicity, we ignore them and use the filters passed to the hook.
      // If you need dynamic params, consider using the store's `fetch` method directly.
      return loadNotifications();
    },
    [loadNotifications],
  );

  const markAsRead = useCallback(
    async (data?: Record<string, any>): Promise<void> => {
      // data is expected to have an `ids` array; fallback to empty array.
      const ids = data?.ids ?? [];
      return markRead(ids);
    },
    [markRead],
  );

  // ── Public API ──
  return {
    // State
    notifications,
    selectedNotification,
    summary,
    loading,
    error,

    // Actions
    refetch: loadNotifications,
    selectNotification,
    setSelectedNotification,
    markRead,
    clearError,

    // Aliases for backward compatibility
    listNotifications,
    markAsRead,
  };
};