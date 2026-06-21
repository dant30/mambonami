// features/analytics/hooks/useAnalytics.ts
import { useCallback, useEffect } from 'react';
import { getAnalyticsDashboardStats } from '../services/analyticsService';
import { useAnalyticsStore } from '../stores/analyticsStore';

/**
 * Hook for fetching and managing analytics dashboard data.
 * Uses a store to cache state across components.
 */
export const useAnalytics = (options?: { autoFetch?: boolean }) => {
  const { autoFetch = true } = options ?? {};

  const stats = useAnalyticsStore((state) => state.stats);
  const loading = useAnalyticsStore((state) => state.loading);
  const error = useAnalyticsStore((state) => state.error);
  const setStats = useAnalyticsStore((state) => state.setStats);
  const setLoading = useAnalyticsStore((state) => state.setLoading);
  const setError = useAnalyticsStore((state) => state.setError);

  const refetch = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const dashboardStats = await getAnalyticsDashboardStats();
      setStats(dashboardStats);
      return dashboardStats;
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to load analytics';
      setError(message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [setError, setLoading, setStats]);

  useEffect(() => {
    // Only fetch if autoFetch is true and we don't have data yet
    if (autoFetch && !stats) {
      void refetch();
    }
  }, [autoFetch, refetch, stats]);

  return {
    stats,
    loading,
    error,
    refetch,
    // Optional: clear cache if needed
    clear: useCallback(() => {
      setStats(null);
      setError(null);
    }, [setStats, setError]),
  };
};