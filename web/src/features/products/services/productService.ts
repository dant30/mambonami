import { apiClient } from '../../../core/api/client';
import { PRODUCTS_ENDPOINTS } from '../../../core/api/endpoints';
import type { Product } from '../types/product';

export const listProducts = async (params?: Record<string, unknown>): Promise<Product[]> => {
  const response = await apiClient.get(PRODUCTS_ENDPOINTS.list, { params });
  return response.data.results || response.data;
};

export const getProduct = async (uuid: string): Promise<Product> => {
  const response = await apiClient.get(PRODUCTS_ENDPOINTS.detail(uuid));
  return response.data;
};
