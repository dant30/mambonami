import { create } from 'zustand';
import type { DisputeListSummary, DisputeRecord } from '../types';

type DisputeStore = {
	disputes: DisputeRecord[];
	selectedDispute: DisputeRecord | null;
	summary: DisputeListSummary;
	loading: boolean;
	error: string | null;
	setDisputes: (disputes: DisputeRecord[]) => void;
	setSelectedDispute: (dispute: DisputeRecord | null) => void;
	setSummary: (summary: DisputeListSummary) => void;
	setLoading: (loading: boolean) => void;
	setError: (error: string | null) => void;
};

const emptySummary: DisputeListSummary = {
	total: 0,
	open: 0,
	under_review: 0,
	resolved: 0,
	closed: 0,
};

export const useDisputeStore = create<DisputeStore>((set) => ({
	disputes: [],
	selectedDispute: null,
	summary: emptySummary,
	loading: false,
	error: null,
	setDisputes: (disputes) => set({ disputes }),
	setSelectedDispute: (selectedDispute) => set({ selectedDispute }),
	setSummary: (summary) => set({ summary }),
	setLoading: (loading) => set({ loading }),
	setError: (error) => set({ error }),
}));
