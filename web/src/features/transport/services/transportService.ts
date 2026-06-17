import { apiClient } from '../../../core/api/client';
import { ADMIN_ENDPOINTS } from '../../../core/api/endpoints';
import type { TransportProviderFilters, TransportProviderRecord } from '../types';

const normalizeArray = <T,>(payload: unknown): T[] => {
	if (Array.isArray(payload)) return payload as T[];
	if (!payload || typeof payload !== 'object') return [];

	const record = payload as Record<string, unknown>;
	if (Array.isArray(record.results)) return record.results as T[];
	if (Array.isArray(record.data)) return record.data as T[];
	return [];
};

const normalizeProvider = (payload: any): TransportProviderRecord => ({
	id: Number(payload.id ?? payload.user_id ?? 0),
	user_id: Number(payload.user_id ?? payload.id ?? 0),
	user_phone: payload.user_phone ?? payload.phone ?? '-',
	user_username: payload.user_username ?? payload.username ?? 'Unknown',
	vehicle_type: payload.vehicle_type ?? '',
	license_plate: payload.license_plate ?? '',
	is_approved: Boolean(payload.is_approved),
	deposit_paid: Boolean(payload.deposit_paid),
	deposit_amount: Number(payload.deposit_amount ?? 0),
	deposit_transaction_id: payload.deposit_transaction_id ?? payload.transaction_id ?? '',
	created_at: payload.created_at ?? payload.createdAt ?? new Date().toISOString(),
	updated_at: payload.updated_at ?? payload.updatedAt,
});

export const listTransportProviders = async (filters?: TransportProviderFilters) => {
	const { data } = await apiClient.get(ADMIN_ENDPOINTS.transportProviders.list, {
		params: {
			status: filters?.status,
			search: filters?.search,
		},
	});

	return normalizeArray<TransportProviderRecord>(data).map(normalizeProvider);
};

export const getTransportProvider = async (id: number | string) => {
	const { data } = await apiClient.get(ADMIN_ENDPOINTS.transportProviders.detail(id));
	return normalizeProvider(data);
};

export const approveTransportProvider = async (id: number | string) => {
	const { data } = await apiClient.post(ADMIN_ENDPOINTS.transportProviders.approve(id));
	return data;
};
