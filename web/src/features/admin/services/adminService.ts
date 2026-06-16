import { apiClient } from '../../../core/api/client';
import { ADMIN_ENDPOINTS } from '../../../core/api/endpoints';
import { listOrders as listAdminOrders } from '../../orders/services/orderService';

export const listOrders = async (params?: Record<string, any>) => listAdminOrders(params);

export const listFarmers = async () => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.farmers.list);
  return data?.results ?? data?.data ?? data ?? [];
};

export const approveFarmer = async (farmerId: number | string) => {
  const { data } = await apiClient.post(ADMIN_ENDPOINTS.farmers.approve(farmerId));
  return data;
};

export const listTransportProviders = async () => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.transportProviders.list);
  return data?.results ?? data?.data ?? data ?? [];
};

export const approveTransportProvider = async (providerId: number | string) => {
  const { data } = await apiClient.post(ADMIN_ENDPOINTS.transportProviders.approve(providerId));
  return data;
};

export const listAuditLogs = async () => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.audit.list);
  return data?.results ?? data?.data ?? data ?? [];
};

export const listDisputes = async () => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.disputes.list);
  return data?.results ?? data?.data ?? data ?? [];
};

export const resolveDispute = async (uuid: string, payload: Record<string, unknown>) => {
  const { data } = await apiClient.post(ADMIN_ENDPOINTS.disputes.resolve(uuid), payload);
  return data;
};

export const listPayouts = async () => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.payouts.list);
  return data?.results ?? data?.data ?? data ?? [];
};

export const listUsers = async () => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.users.list);
  return data?.results ?? data?.data ?? data ?? [];
};

export const suspendUser = async (userId: number | string) => {
  const { data } = await apiClient.post(ADMIN_ENDPOINTS.users.suspend(userId));
  return data;
};

export const activateUser = async (userId: number | string) => {
  const { data } = await apiClient.post(ADMIN_ENDPOINTS.users.activate(userId));
  return data;
};

// Get admin dashboard stats
export const getAdminStats = async () => {
  const [farmers, providers, disputes, payouts, orders] = await Promise.all([
    listFarmers(),
    listTransportProviders(),
    listDisputes(),
    listPayouts(),
    listOrders({ page_size: 100 }),
  ]);

  const pendingFarmers = farmers.filter((f: any) => !f.coop_verified).length;
  const approvedFarmers = farmers.length - pendingFarmers;
  const approvedProviders = providers.filter((p: any) => p.is_approved).length;
  const pendingProviders = providers.filter((p: any) => !p.is_approved && p.deposit_paid).length;
  const disputeStatusCounts = {
    open: disputes.filter((d: any) => d.status === 'open').length,
    under_review: disputes.filter((d: any) => d.status === 'under_review').length,
    resolved: disputes.filter((d: any) => d.status === 'resolved').length,
    closed: disputes.filter((d: any) => d.status === 'closed').length,
  };
  const payoutStatusCounts = {
    pending: payouts.filter((p: any) => p.status === 'pending').length,
    processing: payouts.filter((p: any) => p.status === 'processing').length,
    completed: payouts.filter((p: any) => p.status === 'completed').length,
    failed: payouts.filter((p: any) => p.status === 'failed').length,
  };

  const ordersByDate = orders.reduce<Record<string, number>>((acc, order: any) => {
    const date = order.created_at ? new Date(order.created_at).toLocaleDateString() : 'Unknown';
    acc[date] = (acc[date] || 0) + 1;
    return acc;
  }, {});

  return {
    total_farmers: farmers.length,
    pending_farmer_approvals: pendingFarmers,
    pending_transport_approvals: pendingProviders,
    open_disputes: disputeStatusCounts.open + disputeStatusCounts.under_review,
    pending_payouts: payoutStatusCounts.pending + payoutStatusCounts.processing,
    total_orders: orders.length,
    farmerApprovalBreakdown: [
      { name: 'Approved', value: approvedFarmers },
      { name: 'Pending', value: pendingFarmers },
    ],
    providerApprovalBreakdown: [
      { name: 'Approved', value: approvedProviders },
      { name: 'Pending', value: pendingProviders },
    ],
    disputeStatusBreakdown: [
      { name: 'Open', value: disputeStatusCounts.open },
      { name: 'Under review', value: disputeStatusCounts.under_review },
      { name: 'Resolved', value: disputeStatusCounts.resolved },
      { name: 'Closed', value: disputeStatusCounts.closed },
    ],
    payoutStatusBreakdown: [
      { name: 'Pending', value: payoutStatusCounts.pending },
      { name: 'Processing', value: payoutStatusCounts.processing },
      { name: 'Completed', value: payoutStatusCounts.completed },
      { name: 'Failed', value: payoutStatusCounts.failed },
    ],
    orderTrend: Object.entries(ordersByDate)
      .sort(([a], [b]) => new Date(a).getTime() - new Date(b).getTime())
      .map(([label, value]) => ({ label, orders: value })),
  };
};
