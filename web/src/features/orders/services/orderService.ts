import { apiClient } from '../../../core/api/client';
import { ORDERS_ENDPOINTS } from '../../../core/api/endpoints';
import { Order } from '../../../core/types';

export interface OrderCreateItem {
  product_uuid: string;
  quantity: number;
}

export interface OrderCreatePayload {
  delivery_address: string;
  delivery_lat: number;
  delivery_lng: number;
  scheduled_date: string;
  scheduled_time_window: string;
  items: OrderCreateItem[];
}

export const listOrders = async (params?: Record<string, any>): Promise<Order[]> => {
  const response = await apiClient.get(ORDERS_ENDPOINTS.list, { params });
  return response.data.results || response.data;
};

export const getOrder = async (uuid: string): Promise<Order> => {
  const response = await apiClient.get(ORDERS_ENDPOINTS.detail(uuid));
  return response.data;
};

export const createOrder = async (payload: OrderCreatePayload): Promise<Order> => {
  const response = await apiClient.post(ORDERS_ENDPOINTS.create, payload);
  return response.data;
};
