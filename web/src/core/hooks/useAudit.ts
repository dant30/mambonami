import { useState, useCallback } from 'react';
import { apiClient } from '../api/client';
import { AUDIT_ENDPOINTS } from '../api/endpoints';

interface AuditLog {
  uuid: string;
  [key: string]: any;
}

interface UseAuditState {
  logs: AuditLog[];
  loading: boolean;
  error: string | null;
}

export const useAudit = () => {
  const [state, setState] = useState<UseAuditState>({
    logs: [],
    loading: false,
    error: null,
  });

  const listLogs = useCallback(async (params?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(AUDIT_ENDPOINTS.list, { params });
      setState((prev) => ({ ...prev, logs: response.data.results || response.data }));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch audit logs';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const getLog = useCallback(async (uuid: string) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(AUDIT_ENDPOINTS.detail(uuid));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch audit log';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  return {
    ...state,
    listLogs,
    getLog,
  };
};
