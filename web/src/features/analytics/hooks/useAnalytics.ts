import { useCallback, useEffect } from 'react';
import { getAnalyticsDashboardStats } from '../services/analyticsService';
import { useAnalyticsStore } from '../stores/analyticsStore';

export const useAnalytics = () => {
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
      setError('Failed to load analytics dashboard');
      throw err;
    } finally {
      setLoading(false);
    }
  }, [setError, setLoading, setStats]);

  useEffect(() => {
    if (stats) return;
    void refetch();
  }, [refetch, stats]);

  return {
    stats,
    loading,
    error,
    refetch,
  };
};// useAnalytics
