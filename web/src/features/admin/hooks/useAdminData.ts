import { useCallback, useEffect, useState } from 'react';
import {
  Farmer,
  TransportProvider,
  Dispute,
  AuditLog,
  Payout,
  AdminUser,
} from '../types';
import * as adminService from '../services/adminService';

// Farmer hook
export const useFarmers = (filter?: 'pending' | 'approved' | 'rejected') => {
  const [farmers, setFarmers] = useState<Farmer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadFarmers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await adminService.listFarmers();
      let filtered = data as Farmer[];
      if (filter === 'pending') {
        filtered = filtered.filter(f => !f.coop_verified);
      } else if (filter === 'approved') {
        filtered = filtered.filter(f => f.coop_verified);
      }
      setFarmers(filtered);
    } catch (err) {
      setError('Failed to load farmers');
    } finally {
      setLoading(false);
    }
  }, [filter]);

  useEffect(() => {
    loadFarmers();
  }, [loadFarmers]);

  return { farmers, loading, error, refetch: loadFarmers };
};

// Transport providers hook
export const useTransportProviders = (filter?: 'pending' | 'approved') => {
  const [providers, setProviders] = useState<TransportProvider[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadProviders = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await adminService.listTransportProviders();
      let filtered = data as TransportProvider[];
      if (filter === 'pending') {
        filtered = filtered.filter(p => !p.is_approved && p.deposit_paid);
      } else if (filter === 'approved') {
        filtered = filtered.filter(p => p.is_approved);
      }
      setProviders(filtered);
    } catch (err) {
      setError('Failed to load transport providers');
    } finally {
      setLoading(false);
    }
  }, [filter]);

  useEffect(() => {
    loadProviders();
  }, [loadProviders]);

  return { providers, loading, error, refetch: loadProviders };
};

// Disputes hook
export const useDisputes = (filter?: 'open' | 'under_review' | 'resolved') => {
  const [disputes, setDisputes] = useState<Dispute[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadDisputes = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await adminService.listDisputes();
      let filtered = data as Dispute[];
      if (filter) {
        filtered = filtered.filter(d => d.status === filter);
      } else {
        filtered = filtered.filter(d => d.status === 'open' || d.status === 'under_review');
      }
      setDisputes(filtered);
    } catch (err) {
      setError('Failed to load disputes');
    } finally {
      setLoading(false);
    }
  }, [filter]);

  useEffect(() => {
    loadDisputes();
  }, [loadDisputes]);

  return { disputes, loading, error, refetch: loadDisputes };
};

// Audit logs hook
export const useAuditLogs = (filter?: { user?: string; action?: string; model?: string }) => {
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadLogs = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await adminService.listAuditLogs();
      let filtered = data as AuditLog[];
      if (filter?.user) {
        filtered = filtered.filter(l => l.admin_username.includes(filter.user || ''));
      }
      if (filter?.action) {
        filtered = filtered.filter(l => l.action.includes(filter.action || ''));
      }
      if (filter?.model) {
        filtered = filtered.filter(l => l.model_name.includes(filter.model || ''));
      }
      setLogs(filtered);
    } catch (err) {
      setError('Failed to load audit logs');
    } finally {
      setLoading(false);
    }
  }, [filter]);

  useEffect(() => {
    loadLogs();
  }, [loadLogs]);

  return { logs, loading, error, refetch: loadLogs };
};

// Users hook
export const useUsers = (filter?: 'active' | 'inactive' | 'all') => {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadUsers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await adminService.listUsers();
      let filtered = data as AdminUser[];
      if (filter && filter !== 'all') {
        filtered = filtered.filter((user) => (filter === 'active' ? user.is_active : !user.is_active));
      }
      setUsers(filtered);
    } catch (err) {
      setError('Failed to load users');
    } finally {
      setLoading(false);
    }
  }, [filter]);

  useEffect(() => {
    loadUsers();
  }, [loadUsers]);

  return { users, loading, error, refetch: loadUsers };
};

// Payouts hook
export const usePayouts = (filter?: 'pending' | 'processing' | 'completed' | 'failed') => {
  const [payouts, setPayouts] = useState<Payout[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadPayouts = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await adminService.listPayouts();
      let filtered = data as Payout[];
      if (filter) {
        filtered = filtered.filter(p => p.status === filter);
      }
      setPayouts(filtered);
    } catch (err) {
      setError('Failed to load payouts');
    } finally {
      setLoading(false);
    }
  }, [filter]);

  useEffect(() => {
    loadPayouts();
  }, [loadPayouts]);

  return { payouts, loading, error, refetch: loadPayouts };
};
