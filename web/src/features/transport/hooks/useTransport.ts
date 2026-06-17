import { useCallback, useEffect } from 'react';
import { useTransportStore } from '../stores/transportStore';
import { approveTransportProvider, getTransportProvider, listTransportProviders } from '../services/transportService';
import type { TransportProviderFilters } from '../types';

const summarize = (providers: { is_approved: boolean; deposit_paid: boolean }[]) => ({
	total: providers.length,
	pending: providers.filter((provider) => !provider.is_approved).length,
	approved: providers.filter((provider) => provider.is_approved).length,
	depositPaid: providers.filter((provider) => provider.deposit_paid).length,
});

export const useTransportProviders = (filters?: TransportProviderFilters) => {
	const status = filters?.status;
	const search = filters?.search?.trim() ?? '';

	const providers = useTransportStore((state) => state.providers);
	const selectedProvider = useTransportStore((state) => state.selectedProvider);
	const summary = useTransportStore((state) => state.summary);
	const loading = useTransportStore((state) => state.loading);
	const error = useTransportStore((state) => state.error);
	const setProviders = useTransportStore((state) => state.setProviders);
	const setSelectedProvider = useTransportStore((state) => state.setSelectedProvider);
	const setSummary = useTransportStore((state) => state.setSummary);
	const setLoading = useTransportStore((state) => state.setLoading);
	const setError = useTransportStore((state) => state.setError);

	const loadProviders = useCallback(async () => {
		setLoading(true);
		setError(null);
		try {
			const data = await listTransportProviders({
				status,
				search: search || undefined,
			});
			const normalized = search
				? data.filter((provider) => {
						const query = search.toLowerCase();
						return [
							provider.user_username,
							provider.user_phone,
							provider.vehicle_type,
							provider.license_plate,
							provider.deposit_transaction_id,
						]
							.filter(Boolean)
							.some((value) => String(value).toLowerCase().includes(query));
					})
				: data;

			setProviders(normalized);
			setSummary(summarize(normalized));
			return normalized;
		} catch (err) {
			setError('Failed to load transport providers');
			throw err;
		} finally {
			setLoading(false);
		}
	}, [search, setError, setLoading, setProviders, setSummary, status]);

	const selectProvider = useCallback(
		async (id: number | string) => {
			const provider = await getTransportProvider(id);
			setSelectedProvider(provider);
			return provider;
		},
		[setSelectedProvider],
	);

	const approveProvider = useCallback(async (id: number | string) => approveTransportProvider(id), []);

	useEffect(() => {
		void loadProviders();
	}, [loadProviders]);

	return {
		providers,
		selectedProvider,
		summary,
		loading,
		error,
		refetch: loadProviders,
		selectProvider,
		setSelectedProvider,
		approveProvider,
	};
};
