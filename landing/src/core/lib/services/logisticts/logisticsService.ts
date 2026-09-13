import { apiClient } from '../../../api'
import { LOGISTICS_ENDPOINTS } from '../../../api/endpoints'
import type {
	Trip,
	TripListResponse,
	TripLocationPayload,
	TripMedia,
	TripMediaUploadPayload,
	TripOtpResponse,
	TripOtpVerificationInput,
	TripOtpVerificationResponse,
	TripStatusUpdateResponse,
} from '../../types'

function normalizeTrips(response: TripListResponse | Trip[]): Trip[] {
	return Array.isArray(response) ? response : response.results ?? []
}

function buildTripMediaFormData(payload: TripMediaUploadPayload): FormData {
	const formData = new FormData()

	Object.entries(payload).forEach(([key, value]) => {
		if (value === undefined || value === null || value === '') {
			return
		}

		if (value instanceof File || value instanceof Blob) {
			formData.append(key, value)
			return
		}

		formData.append(key, String(value))
	})

	return formData
}

export async function listAvailableOrders(): Promise<Trip[]> {
	const response = await apiClient.get<TripListResponse | Trip[]>(LOGISTICS_ENDPOINTS.availableOrders)
	return normalizeTrips(response)
}

export async function listMyTrips(): Promise<Trip[]> {
	const response = await apiClient.get<TripListResponse | Trip[]>(LOGISTICS_ENDPOINTS.myTrips)
	return normalizeTrips(response)
}

export async function getTrip(uuid: string): Promise<Trip> {
	return apiClient.get<Trip>(LOGISTICS_ENDPOINTS.trip(uuid))
}

export async function assignTripToMe(uuid: string): Promise<Trip> {
	return apiClient.post<Trip>(LOGISTICS_ENDPOINTS.assign(uuid))
}

export async function declineTrip(uuid: string, reason = 'Declined by transport provider'): Promise<{ message: string }> {
	return apiClient.post<{ message: string }>(LOGISTICS_ENDPOINTS.decline(uuid), { reason })
}

export async function startPickupNavigation(uuid: string): Promise<TripStatusUpdateResponse> {
	return apiClient.post<TripStatusUpdateResponse>(LOGISTICS_ENDPOINTS.startPickupNavigation(uuid))
}

export async function arrivePickup(uuid: string, payload: Partial<TripLocationPayload> = {}): Promise<TripStatusUpdateResponse> {
	return apiClient.post<TripStatusUpdateResponse>(LOGISTICS_ENDPOINTS.arrivePickup(uuid), payload)
}

export async function recordPickup(uuid: string, payload: Partial<TripLocationPayload> = {}): Promise<TripStatusUpdateResponse> {
	return apiClient.post<TripStatusUpdateResponse>(LOGISTICS_ENDPOINTS.pickup(uuid), payload)
}

export async function startDeliveryNavigation(uuid: string): Promise<TripStatusUpdateResponse> {
	return apiClient.post<TripStatusUpdateResponse>(LOGISTICS_ENDPOINTS.startDeliveryNavigation(uuid))
}

export async function arriveDelivery(uuid: string, payload: Partial<TripLocationPayload> = {}): Promise<TripStatusUpdateResponse> {
	return apiClient.post<TripStatusUpdateResponse>(LOGISTICS_ENDPOINTS.arriveDelivery(uuid), payload)
}

export async function generateTripOtp(uuid: string): Promise<TripOtpResponse> {
	return apiClient.post<TripOtpResponse>(LOGISTICS_ENDPOINTS.generateOtp(uuid))
}

export async function verifyTripOtp(uuid: string, input: TripOtpVerificationInput): Promise<TripOtpVerificationResponse> {
	const body = new FormData()
	body.append('otp', input.otp)
	body.append('delivery_photo', input.delivery_photo)
	if (input.delivery_lat !== undefined) body.append('delivery_lat', String(input.delivery_lat))
	if (input.delivery_lng !== undefined) body.append('delivery_lng', String(input.delivery_lng))
	return apiClient.post<TripOtpVerificationResponse>(LOGISTICS_ENDPOINTS.verifyOtp(uuid), body)
}

export async function updateTripLocation(uuid: string, payload: TripLocationPayload): Promise<{ message: string; eta_minutes?: number | null }> {
	return apiClient.post<{ message: string; eta_minutes?: number | null }>(LOGISTICS_ENDPOINTS.location(uuid), payload)
}

export async function uploadTripMedia(uuid: string, payload: TripMediaUploadPayload): Promise<TripMedia> {
	return apiClient.post<TripMedia>(LOGISTICS_ENDPOINTS.media(uuid), buildTripMediaFormData(payload))
}

export async function getBuyerTrip(uuid: string): Promise<Trip> {
	return apiClient.get<Trip>(LOGISTICS_ENDPOINTS.buyerTrip(uuid))
}

export async function listAdminTrips(): Promise<Trip[]> {
	const response = await apiClient.get<TripListResponse | Trip[]>(LOGISTICS_ENDPOINTS.adminTrips)
	return normalizeTrips(response)
}

export async function getAdminTrip(uuid: string): Promise<Trip> {
	return apiClient.get<Trip>(LOGISTICS_ENDPOINTS.adminTrip(uuid))
}

export async function cancelAdminTrip(uuid: string, reason = 'Cancelled by admin'): Promise<TripStatusUpdateResponse> {
	return apiClient.post<TripStatusUpdateResponse>(LOGISTICS_ENDPOINTS.cancelAdminTrip(uuid), { reason })
}
