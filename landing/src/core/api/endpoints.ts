import { apiClient } from './apiClient';

export const API_BASE = (import.meta.env.VITE_API_URL?.trim() || '').replace(/\/$/, '');

export const AUTH_ENDPOINTS = {
	registrationStart: '/api/users/registration/start/',
	registrationVerify: '/api/users/registration/verify/',
	registrationResend: '/api/users/registration/resend/',
	registerInit: '/api/users/register/init/',
	registerVerify: '/api/users/register/verify/',
	login: '/api/users/login/',
	logout: '/api/users/logout/',
	passwordResetInit: '/api/users/password-reset/init/',
	passwordResetVerify: '/api/users/password-reset/verify/',
	passwordResetVerifyCode: '/api/users/password-reset/verify-code/',
	passwordChange: '/api/users/password-change/',
	tokenRefresh: '/api/token/refresh/',
	tokenVerify: '/api/token/verify/',
	profile: '/api/users/profile/',
	avatar: '/api/users/profile/avatar/',
	trustScore: '/api/users/verification/trust-score/',
} as const;

export const USER_ENDPOINTS = {
	verificationDocuments: '/api/users/verification/documents/',
	verificationDocument: (uuid: string) => `/api/users/verification/documents/${uuid}/`,
	reviewVerificationDocument: (uuid: string) => `/api/users/verification/documents/${uuid}/review/`,
	trustScore: (uuid: string) => `/api/users/verification/trust-score/${uuid}/`,
} as const;

export const PRODUCT_ENDPOINTS = {
	list: '/api/products/',
	detail: (uuid: string) => `/api/products/${uuid}/`,
	reviews: (uuid: string) => `/api/products/${uuid}/reviews/`,
	categories: '/api/products/categories/',
	units: '/api/products/units/',
	wishlist: '/api/products/wishlist/',
	wishlistItem: (uuid: string) => `/api/products/wishlist/${uuid}/`,
	farmerProducts: '/api/products/farmer/products/',
	farmerProduct: (uuid: string) => `/api/products/farmer/products/${uuid}/`,
} as const;

export const ORDER_ENDPOINTS = {
	list: '/api/orders/',
	create: '/api/orders/create/',
	active: '/api/orders/active/',
	detail: (uuid: string) => `/api/orders/${uuid}/`,
	suborders: '/api/orders/suborders/',
	suborder: (id: string | number) => `/api/orders/suborders/${id}/`,
	confirmSuborder: (id: string | number) => `/api/orders/suborders/${id}/confirm/`,
	readySuborder: (id: string | number) => `/api/orders/suborders/${id}/ready/`,
	generateOtp: (uuid: string) => `/api/orders/${uuid}/generate-otp/`,
	verifyOtp: (uuid: string) => `/api/orders/${uuid}/verify-otp/`,
} as const;

export const LOGISTICS_ENDPOINTS = {
	availableOrders: '/api/logistics/orders/available/',
	myTrips: '/api/logistics/my-trips/',
	trip: (uuid: string) => `/api/logistics/my-trips/${uuid}/`,
	assign: (uuid: string) => `/api/logistics/trips/${uuid}/assign/`,
	decline: (uuid: string) => `/api/logistics/trips/${uuid}/decline/`,
	startPickupNavigation: (uuid: string) => `/api/logistics/trips/${uuid}/start-pickup-nav/`,
	arrivePickup: (uuid: string) => `/api/logistics/trips/${uuid}/arrive-pickup/`,
	pickup: (uuid: string) => `/api/logistics/trips/${uuid}/pickup/`,
	startDeliveryNavigation: (uuid: string) => `/api/logistics/trips/${uuid}/start-delivery-nav/`,
	arriveDelivery: (uuid: string) => `/api/logistics/trips/${uuid}/arrive-delivery/`,
	generateOtp: (uuid: string) => `/api/logistics/trips/${uuid}/generate-otp/`,
	location: (uuid: string) => `/api/logistics/my-trips/${uuid}/location/`,
	media: (uuid: string) => `/api/logistics/my-trips/${uuid}/media/`,
	verifyOtp: (uuid: string) => `/api/logistics/trips/${uuid}/verify-otp/`,
	buyerTrip: (uuid: string) => `/api/logistics/buyer/trips/${uuid}/`,
	adminTrips: '/api/logistics/admin/trips/',
	adminTrip: (uuid: string) => `/api/logistics/admin/trips/${uuid}/`,
	cancelAdminTrip: (uuid: string) => `/api/logistics/admin/trips/${uuid}/cancel/`,
} as const;

