import { useState, useCallback } from 'react';
import { apiClient } from '../api/client';
import { NOTIFICATIONS_ENDPOINTS } from '../api/endpoints';

interface Notification {
  id: number;
  [key: string]: any;
}

interface UseNotificationsState {
  notifications: Notification[];
  loading: boolean;
  error: string | null;
}

export const useNotifications = () => {
  const [state, setState] = useState<UseNotificationsState>({
    notifications: [],
    loading: false,
    error: null,
  });

  const listNotifications = useCallback(async (params?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(NOTIFICATIONS_ENDPOINTS.list, { params });
      setState((prev) => ({
        ...prev,
        notifications: response.data.results || response.data,
      }));
      return response.data;
    } catch (error: any) {
      const errorMessage =
        error.response?.data?.detail || 'Failed to fetch notifications';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const markAsRead = useCallback(async (data?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(NOTIFICATIONS_ENDPOINTS.markRead, data || {});
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to mark as read';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  return {
    ...state,
    listNotifications,
    markAsRead,
  };
};
