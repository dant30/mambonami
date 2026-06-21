// src/features/transport/types/index.ts
export * from './trip';

export interface TransportProviderRecord {
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

export interface TransportProviderFilters {
  status?: 'pending' | 'approved' | 'all';
  search?: string;
}

export interface TransportProviderSummary {
  total: number;
  pending: number;
  approved: number;
  depositPaid: number;
}