export const NOTIFICATION_ENDPOINTS = {
	list: '/api/notifications/',
	markRead: '/api/notifications/mark-read/',
	preferences: '/api/notifications/preferences/',
	preference: (id: string | number) => `/api/notifications/preferences/${id}/`,
} as const;

export const PAYBILL_ENDPOINTS = {
	stkPush: '/api/paybill/stk-push/',
	simulate: '/api/paybill/simulate/',
	transactions: '/api/paybill/transactions/',
	settlements: '/api/paybill/settlements/',
	floatBalance: '/api/paybill/float-balance/',
} as const;

export const PAYOUT_ENDPOINTS = {
	list: '/api/payouts/',
	summary: '/api/payouts/summary/',
	detail: (uuid: string) => `/api/payouts/${uuid}/`,
} as const;

export const DISPUTE_ENDPOINTS = {
	list: '/api/disputes/',
	create: '/api/disputes/create/',
	detail: (uuid: string) => `/api/disputes/${uuid}/`,
	resolve: (uuid: string) => `/api/disputes/${uuid}/resolve/`,
} as const;

export const ANALYTICS_ENDPOINTS = {
	metrics: '/api/analytics/metrics/',
	metric: (id: string | number) => `/api/analytics/metrics/${id}/`,
	recomputeMetrics: '/api/analytics/metrics/recompute/',
	metricsSummary: '/api/analytics/metrics/summary/',
	paymentMetrics: '/api/analytics/metrics/payments/',
	topFarmers: '/api/analytics/metrics/top-farmers/',
	topTransport: '/api/analytics/metrics/top-transport/',
	exports: '/api/analytics/exports/',
	export: (uuid: string) => `/api/analytics/exports/${uuid}/`,
} as const;

export const AUDIT_ENDPOINTS = {
	list: '/api/audit/',
	detail: (uuid: string) => `/api/audit/${uuid}/`,
} as const;

export const ADMIN_ENDPOINTS = {
	products: {
		list: '/api/products/admin/',
		status: (uuid: string) => `/api/products/admin/${uuid}/status/`,
	},
	orders: {
		list: '/admin-api/orders/',
		detail: (uuid: string) => `/admin-api/orders/${uuid}/`,
		status: (uuid: string) => `/admin-api/orders/${uuid}/status/`,
	},
	users: {
		list: '/admin-api/users/users/',
		detail: (id: string | number) => `/admin-api/users/users/${id}/`,
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
	userActions: {
		suspend: (id: string | number) => `/admin-api/users/users/${id}/suspend/`,
		activate: (id: string | number) => `/admin-api/users/users/${id}/activate/`,
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

export const endpoints = {
	products: {
		list: (params?: Record<string, string | number | boolean>) => apiClient.get(PRODUCT_ENDPOINTS.list, { params }),
		detail: (uuid: string) => apiClient.get(PRODUCT_ENDPOINTS.detail(uuid)),
	},
	orders: {
		list: () => apiClient.get(ORDER_ENDPOINTS.list),
		create: (body: unknown) => apiClient.post(ORDER_ENDPOINTS.create, body),
	},
} as const;

export const endpointsByResource = {
	users: USER_ENDPOINTS,
	products: PRODUCT_ENDPOINTS,
	orders: ORDER_ENDPOINTS,
	logistics: LOGISTICS_ENDPOINTS,
	notifications: NOTIFICATION_ENDPOINTS,
	paybill: PAYBILL_ENDPOINTS,
	payouts: PAYOUT_ENDPOINTS,
	disputes: DISPUTE_ENDPOINTS,
	analytics: ANALYTICS_ENDPOINTS,
	audit: AUDIT_ENDPOINTS,
	admin: ADMIN_ENDPOINTS,
} as const;
