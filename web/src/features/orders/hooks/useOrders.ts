// web/src/features/orders/hooks/useOrders.ts
import { useCallback } from 'react';
import useOrderStore from '../stores/orderStore';
import type { OrderStatus, SubOrderStatus } from '../types/order';

// ----- Status helpers (merged from useOrderStatus) -----

export const ORDER_STATUS_LABELS: Record<OrderStatus, string> = {
  cart: 'Cart',
  placed: 'Placed',
  paid_escrow: 'Paid',
  transport_assigned: 'Transport Assigned',
  picked_up: 'Picked Up',
  delivered: 'Delivered',
  cancelled: 'Cancelled',
  disputed: 'Disputed',
};

export const ORDER_STATUS_CLASSES: Record<OrderStatus, string> = {
  cart: 'bg-slate-100 text-slate-800',
  placed: 'bg-amber-100 text-amber-800',
  paid_escrow: 'bg-emerald-100 text-emerald-800',
  transport_assigned: 'bg-sky-100 text-sky-800',
  picked_up: 'bg-indigo-100 text-indigo-800',
  delivered: 'bg-emerald-200 text-emerald-900',
  cancelled: 'bg-red-100 text-red-800',
  disputed: 'bg-orange-100 text-orange-800',
};

export const SUBORDER_STATUS_LABELS: Record<SubOrderStatus, string> = {
  pending: 'Pending',
  confirmed: 'Confirmed',
  ready: 'Ready',
  cancelled: 'Cancelled',
};

export const getOrderStatusLabel = (status: OrderStatus) =>
  ORDER_STATUS_LABELS[status] ?? status;

export const getOrderStatusClasses = (status: OrderStatus) =>
  ORDER_STATUS_CLASSES[status] ?? 'bg-slate-100 text-slate-800';

export const getSubOrderStatusLabel = (status: SubOrderStatus) =>
  SUBORDER_STATUS_LABELS[status] ?? status;

export const isFinalOrderStatus = (status: OrderStatus) =>
  ['delivered', 'cancelled', 'disputed'].includes(status);

// ----- Main hook -----

export const useOrders = () => {
  // Select state from store
  const orders = useOrderStore((state) => state.orders);
  const order = useOrderStore((state) => state.order);
  const loading = useOrderStore((state) => state.loading);
  const error = useOrderStore((state) => state.error);

  // Select actions from store
  const fetchOrders = useOrderStore((state) => state.fetchOrders);
  const fetchOrder = useOrderStore((state) => state.fetchOrder);
  const clearError = useOrderStore((state) => state.clearError);

  // Memoize actions to stabilize references (optional but good practice)
  return {
    // State
    orders,
    order,
    loading,
    error,

    // Actions
    fetchOrders: useCallback(fetchOrders, [fetchOrders]),
    fetchOrder: useCallback(fetchOrder, [fetchOrder]),
    clearError: useCallback(clearError, [clearError]),
  };
};