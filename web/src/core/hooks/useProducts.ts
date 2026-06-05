import { useState, useCallback } from 'react';
import { apiClient } from '../api/client';
import { PRODUCTS_ENDPOINTS } from '../api/endpoints';
import type { Product } from '../types';

interface ProductCategory {
  id: number;
  [key: string]: any;
}

interface UseProductsState {
  products: Product[];
  categories: ProductCategory[];
  loading: boolean;
  error: string | null;
}

export const useProducts = () => {
  const [state, setState] = useState<UseProductsState>({
    products: [],
    categories: [],
    loading: false,
    error: null,
  });

  const getCategories = useCallback(async () => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(PRODUCTS_ENDPOINTS.categories);
      setState((prev) => ({ ...prev, categories: response.data.results || response.data }));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch categories';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const listProducts = useCallback(async (params?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(PRODUCTS_ENDPOINTS.list, { params });
      setState((prev) => ({ ...prev, products: response.data.results || response.data }));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch products';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const getProduct = useCallback(async (uuid: string) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(PRODUCTS_ENDPOINTS.detail(uuid));
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch product';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const listFarmerProducts = useCallback(async (params?: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.get(PRODUCTS_ENDPOINTS.farmerList, { params });
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to fetch farmer products';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const createFarmerProduct = useCallback(async (data: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.post(PRODUCTS_ENDPOINTS.farmerList, data);
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to create product';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const updateFarmerProduct = useCallback(async (uuid: string, data: Record<string, any>) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiClient.patch(PRODUCTS_ENDPOINTS.farmerDetail(uuid), data);
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to update product';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  const deleteFarmerProduct = useCallback(async (uuid: string) => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      await apiClient.delete(PRODUCTS_ENDPOINTS.farmerDetail(uuid));
      return true;
    } catch (error: any) {
      const errorMessage = error.response?.data?.detail || 'Failed to delete product';
      setState((prev) => ({ ...prev, error: errorMessage }));
      throw error;
    } finally {
      setState((prev) => ({ ...prev, loading: false }));
    }
  }, []);

  return {
    ...state,
    getCategories,
    listProducts,
    getProduct,
    listFarmerProducts,
    createFarmerProduct,
    updateFarmerProduct,
    deleteFarmerProduct,
  };
};
