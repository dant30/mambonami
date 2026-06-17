import { apiClient } from '../../../core/api/client';
import { ADMIN_ENDPOINTS, DISPUTES_ENDPOINTS } from '../../../core/api/endpoints';
import type { DisputeRecord, DisputeResolutionForm, DisputeWorkflowStatus } from '../types';

const disputeListCache = new Map<string, DisputeRecord[]>();
const disputeListPromiseCache = new Map<string, Promise<DisputeRecord[]>>();

const buildListCacheKey = (params?: { status?: DisputeWorkflowStatus; search?: string }) =>
	JSON.stringify({
		status: params?.status ?? null,
		search: params?.search?.trim() || null,
	});

const normalizeArray = <T,>(payload: unknown): T[] => {
	if (Array.isArray(payload)) return payload as T[];
	if (!payload || typeof payload !== 'object') return [];

	const record = payload as Record<string, unknown>;
	if (Array.isArray(record.results)) return record.results as T[];
	if (Array.isArray(record.data)) return record.data as T[];
	return [];
};

const normalizeDispute = (payload: any): DisputeRecord => ({
	uuid: String(payload.uuid ?? payload.id ?? ''),
	order_id: payload.order_id ?? payload.orderId,
	order_number: payload.order_number ?? payload.orderNumber,
	reason: payload.reason ?? '',
	description: payload.description ?? payload.details ?? '',
	status: payload.status ?? 'open',
	raised_by: payload.raised_by ?? payload.reporter_name,
	raised_by_phone: payload.raised_by_phone ?? payload.reporter_phone,
	created_at: payload.created_at ?? payload.createdAt,
	updated_at: payload.updated_at ?? payload.updatedAt,
	evidence_photos: payload.evidence_photos ?? [],
	resolved_amount: payload.resolved_amount,
	resolution_type: payload.resolution_type,
	resolved_by: payload.resolved_by,
	resolved_at: payload.resolved_at,
});

export const listDisputes = async (params?: { status?: DisputeWorkflowStatus; search?: string }) => {
	const cacheKey = buildListCacheKey(params);
	const cached = disputeListCache.get(cacheKey);
	if (cached) return cached;

	const inFlight = disputeListPromiseCache.get(cacheKey);
	if (inFlight) return inFlight;

	const request = apiClient.get(DISPUTES_ENDPOINTS.list, { params }).then(({ data }) => {
		const normalized = normalizeArray<DisputeRecord>(data).map(normalizeDispute);
		disputeListCache.set(cacheKey, normalized);
		return normalized;
	}).finally(() => {
		disputeListPromiseCache.delete(cacheKey);
	});

	disputeListPromiseCache.set(cacheKey, request);
	return request;
};

export const getDispute = async (uuid: string) => {
	const { data } = await apiClient.get(DISPUTES_ENDPOINTS.detail(uuid));
	return normalizeDispute(data);
};

export const createDispute = async (payload: Record<string, unknown>) => {
	const { data } = await apiClient.post(DISPUTES_ENDPOINTS.create, payload);
	return normalizeDispute(data);
};

export const resolveDispute = async (uuid: string, payload: DisputeResolutionForm) => {
	const { data } = await apiClient.post(ADMIN_ENDPOINTS.disputes.resolve(uuid), payload);
	return normalizeDispute(data);
};

export const listAdminDisputes = async (params?: { status?: DisputeWorkflowStatus; search?: string }) => {
	const cacheKey = `admin:${buildListCacheKey(params)}`;
	const cached = disputeListCache.get(cacheKey);
	if (cached) return cached;

	const inFlight = disputeListPromiseCache.get(cacheKey);
	if (inFlight) return inFlight;

	const request = apiClient.get(ADMIN_ENDPOINTS.disputes.list, { params }).then(({ data }) => {
		const normalized = normalizeArray<DisputeRecord>(data).map(normalizeDispute);
		disputeListCache.set(cacheKey, normalized);
		return normalized;
	}).finally(() => {
		disputeListPromiseCache.delete(cacheKey);
	});

	disputeListPromiseCache.set(cacheKey, request);
	return request;
};

export const getAdminDispute = async (uuid: string) => {
	const { data } = await apiClient.get(ADMIN_ENDPOINTS.disputes.detail(uuid));
	return normalizeDispute(data);
};

export const resolveAdminDispute = async (uuid: string, payload: DisputeResolutionForm) => {
	const { data } = await apiClient.post(ADMIN_ENDPOINTS.disputes.resolve(uuid), payload);
	return normalizeDispute(data);
};
