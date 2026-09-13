import type { Order } from '../orders'

export type TripStatus =
	| 'created'
	| 'offered'
	| 'accepted'
	| 'en_route_pickup'
	| 'arrived_pickup'
	| 'picked_up'
	| 'en_route_delivery'
	| 'arrived_delivery'
	| 'otp_pending'
	| 'delivered'
	| 'cancelled'
	| 'failed'
	| 'disputed'

export interface TripProviderDetail {
	phone?: string | null
	vehicle_type?: string | null
	license_plate?: string | null
	rating?: number | null
	on_time_percentage?: number | null
	acceptance_rate?: number | null
	completion_rate?: number | null
}

export interface TripStatusHistory {
	status: TripStatus
	changed_at: string
	location_lat?: string | number | null
	location_lng?: string | number | null
	battery_level?: number | null
	speed_kmh?: string | number | null
	actor?: number | null
	actor_phone?: string | null
	source?: string | null
	note?: string | null
	ip_address?: string | null
}

export interface TripLocationPing {
	id: number
	latitude: string | number
	longitude: string | number
	heading?: number | null
	speed_kmh?: string | number | null
	accuracy_m?: number | null
	altitude_m?: number | null
	battery_level?: number | null
	timestamp?: string
}

export interface TripMedia {
	id: number
	media_type: string
	image_url?: string | null
	uploaded_by?: number | null
	uploaded_by_phone?: string | null
	uploaded_at?: string
	latitude?: string | number | null
	longitude?: string | number | null
	caption?: string | null
	is_verified?: boolean
}

export interface Trip {
	id: number
	uuid: string
	order: number | string
	order_detail?: Order
	order_id?: string
	provider?: number | null
	provider_detail?: TripProviderDetail | null
	status: TripStatus
	pickup_lat?: string | number | null
	pickup_lng?: string | number | null
	delivery_lat?: string | number | null
	delivery_lng?: string | number | null
	current_lat?: string | number | null
	current_lng?: string | number | null
	pickup_address?: string
	delivery_address?: string
	straight_line_km?: string | number | null
	road_km?: string | number | null
	eta_minutes?: number | null
	base_fee?: string | number
	distance_fee?: string | number
	weight_fee?: string | number
	waiting_fee?: string | number
	surge_fee?: string | number
	commission?: string | number
	provider_payout?: string | number
	platform_fee?: string | number
	buyer_total?: string | number
	agreed_fee?: string | number
	waiting_surcharge?: string | number
	vehicle_type?: string | null
	vehicle_plate?: string | null
	vehicle_make?: string | null
	vehicle_model?: string | null
	created_at_trip?: string | null
	offered_at?: string | null
	accepted_at?: string | null
	started_navigation_pickup?: string | null
	arrived_pickup_at?: string | null
	picked_up_at?: string | null
	left_pickup_at?: string | null
	started_navigation_delivery?: string | null
	arrived_delivery_at?: string | null
	otp_verified_at?: string | null
	completed_at?: string | null
	cancelled_at?: string | null
	failed_at?: string | null
	assigned_by?: number | null
	accepted_device?: string
	completed_device?: string
	ip_address?: string | null
	cancel_reason?: string
	cancelled_by?: number | null
	failure_reason?: string
	delivery_notes?: string
	buyer_signature?: string | null
	buyer_rating?: number | null
	provider_rating?: number | null
	driver_name?: string | null
	driver_phone?: string | null
	driver_avatar_url?: string | null
	driver_rating?: number | null
	vehicle_label?: string | null
	delivery_location?: string | null
	otp_hash?: string | null
	otp_expires_at?: string | null
	otp_attempts?: number
	status_history?: TripStatusHistory[]
	location_pings?: TripLocationPing[]
	media?: TripMedia[]
	total_duration_minutes?: number | null
	pickup_delay_minutes?: number | null
	driving_time_minutes?: number | null
	created_at?: string
	updated_at?: string
}

export interface TripListResponse {
	count?: number
	next?: string | null
	previous?: string | null
	results?: Trip[]
	[key: string]: unknown
}

export interface TripLocationPayload {
	latitude: string | number
	longitude: string | number
	heading?: number | null
	speed_kmh?: string | number | null
	accuracy_m?: number | null
	altitude_m?: number | null
	battery_level?: number | null
}

export interface TripMediaUploadPayload {
	media_type: string
	image: File | string
	latitude?: string | number | null
	longitude?: string | number | null
	caption?: string
}

export interface TripOtpResponse {
	otp?: string
	expires_in?: number
	message?: string
	status?: TripStatus
}

export interface TripOtpVerificationResponse {
	message?: string
	status?: TripStatus
	error?: string
	attempts_remaining?: number
}

export interface TripOtpVerificationInput {
	otp: string
	delivery_photo: File
	delivery_lat?: string | number
	delivery_lng?: string | number
}

export interface TripStatusUpdateResponse {
	message?: string
	status?: TripStatus
	arrived_at?: string | null
	eta_minutes?: number | null
	waiting_surcharge?: string | number | null
	total_fee?: string | number | null
}
