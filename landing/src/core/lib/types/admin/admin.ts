import type { Dispute, DisputeResolutionInput } from '../disputes'
import type { Order, OrderStatus } from '../orders'
import type { Payout } from '../payouts'
import type { Product } from '../products'

export type AdminRole = 'buyer' | 'farmer' | 'retailer' | 'transport_provider' | 'admin'

export interface AdminUser {
	id: number
	phone: string
	username?: string
	first_name?: string
	middle_name?: string
	last_name?: string
	full_name?: string
	display_name?: string
	avatar_url?: string | null
	role: AdminRole | string
	email?: string
	is_active: boolean
	is_staff: boolean
	is_superuser: boolean
	is_phone_verified?: boolean
	is_email_verified?: boolean
	account_status?: string
	kyc_status?: string
	date_joined?: string
	last_seen?: string | null
}

export type AdminStaffInput = Pick<AdminUser, 'phone' | 'username'> & Partial<Pick<AdminUser, 'first_name' | 'middle_name' | 'last_name' | 'email'>> & { password?: string }

export interface AdminFarmer {
	id: number
	user: number
	user_phone?: string
	user_username?: string
	latitude?: string | number | null
	longitude?: string | number | null
	farm_gps?: string
	county?: string
	sub_county?: string
	ward?: string
	village?: string
	cooperative?: string
	coop_verified?: boolean
	total_sales?: string | number
	rating?: number
	rating_count?: number
	total_orders?: number
}

export interface AdminTransportProvider {
	id: number
	user: number
	user_phone?: string
	user_username?: string
	vehicle_type?: string
	capacity_kg?: number
	license_plate?: string
	driver_license?: string
	deposit_paid?: boolean
	is_approved?: boolean
	rating?: number
	total_deliveries?: number
	is_online?: boolean
	available?: boolean
}

export interface AdminAuditLog {
	id: number
	uuid: string
	action?: string
	actor?: number | null
	actor_phone?: string
	resource_type?: string
	resource_id?: string | number
	description?: string
	metadata?: Record<string, unknown>
	created_at?: string
}

export type AdminSecuritySeverity = 'low' | 'medium' | 'high' | 'critical'

export interface AdminSecurityEvent {
	id: number
	uuid: string
	event_type: string
	description: string
	severity: AdminSecuritySeverity
	user: number | null
	actor_phone?: string | null
	ip_address?: string | null
	request_id?: string
	investigated: boolean
	investigation_notes: string
	resolved_at?: string | null
	created_at: string
}

export interface AdminSecurityEventUpdate {
	investigated: boolean
	investigation_notes: string
	resolved_at?: string | null
}

export interface AdminDashboardData {
	orders: Order[]
	users: AdminUser[]
	farmers: AdminFarmer[]
	transportProviders: AdminTransportProvider[]
	disputes: Dispute[]
	payouts: Payout[]
	auditLogs: AdminAuditLog[]
	metrics: AdminDailyMetric[]
}

export type AdminProduct = Product

export interface AdminDailyMetric {
	id: number
	uuid?: string
	date: string
	total_orders: number
	completed_orders: number
	cancelled_orders: number
	disputed_orders: number
	total_sales: string | number
	platform_commission: string | number
	total_paid_to_farmers: string | number
	total_paid_to_transport: string | number
	total_collections_amount: string | number
	collections_count: number
	orphaned_collections: number
	total_payouts_amount: string | number
	payouts_count: number
	failed_payouts: number
}

export interface AdminAnalyticsSummary {
	start_date?: string
	end_date?: string
	total_orders?: number
	completed_orders?: number
	total_sales?: string | number
	platform_commission?: string | number
	total_paid_to_farmers?: string | number
	total_paid_to_transport?: string | number
}

export interface AdminResourceCache<T> {
	get: () => T | null | undefined
	set: (value: T) => void
}

export interface AdminOrderStatusUpdate {
	status: OrderStatus
}

export type AdminDisputeResolution = DisputeResolutionInput
