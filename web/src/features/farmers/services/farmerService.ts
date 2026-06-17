import { apiClient } from '../../../core/api/client';
import { ADMIN_ENDPOINTS } from '../../../core/api/endpoints';
import type { Farmer, FarmerFilters } from '../types';

const normalizeArray = <T,>(payload: unknown): T[] => {
  if (Array.isArray(payload)) return payload as T[];
  if (!payload || typeof payload !== 'object') return [];

  const record = payload as Record<string, unknown>;
  if (Array.isArray(record.results)) return record.results as T[];
  if (Array.isArray(record.data)) return record.data as T[];
  return [];
};

const normalizeFarmer = (payload: any): Farmer => ({
  id: Number(payload.id ?? payload.user_id ?? 0),
  user_id: Number(payload.user_id ?? payload.id ?? 0),
  user_phone: payload.user_phone ?? payload.phone ?? '-',
  user_username: payload.user_username ?? payload.username ?? 'Unknown',
  user_email: payload.user_email ?? payload.email ?? '',
  farm_gps: payload.farm_gps ?? '',
  coop_name: payload.coop_name ?? '',
  coop_verified: Boolean(payload.coop_verified),
  mpesa_number: payload.mpesa_number ?? '',
  total_sales: Number(payload.total_sales ?? 0),
  rating: Number(payload.rating ?? 0),
  created_at: payload.created_at ?? payload.createdAt ?? new Date().toISOString(),
  updated_at: payload.updated_at ?? payload.updatedAt,
});

export const listFarmers = async (filters?: FarmerFilters) => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.farmers.list, {
    params: {
      status: filters?.status,
      search: filters?.search,
    },
  });

  return normalizeArray<Farmer>(data).map(normalizeFarmer);
};

export const getFarmer = async (id: number | string) => {
  const { data } = await apiClient.get(ADMIN_ENDPOINTS.farmers.detail(id));
  return normalizeFarmer(data);
};

export const approveFarmer = async (id: number | string) => {
  const { data } = await apiClient.post(ADMIN_ENDPOINTS.farmers.approve(id));
  return data;
};