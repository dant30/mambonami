import { apiClient } from '../../../core/api/client';
import { ORDERS_ENDPOINTS } from '../../../core/api/endpoints';
import type { Order } from '../types/order';

export const listOrders = async (params?: Record<string, any>): Promise<Order[]> => {
  const response = await apiClient.get(ORDERS_ENDPOINTS.list, { params });
  return response.data.results || response.data;
};

export const getOrder = async (uuid: string): Promise<Order> => {
  const response = await apiClient.get(ORDERS_ENDPOINTS.detail(uuid));
  return response.data;
};
