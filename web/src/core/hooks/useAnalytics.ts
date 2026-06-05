import { useState, useCallback } from 'react';
import { apiClient } from '../api/client';
import { ANALYTICS_ENDPOINTS } from '../api/endpoints';

interface Metric {
  id: number;
  [key: string]: any;
}

interface UseAnalyticsState {
  metrics: Metric[];
  loading: boolean;
  error: string | null;
}

export const useAnalytics = () => {
  const [state, setState] = useState<UseAnalyticsState>({
    metrics: [],
    loading: false,
    error: null,
  });

  const listMetrics = useCallback(async (params?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(ANALYTICS_ENDPOINTS.metrics, { params });
      setState((prev) => ({ ...prev, metrics: response.data.results || response.data }));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch metrics';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  return {
    ...state,
    listMetrics,
  };
};
