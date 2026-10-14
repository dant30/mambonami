export type AuthRole = 'buyer' | 'farmer' | 'retailer' | 'transport_provider'

export interface AuthUser {
	id?: string | number
	phone?: string
	username?: string
	email?: string
	first_name?: string
	last_name?: string
	middle_name?: string
	role?: AuthRole
	avatar_url?: string | null
	is_phone_verified?: boolean
	is_email_verified?: boolean
	is_active?: boolean
	account_status?: string
	kyc_status?: string
	national_id?: string
	date_joined?: string
	last_seen?: string
	is_staff?: boolean
	is_superuser?: boolean
	[key: string]: unknown
}

export interface TransportProfile {
	vehicle_type?: string
	capacity_kg?: number
	license_plate?: string
	driver_license?: string
	is_online?: boolean
	available?: boolean
	is_approved?: boolean
	deposit_paid?: boolean
	deposit_amount?: number
	deposit_account_number?: string
	deposit_transaction_id?: string
	paybill_number?: string
	rating?: number
	total_deliveries?: number
	base_rate_per_km?: number
	waiting_grace_minutes?: number
	waiting_rate_per_min?: number
	bank_account?: string
}

export interface AuthTokens {
	access: string
	refresh?: string
}

export interface LoginInput {
	phone: string
	password: string
}

export interface RegisterInitInput {
	phone: string
	role: AuthRole
}

export interface RegisterInput extends RegisterInitInput {
	otp: string
	username: string
	password: string
	confirm_password: string
	full_name?: string
	email?: string
	delivery_address?: string
	latitude?: number
	longitude?: number
	mpesa_number?: string
	vehicle_type?: string
	license_plate?: string
	business_name?: string
	owner_full_name?: string
	business_phone?: string
	business_email?: string
	business_address?: string
	business_type?: string
	national_id?: string
	bank_account?: string
}

export interface AuthResponse {
	user: AuthUser
	tokens?: AuthTokens
}

export interface PasswordResetInput {
	phone: string
	otp: string
	new_password: string
	confirm_password: string
}

export interface RegistrationStartResponse {
	registration_id: string
	phone: string
	role: AuthRole
	expires_in: number
	otp_sent: boolean
}

export interface RegistrationVerifyInput {
	registration_id: string
	otp: string
}
