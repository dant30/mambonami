import { OrderStatus, SubOrderStatus } from '../../../core/types/order';

const statusLabels: Record<OrderStatus, string> = {
  cart: 'Cart',
  placed: 'Placed',
  paid_escrow: 'Paid',
  transport_assigned: 'Transport Assigned',
  picked_up: 'Picked Up',
  delivered: 'Delivered',
  cancelled: 'Cancelled',
  disputed: 'Disputed',
};

const statusClasses: Record<OrderStatus, string> = {
  cart: 'bg-slate-100 text-slate-800',
  placed: 'bg-amber-100 text-amber-800',
  paid_escrow: 'bg-emerald-100 text-emerald-800',
  transport_assigned: 'bg-sky-100 text-sky-800',
  picked_up: 'bg-indigo-100 text-indigo-800',
  delivered: 'bg-emerald-200 text-emerald-900',
  cancelled: 'bg-red-100 text-red-800',
  disputed: 'bg-orange-100 text-orange-800',
};

const subOrderLabels: Record<SubOrderStatus, string> = {
  pending: 'Pending',
  confirmed: 'Confirmed',
  ready: 'Ready',
  cancelled: 'Cancelled',
};

export const getOrderStatusLabel = (status: OrderStatus) => statusLabels[status] ?? status;

export const getOrderStatusClasses = (status: OrderStatus) =>
  statusClasses[status] ?? 'bg-slate-100 text-slate-800';

export const getSubOrderStatusLabel = (status: SubOrderStatus) => subOrderLabels[status] ?? status;

export const isFinalOrderStatus = (status: OrderStatus) => ['delivered', 'cancelled', 'disputed'].includes(status);
