// web/src/features/disputes/hooks/useDisputes.ts
import { useCallback } from 'react';
import { useDisputeStore } from '../stores/disputeStore';
import { listAdminDisputes, getAdminDispute, resolveAdminDispute } from '../services/disputeService';
import type { DisputeListFilters, DisputeResolutionForm } from '../types';
import type { DisputeRecord } from '../types';

// ----- Status helpers (for UI) -----

export const DISPUTE_STATUS_LABELS: Record<string, string> = {
  open: 'Open',
  under_review: 'Under Review',
  resolved: 'Resolved',
  rejected: 'Rejected',
  escalated: 'Escalated',
  closed: 'Closed',
};

export const DISPUTE_STATUS_CLASSES: Record<string, string> = {
  open: 'bg-amber-100 text-amber-800',
  under_review: 'bg-sky-100 text-sky-800',
  resolved: 'bg-emerald-100 text-emerald-800',
  rejected: 'bg-red-100 text-red-800',
  escalated: 'bg-orange-100 text-orange-800',
  closed: 'bg-slate-100 text-slate-800',
};

export const getDisputeStatusLabel = (status: string) =>
  DISPUTE_STATUS_LABELS[status] ?? status;

export const getDisputeStatusClasses = (status: string) =>
  DISPUTE_STATUS_CLASSES[status] ?? 'bg-slate-100 text-slate-800';

// ----- Main hook -----

interface UseDisputesOptions {
  filters?: DisputeListFilters;
}

type UseDisputesInput = DisputeListFilters | UseDisputesOptions | undefined;

const normalizeFilters = (input: UseDisputesInput): DisputeListFilters | undefined => {
  if (!input) return undefined;
  if ('filters' in input) return input.filters;
  return input as DisputeListFilters;
};

export const useDisputes = (options: UseDisputesInput = {}, _scope?: string) => {
  const filters = normalizeFilters(options);

  // Select state from store
  const disputes = useDisputeStore((state) => state.disputes);
  const selectedDispute = useDisputeStore((state) => state.selectedDispute);
  const summary = useDisputeStore((state) => state.summary);
  const loading = useDisputeStore((state) => state.loading);
  const error = useDisputeStore((state) => state.error);

  // Select actions from store
  const setDisputes = useDisputeStore((state) => state.setDisputes);
  const setSelectedDispute = useDisputeStore((state) => state.setSelectedDispute);
  const setSummary = useDisputeStore((state) => state.setSummary);
  const setLoading = useDisputeStore((state) => state.setLoading);
  const setError = useDisputeStore((state) => state.setError);

  // Helper to summarize dispute counts
  const summarizeDisputes = useCallback((items: DisputeRecord[]) => ({
    total: items.length,
    open: items.filter((d) => d.status === 'open').length,
    under_review: items.filter((d) => d.status === 'under_review').length,
    resolved: items.filter((d) => d.status === 'resolved').length,
    rejected: items.filter((d) => d.status === 'rejected').length,
    closed: items.filter((d) => d.status === 'closed').length,
  }), []);

  // ----- Core methods -----

  const listDisputes = useCallback(async (params?: DisputeListFilters) => {
    setLoading(true);
    setError(null);
    try {
      const data = await listAdminDisputes(params);
      setDisputes(data);
      setSummary(summarizeDisputes(data));
      return data;
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to load disputes';
      setError(message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [setLoading, setError, setDisputes, setSummary, summarizeDisputes]);

  const getDispute = useCallback(async (uuid: string) => {
    setLoading(true);
    setError(null);
    try {
      const data = await getAdminDispute(uuid);
      setSelectedDispute(data);
      return data;
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to fetch dispute';
      setError(message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [setLoading, setError, setSelectedDispute]);


  const resolveDispute = useCallback(async (uuid: string, form: DisputeResolutionForm) => {
    setLoading(true);
    setError(null);
    try {
      const result = await resolveAdminDispute(uuid, form);
      // Refresh list to reflect the resolved status
      await listDisputes();
      // Clear selected if it was the resolved one
      if (selectedDispute?.uuid === uuid) {
        setSelectedDispute(null);
      }
      return result;
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to resolve dispute';
      setError(message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [setLoading, setError, listDisputes, selectedDispute, setSelectedDispute]);

  // ----- Combined return ---- 
  return {
    // State
    disputes,
    selectedDispute,
    summary,
    loading,
    error,

    // Actions
    listDisputes,
    getDispute,
    selectDispute: getDispute,
    resolveDispute,
    refetch: useCallback(() => listDisputes(filters), [listDisputes, filters]),
    clearError: useCallback(() => setError(null), [setError]),
  };
};