import { create } from 'zustand';
import type { Farmer, FarmerSummary } from '../types';

type FarmerStore = {
  farmers: Farmer[];
  selectedFarmer: Farmer | null;
  summary: FarmerSummary;
  loading: boolean;
  error: string | null;
  setFarmers: (farmers: Farmer[]) => void;
  setSelectedFarmer: (farmer: Farmer | null) => void;
  setSummary: (summary: FarmerSummary) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
};

const emptySummary: FarmerSummary = {
  total: 0,
  pending: 0,
  approved: 0,
  verified: 0,
};

export const useFarmersStore = create<FarmerStore>((set) => ({
  farmers: [],
  selectedFarmer: null,
  summary: emptySummary,
  loading: false,
  error: null,
  setFarmers: (farmers) => set({ farmers }),
  setSelectedFarmer: (selectedFarmer) => set({ selectedFarmer }),
  setSummary: (summary) => set({ summary }),
  setLoading: (loading) => set({ loading }),
  setError: (error) => set({ error }),
}));