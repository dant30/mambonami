export interface AnalyticsTrendPoint {
  label: string;
  value: number;
}

export interface AnalyticsBreakdownPoint {
  name: string;
  value: number;
}

export interface AnalyticsSummary {
  start_date: string;
  end_date: string;
  total_orders: number;
  completed_orders: number;
  total_sales: string | number;
  platform_commission: string | number;
  total_paid_to_farmers: string | number;
  total_paid_to_transport: string | number;
}

export interface AnalyticsPaymentsMetrics {
  start_date: string;
  end_date: string;
  collections: {
    total_amount: string | number;
    count: number;
    matched_count: number;
    orphaned_count: number;
  };
  payouts: {
    total_amount: string | number;
    count: number;
    failed_count: number;
  };
}

export interface AnalyticsTopFarmer {
  id: number;
  user_phone: string;
  total_sales: number | string;
}

export interface AnalyticsTopTransportProvider {
  id: number;
  user_phone: string;
  total_deliveries: number | string;
}

export interface AnalyticsDashboardStats {
  summary: AnalyticsSummary | null;
  payments: AnalyticsPaymentsMetrics | null;
  topFarmers: AnalyticsTopFarmer[];
  topTransportProviders: AnalyticsTopTransportProvider[];
  orderTrend: AnalyticsTrendPoint[];
  farmerApprovalBreakdown: AnalyticsBreakdownPoint[];
  providerApprovalBreakdown: AnalyticsBreakdownPoint[];
  disputeStatusBreakdown: AnalyticsBreakdownPoint[];
  payoutStatusBreakdown: AnalyticsBreakdownPoint[];
}
