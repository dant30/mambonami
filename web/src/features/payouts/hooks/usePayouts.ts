import { useCallback, useEffect } from 'react';
import { usePayoutStore } from '../stores/payoutStore';
import { getPayout, handleB2CCallback, handleB2CTimeout, listPayouts } from '../services/payoutService';
import type { PayoutListFilters } from '../types';

const summarize = (payouts: { status: string }[]) => ({
	total: payouts.length,
	pending: payouts.filter((payout) => payout.status === 'pending').length,
	processing: payouts.filter((payout) => payout.status === 'processing').length,
	completed: payouts.filter((payout) => payout.status === 'completed' || payout.status === 'paid').length,
	failed: payouts.filter((payout) => payout.status === 'failed').length,
});

export const usePayouts = (filters?: PayoutListFilters) => {
	const status = filters?.status ?? 'all';
	const search = filters?.search?.trim() ?? '';

	const {
		payouts,
		selectedPayout,
		summary,
		loading,
		error,
		setPayouts,
		setSelectedPayout,
		setSummary,
		setLoading,
		setError,
	} = usePayoutStore();

	const loadPayouts = useCallback(async () => {
		setLoading(true);
		setError(null);
		try {
			const data = await listPayouts({
				status,
				search: search || undefined,
			});
			const normalized = search
				? data.filter((payout) => {
						const query = search.toLowerCase();
						return [
							payout.uuid,
							payout.farmer_name,
							payout.farmer_phone,
							payout.mpesa_transaction_id,
							payout.error_message,
						]
							.filter(Boolean)
							.some((value) => String(value).toLowerCase().includes(query));
					})
				: data;

			setPayouts(normalized);
			setSummary(summarize(normalized));
			return normalized;
		} catch (err) {
			setError('Failed to load payouts');
			throw err;
		} finally {
			setLoading(false);
		}
	}, [search, setError, setLoading, setPayouts, setSummary, status]);

	const selectPayout = useCallback(
		async (uuid: string) => {
			const payout = await getPayout(uuid);
			setSelectedPayout(payout);
			return payout;
		},
		[setSelectedPayout],
	);

	const retryB2CCallback = useCallback(async (payload: Record<string, unknown>) => handleB2CCallback(payload), []);
	const retryB2CTimeout = useCallback(async (payload: Record<string, unknown>) => handleB2CTimeout(payload), []);

	useEffect(() => {
		void loadPayouts();
	}, [loadPayouts]);

	return {
		payouts,
		selectedPayout,
		summary,
		loading,
		error,
		refetch: loadPayouts,
		selectPayout,
		setSelectedPayout,
		handleB2CCallback: retryB2CCallback,
		handleB2CTimeout: retryB2CTimeout,
	};
};
