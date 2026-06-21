// web/src/core/api/types.ts

/**
 * Common API utility types used across the application
 */

// ---- Base API types ----
export interface ApiError {
  code?: string;
  message: string;
  details?: Record<string, any> | string;
}

export interface ApiResponse<T = any> {
  data?: T;
  results?: T[];
  error?: ApiError | null;
  detail?: string;
  message?: string;
  status?: string;
  meta?: Record<string, any>;
  [key: string]: any;
}

export interface PaginatedResponse<T> extends ApiResponse<T> {
  count: number;
  next: string | null;
  previous: string | null;
  results: T[];
}

export interface Pagination {
  page: number;
  pageSize: number;
  total: number;
  totalPages: number;
}

export interface ListResponse<T = any> extends ApiResponse<T[]> {
  meta: {
    pagination: Pagination;
    [key: string]: any;
  };
}

export interface ApiErrorResponse {
  status: number;
  message: string;
  errors?: Record<string, string[]>;
  detail?: string;
}

export interface AsyncState<T> {
  data: T | null;
  loading: boolean;
  error: ApiErrorResponse | null;
}

// ---- Auth-related types ----
export interface Tokens {
  access: string;
  refresh?: string;
}

export interface UserProfile {
  id: number;
  phone: string;
  username: string;
  email: string | null;
  first_name: string | null;
  last_name: string | null;
  role: string;
  is_phone_verified: boolean;
  is_staff?: boolean;
  is_superuser?: boolean;
  date_joined: string;
  farm_profile?: {
    farm_gps: string;
    coop_verified: boolean;
    mpesa_number: string;
    total_sales: number;
  } | null;
  transport_profile?: {
    vehicle_type: string;
    capacity_kg: number;
    license_plate: string;
    deposit_paid: boolean;
    is_approved: boolean;
    rating: number;
    total_deliveries: number;
  } | null;
}

export interface LoginResponse {
  tokens: Tokens;
  user: UserProfile;
}

export interface AuthError {
  detail?: string;
  [key: string]: unknown;
}