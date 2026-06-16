// web/src/core/api/endpoints.ts
const DEFAULT_API_BASE = () => {
  if (import.meta.env.VITE_API_BASE_URL) {
    return import.meta.env.VITE_API_BASE_URL;
  }
  if (typeof window !== 'undefined') {
    const protocol = window.location.protocol;
    const host = window.location.hostname;
    const port = window.location.port ? `:${window.location.port}` : '';
    return `${protocol}//${host}${port}`;
  }
  return 'http://localhost:8000';
};

export const API_BASE = DEFAULT_API_BASE();

/**
 * Authentication & User Management Endpoints
 */
export const AUTH_ENDPOINTS = {
  // Auth
  login: '/api/users/login/',
  passwordResetInit: '/api/users/password-reset/init/',
  passwordResetVerify: '/api/users/password-reset/verify/',
  
  // Token management
  tokenRefresh: '/api/token/refresh/',
  tokenVerify: '/api/token/verify/',
  
  // Profile
  profile: '/api/users/profile/',
} as const;

/**
 * Admin-only endpoints
 */
export const ADMIN_ENDPOINTS = {
  users: {
    list: '/admin-api/users/users/',
    detail: (id: string | number) => `/admin-api/users/users/${id}/`,
    suspend: (id: string | number) => `/admin-api/users/users/${id}/suspend/`,
    activate: (id: string | number) => `/admin-api/users/users/${id}/activate/`,
  },
  farmers: {
    list: '/admin-api/users/farmers/',
    detail: (id: string | number) => `/admin-api/users/farmers/${id}/`,
    approve: (id: string | number) => `/admin-api/users/farmers/${id}/approve/`,
  },
  transportProviders: {
    list: '/admin-api/users/transport-providers/',
    detail: (id: string | number) => `/admin-api/users/transport-providers/${id}/`,
    approve: (id: string | number) => `/admin-api/users/transport-providers/${id}/approve/`,
  },
  audit: {
    list: '/admin-api/audit/logs/',
    detail: (uuid: string) => `/admin-api/audit/logs/${uuid}/`,
  },
  disputes: {
    list: '/admin-api/disputes/',
    detail: (uuid: string) => `/admin-api/disputes/${uuid}/`,
    resolve: (uuid: string) => `/admin-api/disputes/${uuid}/resolve/`,
  },
  payouts: {
    list: '/admin-api/payouts/',
    detail: (uuid: string) => `/admin-api/payouts/${uuid}/`,
  },
} as const;

/**
 * Orders Endpoints
 */
export const ORDERS_ENDPOINTS = {
  // Order management
  list: '/api/orders/',
  create: '/api/orders/cart/create-order/',
  detail: (uuid: string) => `/api/orders/${uuid}/`,
  
  // Farmer operations
  farmerSuborders: '/api/orders/farmer/suborders/',
  farmerSuborderDetail: (id: number) => `/api/orders/farmer/suborders/${id}/`,
  farmerConfirmSuborder: (id: number) => `/api/orders/suborder/${id}/confirm/`,
  farmerReady: (id: number) => `/api/orders/suborder/${id}/ready/`,
  
  // Delivery operations
  generateDeliveryOTP: (uuid: string) => `/api/orders/${uuid}/generate-otp/`,
  verifyDeliveryOTP: (uuid: string) => `/api/orders/${uuid}/verify-delivery/`,
} as const;

/**
 * Products Endpoints
 */
export const PRODUCTS_ENDPOINTS = {
  // Public
  categories: '/api/products/categories/',
  list: '/api/products/',
  detail: (uuid: string) => `/api/products/${uuid}/`,
  
  // Farmer management
  farmerList: '/api/products/farmer/products/',
  farmerDetail: (uuid: string) => `/api/products/farmer/products/${uuid}/`,
} as const;

/**
 * Disputes Endpoints
 */
export const DISPUTES_ENDPOINTS = {
  list: '/api/disputes/',
  create: '/api/disputes/create/',
  detail: (uuid: string) => `/api/disputes/${uuid}/`,
  resolve: (uuid: string) => `/api/disputes/${uuid}/resolve/`,
} as const;

/**
 * Logistics/Transport Providers Endpoints
 */
export const LOGISTICS_ENDPOINTS = {
  // Orders availability
  availableOrders: '/api/logistics/orders/available/',
  assignToMe: (orderId: number) => `/api/logistics/orders/${orderId}/assign/`,
  
  // Trip management
  myTrips: '/api/logistics/my-trips/',
  tripDetail: (uuid: string) => `/api/logistics/my-trips/${uuid}/`,
  tripArrive: (uuid: string) => `/api/logistics/my-trips/${uuid}/arrive/`,
  tripPickup: (uuid: string) => `/api/logistics/my-trips/${uuid}/pickup/`,
  generateOTP: (uuid: string) => `/api/logistics/my-trips/${uuid}/generate-otp/`,
  verifyOTP: (uuid: string) => `/api/logistics/trips/${uuid}/verify-otp/`,
} as const;

/**
 * Payouts Endpoints
 */
export const PAYOUTS_ENDPOINTS = {
  list: '/api/payouts/',
  detail: (uuid: string) => `/api/payouts/${uuid}/`,
  b2cCallback: '/api/payouts/b2c/result/',
  b2cTimeout: '/api/payouts/b2c/timeout/',
} as const;

/**
 * Notifications Endpoints
 */
export const NOTIFICATIONS_ENDPOINTS = {
  list: '/api/notifications/',
  markRead: '/api/notifications/mark-read/',
} as const;

/**
 * Audit Log Endpoints
 */
export const AUDIT_ENDPOINTS = {
  list: '/api/audit/',
  detail: (uuid: string) => `/api/audit/${uuid}/`,
} as const;

/**
 * Analytics Endpoints
 */
export const ANALYTICS_ENDPOINTS = {
  metrics: '/api/analytics/metrics/',
} as const;

/**
 * PayBill Endpoints
 */
export const PAYBILL_ENDPOINTS = {
  mpesaCallback: '/api/paybill/mpesa/callback/',
  transactions: '/api/paybill/transactions/',
} as const;

/**
 * Payments Endpoints
 */
export const PAYMENTS_ENDPOINTS = {
  health: '/api/payments/health/',
} as const;

/**
 * Health Check
 */
export const HEALTH_ENDPOINT = '/health/' as const;
