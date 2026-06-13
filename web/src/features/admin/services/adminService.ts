import { apiClient } from '../../../core/api/client';
import { ADMIN_ENDPOINTS } from '../../../core/api/endpoints';

export const listFarmers = async () => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.farmers.list);
  return data.results || data;
};

export const approveFarmer = async (farmerId: number | string) => {
  const { data } = await apiClient.post(ADMIN_ENDPOINTS.farmers.approve(farmerId));
  return data;
};

export const listTransportProviders = async () => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.transportProviders.list);
  return data.results || data;
};

export const approveTransportProvider = async (providerId: number | string) => {
  const { data } = await apiClient.post(ADMIN_ENDPOINTS.transportProviders.approve(providerId));
  return data;
};

export const listAuditLogs = async () => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.audit.list);
  return data.results || data;
};

export const listDisputes = async () => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.disputes.list);
  return data.results || data;
};

export const resolveDispute = async (uuid: string, payload: Record<string, unknown>) => {
  const { data } = await apiClient.post(ADMIN_ENDPOINTS.disputes.resolve(uuid), payload);
  return data;
};

export const listPayouts = async () => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.payouts.list);
  return data.results || data;
};

export const listUsers = async () => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.users.list);
  return data.results || data;
};

export const suspendUser = async (userId: number | string) => {
  const { data } = await apiClient.post(ADMIN_ENDPOINTS.users.suspend(userId));
  return data;
};

export const activateUser = async (userId: number | string) => {
  const { data } = await apiClient.post(ADMIN_ENDPOINTS.users.activate(userId));
  return data;
};// Admin service
