import { apiClient } from '../../../core/api/client';
import { PRODUCTS_ENDPOINTS } from '../../../core/api/endpoints';
import type { Product } from '../../../core/types';

export const listProducts = async (params?: Record<string, unknown>): Promise<Product[]> => {
  const response = await apiClient.get(PRODUCTS_ENDPOINTS.list, { params });
  return response.data.results || response.data;
};

export const getProduct = async (uuid: string): Promise<Product> => {
  const response = await apiClient.get(PRODUCTS_ENDPOINTS.detail(uuid));
  return response.data;
};

export const listFarmerProducts = async (params?: Record<string, unknown>): Promise<Product[]> => {
  const response = await apiClient.get(PRODUCTS_ENDPOINTS.farmerList, { params });
  return response.data.results || response.data;
};

export const createFarmerProduct = async (payload: Record<string, unknown>): Promise<Product> => {
  const response = await apiClient.post(PRODUCTS_ENDPOINTS.farmerList, payload);
  return response.data;
};

export const updateFarmerProduct = async (uuid: string, payload: Record<string, unknown>): Promise<Product> => {
  const response = await apiClient.patch(PRODUCTS_ENDPOINTS.farmerDetail(uuid), payload);
  return response.data;
};

export const deleteFarmerProduct = async (uuid: string): Promise<void> => {
  await apiClient.delete(PRODUCTS_ENDPOINTS.farmerDetail(uuid));
};
