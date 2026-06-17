import { useCallback, useEffect } from 'react';
import { useFarmersStore } from '../stores/farmerStore';
import { approveFarmer, getFarmer, listFarmers } from '../services/farmerService';
import type { FarmerFilters } from '../types';

const summarize = (farmers: { coop_verified: boolean }[]) => ({
  total: farmers.length,
  pending: farmers.filter((farmer) => !farmer.coop_verified).length,
  approved: farmers.filter((farmer) => farmer.coop_verified).length,
  verified: farmers.filter((farmer) => farmer.coop_verified).length,
});

export const useFarmers = (filters?: FarmerFilters) => {
  const status = filters?.status;
  const search = filters?.search?.trim() ?? '';

  const farmers = useFarmersStore((state) => state.farmers);
  const selectedFarmer = useFarmersStore((state) => state.selectedFarmer);
  const summary = useFarmersStore((state) => state.summary);
  const loading = useFarmersStore((state) => state.loading);
  const error = useFarmersStore((state) => state.error);
  const setFarmers = useFarmersStore((state) => state.setFarmers);
  const setSelectedFarmer = useFarmersStore((state) => state.setSelectedFarmer);
  const setSummary = useFarmersStore((state) => state.setSummary);
  const setLoading = useFarmersStore((state) => state.setLoading);
  const setError = useFarmersStore((state) => state.setError);

  const loadFarmers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await listFarmers({
        status,
        search: search || undefined,
      });
      const normalized = search
        ? data.filter((farmer) => {
            const query = search.toLowerCase();
            return [
              farmer.user_username,
              farmer.user_phone,
              farmer.user_email,
              farmer.coop_name,
              farmer.mpesa_number,
            ]
              .filter(Boolean)
              .some((value) => String(value).toLowerCase().includes(query));
          })
        : data;

      setFarmers(normalized);
      setSummary(summarize(normalized));
      return normalized;
    } catch (err) {
      setError('Failed to load farmers');
      throw err;
    } finally {
      setLoading(false);
    }
  }, [search, setError, setFarmers, setLoading, setSummary, status]);

  const selectFarmer = useCallback(
    async (id: number | string) => {
      const farmer = await getFarmer(id);
      setSelectedFarmer(farmer);
      return farmer;
    },
    [setSelectedFarmer],
  );

  const approveSelectedFarmer = useCallback(async (id: number | string) => approveFarmer(id), []);

  useEffect(() => {
    void loadFarmers();
  }, [loadFarmers]);

  return {
    farmers,
    selectedFarmer,
    summary,
    loading,
    error,
    refetch: loadFarmers,
    selectFarmer,
    setSelectedFarmer,
    approveFarmer: approveSelectedFarmer,
  };
};