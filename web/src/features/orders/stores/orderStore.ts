import create from 'zustand';
import { Order } from '../types/order';
import * as orderService from '../services/orderService';

interface OrderState {
  orders: Order[];
  order: Order | null;
  loading: boolean;
  error: string | null;
  fetchOrders: (params?: Record<string, any>) => Promise<void>;
  fetchOrder: (uuid: string) => Promise<void>;
  clearError: () => void;
}

export const useOrderStore = create<OrderState>((set) => ({
  orders: [],
  order: null,
  loading: false,
  error: null,
  fetchOrders: async (params) => {
    set({ loading: true, error: null });
    try {
      const orders = await orderService.listOrders(params);
      set({ orders });
    } catch (error: any) {
      set({ error: error.response?.data?.detail || error.message || 'Unable to load orders' });
    } finally {
      set({ loading: false });
    }
  },
  fetchOrder: async (uuid) => {
    set({ loading: true, error: null });
    try {
      const order = await orderService.getOrder(uuid);
      set({ order });
    } catch (error: any) {
      set({ error: error.response?.data?.detail || error.message || 'Unable to load order' });
    } finally {
      set({ loading: false });
    }
  },
  clearError: () => set({ error: null }),
}));

export default useOrderStore;
