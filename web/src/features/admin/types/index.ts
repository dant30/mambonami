// Admin Types

export interface Farmer {
  id: number;
  user_id: number;
  user_phone: string;
  user_username: string;
  user_email: string;
  farm_gps: string;
  coop_name: string;
  coop_verified: boolean;
  mpesa_number: string;
  total_sales: number;
  rating: number;
  created_at: string;
  updated_at: string;
}

export interface TransportProvider {
  id: number;
  user_id: number;
  user_phone: string;
  user_username: string;
  vehicle_type: string;
  license_plate: string;
  is_approved: boolean;
  deposit_paid: boolean;
  deposit_amount: number;
  deposit_transaction_id: string;
  created_at: string;
  updated_at: string;
}

export interface Dispute {
  uuid: string;
  order_id: number;
  order_number: string;
  reason: string;
  description: string;
  status: 'open' | 'under_review' | 'resolved' | 'closed';
  raised_by: string;
  raised_by_phone: string;
  created_at: string;
  updated_at: string;
  evidence_photos?: string[];
  resolved_amount?: number;
  resolution_type?: 'full_refund' | 'partial_refund' | 'penalty' | 'no_action';
  resolved_by?: string;
  resolved_at?: string;
}

export interface AuditLog {
  uuid: string;
  admin_id: number;
  admin_username: string;
  action: string;
  model_name: string;
  object_id: string;
  object_repr: string;
  changes: Record<string, any>;
  timestamp: string;
}

export interface Payout {
  uuid: string;
  farmer_id: number;
  farmer_name: string;
  farmer_phone: string;
  amount: number;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  mpesa_transaction_id?: string;
  error_message?: string;
  created_at: string;
  updated_at: string;
}

export interface AdminUser {
  id: number;
  username: string;
  phone: string;
  email: string;
  is_active: boolean;
  user_type: string;
  role?: string;
  created_at: string;
  updated_at: string;
}

export interface DashboardTrendPoint {
  label: string;
  orders: number;
}

export interface DashboardBreakdownPoint {
  name: string;
  value: number;
}

export interface AdminStats {
  total_farmers: number;
  pending_farmer_approvals: number;
  pending_transport_approvals: number;
  open_disputes: number;
  pending_payouts: number;
  total_orders: number;
  farmerApprovalBreakdown: DashboardBreakdownPoint[];
  providerApprovalBreakdown: DashboardBreakdownPoint[];
  disputeStatusBreakdown: DashboardBreakdownPoint[];
  payoutStatusBreakdown: DashboardBreakdownPoint[];
  orderTrend: DashboardTrendPoint[];
}

// API Response types
export interface ListResponse<T> {
  count: number;
  next: string | null;
  previous: string | null;
  results: T[];
}

export interface ApiResponse<T> {
  data: T;
  message?: string;
  success: boolean;
}
