import { useCallback, useEffect } from 'react';
import { useNotificationStore } from '../stores/notificationStore';
import { getNotification, listNotifications, markNotificationsRead } from '../services/notificationService';
import type { NotificationFilters } from '../types';

const summarize = (notifications: { status: string; read_at?: string | null }[]) => ({
  total: notifications.length,
  unread: notifications.filter((notification) => !notification.read_at && notification.status !== 'read').length,
  sent: notifications.filter((notification) => notification.status === 'sent').length,
  failed: notifications.filter((notification) => notification.status === 'failed').length,
});

export const useNotifications = (filters?: NotificationFilters) => {
  const status = filters?.status ?? 'all';
  const channel = filters?.channel ?? 'all';
  const search = filters?.search?.trim() ?? '';

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

  const loadNotifications = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await listNotifications({
        status,
        channel,
        search: search || undefined,
      });
      const normalized = search
        ? data.filter((notification) => {
            const query = search.toLowerCase();
            return [notification.title, notification.body, notification.user_phone, notification.user_email]
              .filter(Boolean)
              .some((value) => String(value).toLowerCase().includes(query));
          })
        : data;

      setNotifications(normalized);
      setSummary(summarize(normalized));
      return normalized;
    } catch (err) {
      setError('Failed to load notifications');
      throw err;
    } finally {
      setLoading(false);
    }
  }, [channel, search, setError, setLoading, setNotifications, setSummary, status]);

  const selectNotification = useCallback(
    async (id: number | string) => {
      const notification = await getNotification(id);
      setSelectedNotification(notification);
      return notification;
    },
    [setSelectedNotification],
  );

  const markRead = useCallback(async (ids: Array<number | string>) => markNotificationsRead(ids), []);

  useEffect(() => {
    void loadNotifications();
  }, [loadNotifications]);

  return {
    notifications,
    selectedNotification,
    summary,
    loading,
    error,
    refetch: loadNotifications,
    selectNotification,
    setSelectedNotification,
    markRead,
  };
};