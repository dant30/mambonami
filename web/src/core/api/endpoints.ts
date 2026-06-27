// web/src/core/api/endpoints.ts

const DEFAULT_API_BASE = import.meta.env.VITE_API_BASE_URL?.trim() || 'https://api.mambonami.com';

export const API_BASE = DEFAULT_API_BASE;

/**
 * Authentication & Token Endpoints
 * Used for admin login, token refresh, and profile.
 */
export const AUTH_ENDPOINTS = {
  login: '/api/users/login/',
  passwordResetInit: '/api/users/password-reset/init/',
  passwordResetVerify: '/api/users/password-reset/verify/',
  tokenRefresh: '/api/token/refresh/',
  tokenVerify: '/api/token/verify/',
  profile: '/api/users/profile/',
} as const;

/**
 * Admin‑only endpoints – all administrative actions.
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
 * Orders – read‑only for admin (view lists and details).
 * No create / farmer‑specific / delivery endpoints.
 */
export const ORDERS_ENDPOINTS = {
  list: '/api/orders/',
  detail: (uuid: string) => `/api/orders/${uuid}/`,
} as const;

/**
 * Products – read‑only for admin (categories, list, detail).
 * No farmer creation/update endpoints.
 */
export const PRODUCTS_ENDPOINTS = {
  categories: '/api/products/categories/',
  list: '/api/products/',
  detail: (uuid: string) => `/api/products/${uuid}/`,
} as const;

/**
 * Disputes – admin can list, view, and resolve.
 * (Resolve is also in ADMIN_ENDPOINTS, but kept here for completeness.)
 */
export const DISPUTES_ENDPOINTS = {
  list: '/api/disputes/',
  detail: (uuid: string) => `/api/disputes/${uuid}/`,
  resolve: (uuid: string) => `/api/disputes/${uuid}/resolve/`,
} as const;

/**
 * Payouts – read‑only for admin (list, detail).
 */
export const PAYOUTS_ENDPOINTS = {
  list: '/api/payouts/',
  detail: (uuid: string) => `/api/payouts/${uuid}/`,
} as const;

/**
 * Notifications – admin can view and mark as read.
 */
export const NOTIFICATIONS_ENDPOINTS = {
  list: '/api/notifications/',
  markRead: '/api/notifications/mark-read/',
} as const;

/**
 * Audit Log – admin can view logs.
 */
export const AUDIT_ENDPOINTS = {
  list: '/api/audit/',
  detail: (uuid: string) => `/api/audit/${uuid}/`,
} as const;

/**
 * Analytics – admin dashboard metrics.
 */
export const ANALYTICS_ENDPOINTS = {
  metrics: '/api/analytics/metrics/',
} as const;

