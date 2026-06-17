import { useCallback, useEffect } from 'react';
import { useDisputeStore } from '../stores/disputeStore';
import {
	getAdminDispute,
	getDispute,
	listAdminDisputes,
	listDisputes,
	resolveAdminDispute,
	resolveDispute,
} from '../services/disputeService';
import type { DisputeListFilters, DisputeResolutionForm } from '../types';

const summarize = (disputes: { status: string }[]) => ({
	total: disputes.length,
	open: disputes.filter((dispute) => dispute.status === 'open').length,
	under_review: disputes.filter((dispute) => dispute.status === 'under_review').length,
	resolved: disputes.filter((dispute) => dispute.status === 'resolved').length,
	closed: disputes.filter((dispute) => dispute.status === 'closed').length,
});

export const useDisputes = (filters?: DisputeListFilters, source: 'public' | 'admin' = 'public') => {
	const status = filters?.status;
	const search = filters?.search?.trim() ?? '';

	const disputes = useDisputeStore((state) => state.disputes);
	const selectedDispute = useDisputeStore((state) => state.selectedDispute);
	const summary = useDisputeStore((state) => state.summary);
	const loading = useDisputeStore((state) => state.loading);
	const error = useDisputeStore((state) => state.error);
	const setDisputes = useDisputeStore((state) => state.setDisputes);
	const setSelectedDispute = useDisputeStore((state) => state.setSelectedDispute);
	const setSummary = useDisputeStore((state) => state.setSummary);
	const setLoading = useDisputeStore((state) => state.setLoading);
	const setError = useDisputeStore((state) => state.setError);

	const loadDisputes = useCallback(async () => {
		setLoading(true);
		setError(null);
		try {
			const data = source === 'admin'
				? await listAdminDisputes({ status, search: search || undefined })
				: await listDisputes({ status, search: search || undefined });
			const normalized = search
				? data.filter((dispute) => {
						const query = search.toLowerCase();
						return [
							dispute.uuid,
							dispute.order_number,
							dispute.reason,
							dispute.description,
							dispute.raised_by,
							dispute.raised_by_phone,
						]
							.filter(Boolean)
							.some((value) => String(value).toLowerCase().includes(query));
					})
				: data;

			setDisputes(normalized);
			setSummary(summarize(normalized));
			return normalized;
		} catch (err) {
			setError('Failed to load disputes');
			throw err;
		} finally {
			setLoading(false);
		}
	}, [search, setDisputes, setError, setLoading, setSummary, source, status]);

	const selectDispute = useCallback(
		async (uuid: string) => {
			const dispute = source === 'admin' ? await getAdminDispute(uuid) : await getDispute(uuid);
			setSelectedDispute(dispute);
			return dispute;
		},
		[source, setSelectedDispute],
	);

	const submitResolution = useCallback(
		async (uuid: string, form: DisputeResolutionForm) => {
			const resolved = source === 'admin' ? await resolveAdminDispute(uuid, form) : await resolveDispute(uuid, form);
			await loadDisputes();
			return resolved;
		},
		[loadDisputes, source],
	);

	useEffect(() => {
		void loadDisputes();
	}, [loadDisputes]);

	return {
		disputes,
		selectedDispute,
		summary,
		loading,
		error,
		refetch: loadDisputes,
		selectDispute,
		setSelectedDispute,
		resolveDispute: submitResolution,
	};
};
