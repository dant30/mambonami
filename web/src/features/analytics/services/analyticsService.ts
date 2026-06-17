import { apiClient } from '../../../core/api/client';
import { ANALYTICS_ENDPOINTS } from '../../../core/api/endpoints';
import axios from 'axios';
import type {
  AnalyticsDashboardStats,
  AnalyticsPaymentsMetrics,
  AnalyticsSummary,
  AnalyticsTopFarmer,
  AnalyticsTopTransportProvider,
} from '../types';

interface AnalyticsMetricRecord {
  date: string;
  total_orders: number | string;
  new_farmers?: number | string;
  new_transport_providers?: number | string;
  total_paid_to_transport?: number | string;
  disputes_opened?: number | string;
  disputes_resolved?: number | string;
  disputes_escalated?: number | string;
}

const normalizeArray = <T,>(payload: unknown): T[] => {
  if (Array.isArray(payload)) return payload as T[];
  if (!payload || typeof payload !== 'object') return [];

  const record = payload as Record<string, unknown>;
  if (Array.isArray(record.results)) return record.results as T[];
  if (Array.isArray(record.data)) return record.data as T[];
  return [];
};

const today = () => new Date().toISOString().slice(0, 10);
const thirtyDaysAgo = () => {
  const date = new Date();
  date.setDate(date.getDate() - 30);
  return date.toISOString().slice(0, 10);
};

const toNumber = (value: unknown) => Number(value ?? 0) || 0;

let analyticsDashboardCache: AnalyticsDashboardStats | null = null;
let analyticsDashboardPromise: Promise<AnalyticsDashboardStats> | null = null;
let analyticsDashboardCooldownUntil = 0;
const ANALYTICS_DASHBOARD_COOLDOWN_MS = 30_000;

export const listAnalyticsMetrics = async () => {
  const { data } = await apiClient.get(ANALYTICS_ENDPOINTS.metrics);
  return normalizeArray<AnalyticsMetricRecord>(data);
};

export const getAnalyticsSummary = async (params?: { start_date?: string; end_date?: string }) => {
  const { data } = await apiClient.get(`${ANALYTICS_ENDPOINTS.metrics}summary/`, {
    params: {
      start_date: params?.start_date ?? thirtyDaysAgo(),
      end_date: params?.end_date ?? today(),
    },
  });
  return data as AnalyticsSummary;
};

export const getAnalyticsPayments = async (params?: { start_date?: string; end_date?: string }) => {
  const { data } = await apiClient.get(`${ANALYTICS_ENDPOINTS.metrics}payments/`, {
    params: {
      start_date: params?.start_date ?? thirtyDaysAgo(),
      end_date: params?.end_date ?? today(),
    },
  });
  return data as AnalyticsPaymentsMetrics;
};

export const getAnalyticsTopFarmers = async (params?: { limit?: number; days?: number }) => {
  const { data } = await apiClient.get(`${ANALYTICS_ENDPOINTS.metrics}top-farmers/`, {
    params: {
      limit: params?.limit ?? 10,
      days: params?.days ?? 30,
    },
  });
  return normalizeArray<AnalyticsTopFarmer>(data);
};

export const getAnalyticsTopTransportProviders = async (params?: { limit?: number; days?: number }) => {
  const { data } = await apiClient.get(`${ANALYTICS_ENDPOINTS.metrics}top-transport/`, {
    params: {
      limit: params?.limit ?? 10,
      days: params?.days ?? 30,
    },
  });
  return normalizeArray<AnalyticsTopTransportProvider>(data);
};

export const getAnalyticsDashboardStats = async (): Promise<AnalyticsDashboardStats> => {
  if (analyticsDashboardCache) {
    return analyticsDashboardCache;
  }

  if (Date.now() < analyticsDashboardCooldownUntil) {
    throw new Error('Analytics dashboard is temporarily unavailable. Please retry in a moment.');
  }

  if (!analyticsDashboardPromise) {
    analyticsDashboardPromise = (async () => {
      try {
        const [metrics, summary, payments, topFarmers, topTransportProviders] = await Promise.all([
          listAnalyticsMetrics(),
          getAnalyticsSummary(),
          getAnalyticsPayments(),
          getAnalyticsTopFarmers({ limit: 5, days: 30 }),
          getAnalyticsTopTransportProviders({ limit: 5, days: 30 }),
        ]);

        const latestMetric = metrics[0] ?? null;
        const orderTrend = metrics
          .slice()
          .reverse()
          .map((metric: AnalyticsMetricRecord) => ({
            label: metric.date,
            value: toNumber(metric.total_orders),
          }));

        const farmerApprovalBreakdown = latestMetric
          ? [
              { name: 'New', value: toNumber(latestMetric.new_farmers) },
              { name: 'Verified', value: toNumber(latestMetric.total_orders) },
            ]
          : [];

        const providerApprovalBreakdown = latestMetric
          ? [
              { name: 'New', value: toNumber(latestMetric.new_transport_providers) },
              { name: 'Verified', value: toNumber(latestMetric.total_paid_to_transport) },
            ]
          : [];

        const disputeStatusBreakdown = latestMetric
          ? [
              { name: 'Opened', value: toNumber(latestMetric.disputes_opened) },
              { name: 'Resolved', value: toNumber(latestMetric.disputes_resolved) },
              { name: 'Escalated', value: toNumber(latestMetric.disputes_escalated) },
            ]
          : [];

        const payoutStatusBreakdown = payments
          ? [
              { name: 'Collections', value: toNumber(payments.collections.count) },
              { name: 'Payouts', value: toNumber(payments.payouts.count) },
              { name: 'Failed payouts', value: toNumber(payments.payouts.failed_count) },
            ]
          : [];

        analyticsDashboardCache = {
          summary,
          payments,
          topFarmers,
          topTransportProviders,
          orderTrend,
          farmerApprovalBreakdown,
          providerApprovalBreakdown,
          disputeStatusBreakdown,
          payoutStatusBreakdown,
        };

        return analyticsDashboardCache;
      } catch (error) {
        const status = axios.isAxiosError(error) ? error.response?.status : undefined;
        if (status === 429) {
          analyticsDashboardCooldownUntil = Date.now() + ANALYTICS_DASHBOARD_COOLDOWN_MS;
        }
        throw error;
      }
    })().finally(() => {
      analyticsDashboardPromise = null;
    });
  }

  return analyticsDashboardPromise;
};// Analytics service
