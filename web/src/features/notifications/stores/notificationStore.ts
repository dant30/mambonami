import { create } from 'zustand';
import type { NotificationRecord, NotificationSummary } from '../types';

type NotificationStore = {
  notifications: NotificationRecord[];
  selectedNotification: NotificationRecord | null;
  summary: NotificationSummary;
  loading: boolean;
  error: string | null;
  setNotifications: (notifications: NotificationRecord[]) => void;
  setSelectedNotification: (notification: NotificationRecord | null) => void;
  setSummary: (summary: NotificationSummary) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
};

const emptySummary: NotificationSummary = {
  total: 0,
  unread: 0,
  sent: 0,
  failed: 0,
};

export const useNotificationStore = create<NotificationStore>((set) => ({
  notifications: [],
  selectedNotification: null,
  summary: emptySummary,
  loading: false,
  error: null,
  setNotifications: (notifications) => set({ notifications }),
  setSelectedNotification: (selectedNotification) => set({ selectedNotification }),
  setSummary: (summary) => set({ summary }),
  setLoading: (loading) => set({ loading }),
  setError: (error) => set({ error }),
}));