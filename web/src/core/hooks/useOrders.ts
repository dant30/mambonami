import { useState, useCallback } from 'react';
import { apiClient } from '../api/client';
import { ORDERS_ENDPOINTS } from '../api/endpoints';

interface Order {
  uuid: string;
  [key: string]: any;
}

interface UseOrdersState {
  orders: Order[];
  loading: boolean;
  error: string | null;
}

export const useOrders = () => {
  const [state, setState] = useState<UseOrdersState>({
    orders: [],
    loading: false,
    error: null,
  });

  const listOrders = useCallback(async (params?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(ORDERS_ENDPOINTS.list, { params });
      setState((prev) => ({ ...prev, orders: response.data.results || response.data }));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch orders';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const getOrder = useCallback(async (uuid: string) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(ORDERS_ENDPOINTS.detail(uuid));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch order';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const createOrder = useCallback(async (data: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(ORDERS_ENDPOINTS.create, data);
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to create order';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const getFarmerSuborders = useCallback(async (params?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(ORDERS_ENDPOINTS.farmerSuborders, { params });
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch suborders';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const confirmSuborder = useCallback(async (id: number) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(ORDERS_ENDPOINTS.farmerConfirmSuborder(id), {});
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to confirm suborder';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const markReady = useCallback(async (id: number) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(ORDERS_ENDPOINTS.farmerReady(id), {});
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to mark order ready';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const generateDeliveryOTP = useCallback(async (uuid: string) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(ORDERS_ENDPOINTS.generateDeliveryOTP(uuid), {});
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to generate OTP';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const verifyDeliveryOTP = useCallback(async (uuid: string, data: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(ORDERS_ENDPOINTS.verifyDeliveryOTP(uuid), data);
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
    listOrders,
    getOrder,
    createOrder,
    getFarmerSuborders,
    confirmSuborder,
    markReady,
    generateDeliveryOTP,
    verifyDeliveryOTP,
  };
};
