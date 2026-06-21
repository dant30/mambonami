// web/src/features/transport/hooks/useTransport.ts
import { useCallback, useEffect } from 'react';
import { useTransportStore } from '../stores/transportStore';
import {
  listTransportProviders,
  getTransportProvider,
  approveTransportProvider,
} from '../services/transportService';
import type { TransportProviderFilters } from '../types';

// Helper to compute summary stats
const summarize = (providers: { is_approved: boolean; deposit_paid: boolean }[]) => ({
  total: providers.length,
  pending: providers.filter((p) => !p.is_approved).length,
  approved: providers.filter((p) => p.is_approved).length,
  depositPaid: providers.filter((p) => p.deposit_paid).length,
});

export const useTransport = (filters?: TransportProviderFilters) => {
  const search = filters?.search?.trim() ?? '';
  const status = filters?.status;

  // Store state
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

  // Load providers with optional search & status filtering
  const loadProviders = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await listTransportProviders({
        status,
        search: search || undefined,
      });

      // Client‑side search (if API doesn't support it)
      const normalized = search
        ? data.filter((provider) => {
            const query = search.toLowerCase();
            const fields = [
              provider.user_username,
              provider.user_phone,
              provider.vehicle_type,
              provider.license_plate,
              provider.deposit_transaction_id,
            ];
            return fields.some((field) => String(field).toLowerCase().includes(query));
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
  }, [search, status, setError, setLoading, setProviders, setSummary]);

  // Select a single provider by ID
  const selectProvider = useCallback(
    async (id: number | string) => {
      setLoading(true);
      setError(null);
      try {
        const provider = await getTransportProvider(id);
        setSelectedProvider(provider);
        return provider;
      } catch (err) {
        setError('Failed to load provider details');
        throw err;
      } finally {
        setLoading(false);
      }
    },
    [setSelectedProvider, setError, setLoading],
  );

  // Approve a provider (admin only)
  const approveProvider = useCallback(
    async (id: number | string) => {
      setLoading(true);
      setError(null);
      try {
        const result = await approveTransportProvider(id);
        // Refresh list after approval
        await loadProviders();
        // Clear selection if it was the approved one
        if (selectedProvider?.id === id) {
          setSelectedProvider(null);
        }
        return result;
      } catch (err) {
        setError('Failed to approve provider');
        throw err;
      } finally {
        setLoading(false);
      }
    },
    [loadProviders, selectedProvider, setSelectedProvider, setError, setLoading],
  );

  // Auto‑load on mount or when filters change
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

export const useTransportProviders = useTransport;