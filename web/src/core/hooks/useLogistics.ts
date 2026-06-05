import { useState, useCallback } from 'react';
import { apiClient } from '../api/client';
import { LOGISTICS_ENDPOINTS } from '../api/endpoints';

interface Trip {
  uuid: string;
  [key: string]: any;
}

interface UseLogisticsState {
  trips: Trip[];
  loading: boolean;
  error: string | null;
}

export const useLogistics = () => {
  const [state, setState] = useState<UseLogisticsState>({
    trips: [],
    loading: false,
    error: null,
  });

  const getAvailableOrders = useCallback(async (params?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(LOGISTICS_ENDPOINTS.availableOrders, { params });
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch available orders';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const assignToMe = useCallback(async (orderId: number) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(LOGISTICS_ENDPOINTS.assignToMe(orderId), {});
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to assign order';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const listMyTrips = useCallback(async (params?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(LOGISTICS_ENDPOINTS.myTrips, { params });
      setState((prev) => ({ ...prev, trips: response.data.results || response.data }));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch trips';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const getTripDetail = useCallback(async (uuid: string) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(LOGISTICS_ENDPOINTS.tripDetail(uuid));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch trip details';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const tripArrive = useCallback(async (uuid: string, data?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(LOGISTICS_ENDPOINTS.tripArrive(uuid), data || {});
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to mark arrival';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const tripPickup = useCallback(async (uuid: string, data?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(LOGISTICS_ENDPOINTS.tripPickup(uuid), data || {});
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to mark pickup';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const generateOTP = useCallback(async (uuid: string) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(LOGISTICS_ENDPOINTS.generateOTP(uuid), {});
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to generate OTP';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const verifyOTP = useCallback(async (uuid: string, data: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(LOGISTICS_ENDPOINTS.verifyOTP(uuid), data);
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to verify OTP';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  return {
    ...state,
    getAvailableOrders,
    assignToMe,
    listMyTrips,
    getTripDetail,
    tripArrive,
    tripPickup,
    generateOTP,
    verifyOTP,
  };
};
