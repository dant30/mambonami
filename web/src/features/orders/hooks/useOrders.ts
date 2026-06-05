import { useCallback } from 'react';
import useOrderStore from '../stores/orderStore';

export const useOrders = () => {
  const orders = useOrderStore((state) => state.orders);
  const order = useOrderStore((state) => state.order);
  const loading = useOrderStore((state) => state.loading);
  const error = useOrderStore((state) => state.error);
  const fetchOrders = useOrderStore((state) => state.fetchOrders);
  const fetchOrder = useOrderStore((state) => state.fetchOrder);
  const createOrder = useOrderStore((state) => state.createOrder);
  const clearError = useOrderStore((state) => state.clearError);

  return {
    orders,
    order,
    loading,
    error,
    fetchOrders: useCallback(fetchOrders, [fetchOrders]),
    fetchOrder: useCallback(fetchOrder, [fetchOrder]),
    createOrder: useCallback(createOrder, [createOrder]),
    clearError: useCallback(clearError, [clearError]),
  };
};
