import { apiClient } from '../../../core/api/client';
import { PAYOUTS_ENDPOINTS } from '../../../core/api/endpoints';
import type { PayoutDetailViewModel, PayoutListFilters, PayoutRecord, PayoutWorkflowStatus } from '../types';

const normalizeArray = <T,>(payload: unknown): T[] => {
	if (Array.isArray(payload)) return payload as T[];
	if (!payload || typeof payload !== 'object') return [];

	const record = payload as Record<string, unknown>;
	if (Array.isArray(record.results)) return record.results as T[];
	if (Array.isArray(record.data)) return record.data as T[];
	return [];
};

const normalizePayout = (payload: any): PayoutRecord => ({
	uuid: String(payload.uuid ?? payload.id ?? ''),
	farmer_name: payload.farmer_name ?? payload.recipient_name ?? 'Unknown',
	farmer_phone: payload.farmer_phone ?? payload.recipient_phone ?? '-',
	amount: Number(payload.amount ?? 0),
	status: (payload.status === 'paid' ? 'completed' : payload.status ?? 'pending') as PayoutWorkflowStatus,
	mpesa_transaction_id: payload.mpesa_transaction_id ?? payload.reference ?? payload.b2c_transaction_id,
	error_message: payload.error_message,
	created_at: payload.created_at ?? payload.createdAt ?? new Date().toISOString(),
	updated_at: payload.updated_at ?? payload.updatedAt,
	recipient_id: payload.recipient_id ?? payload.recipientId,
	currency: payload.currency,
	method: payload.method,
	reference: payload.reference,
	processed_at: payload.processed_at ?? payload.processedAt,
});

export const listPayouts = async (filters?: PayoutListFilters) => {
	const params = {
		status: filters?.status && filters.status !== 'all' ? filters.status : undefined,
		search: filters?.search?.trim() ? filters.search.trim() : undefined,
	};
	const { data } = await apiClient.get(PAYOUTS_ENDPOINTS.list, { params });
	return normalizeArray<PayoutRecord>(data).map(normalizePayout);
};

export const getPayout = async (uuid: string) => {
	const { data } = await apiClient.get(PAYOUTS_ENDPOINTS.detail(uuid));
	return normalizePayout(data) as PayoutDetailViewModel;
};

export const handleB2CCallback = async (payload: Record<string, unknown>) => {
	const { data } = await apiClient.post(PAYOUTS_ENDPOINTS.b2cCallback, payload);
	return data;
};

export const handleB2CTimeout = async (payload: Record<string, unknown>) => {
	const { data } = await apiClient.post(PAYOUTS_ENDPOINTS.b2cTimeout, payload);
	return data;
};
