import { useState, useCallback } from 'react';
import { apiClient } from '../api/client';
import { DISPUTES_ENDPOINTS } from '../api/endpoints';

interface Dispute {
  uuid: string;
  [key: string]: any;
}

interface UseDisputesState {
  disputes: Dispute[];
  loading: boolean;
  error: string | null;
}

export const useDisputes = () => {
  const [state, setState] = useState<UseDisputesState>({
    disputes: [],
    loading: false,
    error: null,
  });

  const listDisputes = useCallback(async (params?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(DISPUTES_ENDPOINTS.list, { params });
      setState((prev) => ({ ...prev, disputes: response.data.results || response.data }));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch disputes';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const getDispute = useCallback(async (uuid: string) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(DISPUTES_ENDPOINTS.detail(uuid));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch dispute';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const createDispute = useCallback(async (data: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(DISPUTES_ENDPOINTS.create, data);
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to create dispute';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const resolveDispute = useCallback(async (uuid: string, data: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(DISPUTES_ENDPOINTS.resolve(uuid), data);
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to resolve dispute';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  return {
    ...state,
    listDisputes,
    getDispute,
    createDispute,
    resolveDispute,
  };
};
