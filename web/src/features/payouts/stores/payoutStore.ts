// web/src/features/payouts/stores/payoutStore.ts
import { create } from 'zustand';
import type { PayoutListSummary, PayoutRecord } from '../types';

type PayoutStore = {
	payouts: PayoutRecord[];
	selectedPayout: PayoutRecord | null;
	summary: PayoutListSummary;
	loading: boolean;
	error: string | null;
	setPayouts: (payouts: PayoutRecord[]) => void;
	setSelectedPayout: (payout: PayoutRecord | null) => void;
	setSummary: (summary: PayoutListSummary) => void;
	setLoading: (loading: boolean) => void;
	setError: (error: string | null) => void;
};

const emptySummary: PayoutListSummary = {
	total: 0,
	pending: 0,
	processing: 0,
	completed: 0,
	failed: 0,
};

export const usePayoutStore = create<PayoutStore>((set) => ({
	payouts: [],
	selectedPayout: null,
	summary: emptySummary,
	loading: false,
	error: null,
	setPayouts: (payouts) => set({ payouts }),
	setSelectedPayout: (selectedPayout) => set({ selectedPayout }),
	setSummary: (summary) => set({ summary }),
	setLoading: (loading) => set({ loading }),
	setError: (error) => set({ error }),
}));
