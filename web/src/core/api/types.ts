// web/src/core/api/types.ts
export type {
	ApiResponse,
	PaginatedResponse,
	ApiErrorResponse,
	AsyncState,
	ListResponse,
} from '../types';

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
