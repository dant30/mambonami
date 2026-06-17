import { create } from 'zustand';
import type { AnalyticsDashboardStats } from '../types';

type AnalyticsStore = {
  stats: AnalyticsDashboardStats | null;
  loading: boolean;
  error: string | null;
  setStats: (stats: AnalyticsDashboardStats | null) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
};

export const useAnalyticsStore = create<AnalyticsStore>((set) => ({
  stats: null,
  loading: false,
  error: null,
  setStats: (stats) => set({ stats }),
  setLoading: (loading) => set({ loading }),
  setError: (error) => set({ error }),
}));// Analytics store
