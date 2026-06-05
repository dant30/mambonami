import { useState, useCallback } from 'react';
import { apiClient } from '../api/client';
import { PAYOUTS_ENDPOINTS } from '../api/endpoints';

interface Payout {
  uuid: string;
  [key: string]: any;
}

interface UsePayoutsState {
  payouts: Payout[];
  loading: boolean;
  error: string | null;
}

export const usePayouts = () => {
  const [state, setState] = useState<UsePayoutsState>({
    payouts: [],
    loading: false,
    error: null,
  });

  const listPayouts = useCallback(async (params?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(PAYOUTS_ENDPOINTS.list, { params });
      setState((prev) => ({ ...prev, payouts: response.data.results || response.data }));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch payouts';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const getPayout = useCallback(async (uuid: string) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(PAYOUTS_ENDPOINTS.detail(uuid));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch payout';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const handleB2CCallback = useCallback(async (data: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(PAYOUTS_ENDPOINTS.b2cCallback, data);
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to handle callback';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const handleB2CTimeout = useCallback(async (data: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(PAYOUTS_ENDPOINTS.b2cTimeout, data);
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to handle timeout';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  return {
    ...state,
    listPayouts,
    getPayout,
    handleB2CCallback,
    handleB2CTimeout,
  };
};
