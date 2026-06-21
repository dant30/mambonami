// web/src/features/payouts/hooks/usePayouts.ts
import { useCallback } from 'react';
import { usePayoutStore } from '../stores/payoutStore';
import { listPayouts as listPayoutsApi, getPayout as getPayoutApi } from '../services/payoutService';
import type { PayoutListFilters } from '../types';
import type { PayoutRecord } from '../types';

const summarize = (payouts: { status: string }[]) => ({
  total: payouts.length,
  pending: payouts.filter((p) => p.status === 'pending').length,
  processing: payouts.filter((p) => p.status === 'processing').length,
  completed: payouts.filter((p) => p.status === 'completed' || p.status === 'paid').length,
  failed: payouts.filter((p) => p.status === 'failed').length,
});

export const usePayouts = (filters?: PayoutListFilters, _scope?: string) => {
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

  // ----- List / load payouts -----
  const listPayouts = useCallback(async (): Promise<PayoutRecord[]> => {
    setLoading(true);
    setError(null);
    try {
      const data = await listPayoutsApi({
        status: status !== 'all' ? status : undefined,
        search: search || undefined,
      });
      // Apply local search filter if needed (already handled by service)
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
  }, [status, search, setPayouts, setSummary, setLoading, setError]);

  // ----- Get single payout -----
  const getPayout = useCallback(async (uuid: string) => {
    setLoading(true);
    setError(null);
    try {
      const payout = await getPayoutApi(uuid);
      setSelectedPayout(payout);
      return payout;
    } catch (err) {
      setError('Failed to load payout');
      throw err;
    } finally {
      setLoading(false);
    }
  }, [setSelectedPayout, setLoading, setError]);

  // ----- Clear error -----
  const clearError = useCallback(() => setError(null), [setError]);

  // ----- Return everything -----
  return {
    // State
    payouts,
    selectedPayout,
    summary,
    loading,
    error,

    // Actions
    listPayouts,          // loads payouts with current filters (alias: refetch)
    refetch: listPayouts, // alias for convenience
    getPayout,
    selectPayout: getPayout,
    setSelectedPayout,
    clearError,
  };
};