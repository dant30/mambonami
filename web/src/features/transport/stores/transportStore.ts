// web/src/features/transport/stores/transportStore.ts
import { create } from 'zustand';
import type { TransportProviderRecord } from '../types';

// -----------------------------------------------------------------------------
// TYPES
// -----------------------------------------------------------------------------

export interface TransportProvider extends TransportProviderRecord {
  user?: number;
  capacity_kg?: number;
  rating?: number;
  total_deliveries?: number;
}

export interface TransportSummary {
  total: number;
  pending: number;      // not approved
  approved: number;     // is_approved = true
  depositPaid: number;  // deposit_paid = true
}

// -----------------------------------------------------------------------------
// STORE INTERFACE
// -----------------------------------------------------------------------------

interface TransportStore {
  // State
  providers: TransportProvider[];
  selectedProvider: TransportProvider | null;
  summary: TransportSummary;
  loading: boolean;
  error: string | null;

  // Setters – direct state mutations
  setProviders: (providers: TransportProvider[]) => void;
  setSelectedProvider: (provider: TransportProvider | null) => void;
  setSummary: (summary: TransportSummary) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  clearStore: () => void;

  // Derived actions – smarter updates
  updateProvider: (id: number, updates: Partial<TransportProvider>) => void;
  recalculateSummary: () => void; // auto‑sync summary from providers list
}

// -----------------------------------------------------------------------------
// INITIAL STATE
// -----------------------------------------------------------------------------

const initialSummary: TransportSummary = {
  total: 0,
  pending: 0,
  approved: 0,
  depositPaid: 0,
};

// -----------------------------------------------------------------------------
// STORE IMPLEMENTATION
// -----------------------------------------------------------------------------

export const useTransportStore = create<TransportStore>((set, get) => ({
  // ── State ──
  providers: [],
  selectedProvider: null,
  summary: { ...initialSummary },
  loading: false,
  error: null,

  // ── Simple setters ──
  setProviders: (providers) => {
    const summary = computeSummary(providers);
    set({ providers, summary });
  },

  setSelectedProvider: (selectedProvider) => set({ selectedProvider }),

  setSummary: (summary) => set({ summary }),

  setLoading: (loading) => set({ loading }),

  setError: (error) => set({ error }),

  clearStore: () =>
    set({
      providers: [],
      selectedProvider: null,
      summary: { ...initialSummary },
      loading: false,
      error: null,
    }),

  // ── Smart actions ──
  updateProvider: (id, updates) => {
    const { providers } = get();
    const updatedList = providers.map((p) =>
      p.id === id ? { ...p, ...updates } : p
    );
    const summary = computeSummary(updatedList);
    set({ providers: updatedList, summary });
  },

  recalculateSummary: () => {
    const { providers } = get();
    const summary = computeSummary(providers);
    set({ summary });
  },
}));

// -----------------------------------------------------------------------------
// HELPERS (pure functions)
// -----------------------------------------------------------------------------

function computeSummary(providers: TransportProvider[]): TransportSummary {
  const total = providers.length;
  const pending = providers.filter((p) => !p.is_approved).length;
  const approved = providers.filter((p) => p.is_approved).length;
  const depositPaid = providers.filter((p) => p.deposit_paid).length;

  return { total, pending, approved, depositPaid };
}