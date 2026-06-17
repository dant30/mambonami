import { create } from 'zustand';
import type { TransportProviderRecord, TransportProviderSummary } from '../types';

type TransportStore = {
	providers: TransportProviderRecord[];
	selectedProvider: TransportProviderRecord | null;
	summary: TransportProviderSummary;
	loading: boolean;
	error: string | null;
	setProviders: (providers: TransportProviderRecord[]) => void;
	setSelectedProvider: (provider: TransportProviderRecord | null) => void;
	setSummary: (summary: TransportProviderSummary) => void;
	setLoading: (loading: boolean) => void;
	setError: (error: string | null) => void;
};

const emptySummary: TransportProviderSummary = {
	total: 0,
	pending: 0,
	approved: 0,
	depositPaid: 0,
};

export const useTransportStore = create<TransportStore>((set) => ({
	providers: [],
	selectedProvider: null,
	summary: emptySummary,
	loading: false,
	error: null,
	setProviders: (providers) => set({ providers }),
	setSelectedProvider: (selectedProvider) => set({ selectedProvider }),
	setSummary: (summary) => set({ summary }),
	setLoading: (loading) => set({ loading }),
	setError: (error) => set({ error }),
}));
