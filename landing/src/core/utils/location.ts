import { geocodeCache } from '../storage/geocodeCache'

export interface Coordinates {
	latitude: number
	longitude: number
	accuracy?: number
}

export interface GeocodeResult {
	displayName: string
	latitude: number
	longitude: number
}

export function getCurrentLocation(options: PositionOptions = {}): Promise<Coordinates> {
	if (typeof navigator === 'undefined' || !navigator.geolocation) return Promise.reject(new Error('Location access is not supported in this browser.'))
	return new Promise((resolve, reject) => {
		navigator.geolocation.getCurrentPosition(
			(position) => resolve({ latitude: position.coords.latitude, longitude: position.coords.longitude, accuracy: position.coords.accuracy }),
			(error) => reject(new Error(error.message || 'Unable to determine your location.')),
			{ enableHighAccuracy: true, timeout: 10000, maximumAge: 60000, ...options },
		)
	})
}

export async function reverseGeocode(coordinates: Pick<Coordinates, 'latitude' | 'longitude'>): Promise<GeocodeResult> {
	const cached = geocodeCache.get(coordinates.latitude, coordinates.longitude)
	if (cached) return cached
	const query = new URLSearchParams({ lat: String(coordinates.latitude), lon: String(coordinates.longitude), format: 'jsonv2' })
	const response = await fetch(`https://nominatim.openstreetmap.org/reverse?${query.toString()}`, { headers: { Accept: 'application/json' } })
	if (!response.ok) throw new Error('Unable to find an address for this location.')
	const data = await response.json() as { display_name?: string; lat?: string; lon?: string }
	const result: GeocodeResult = { displayName: data.display_name ?? 'Selected location', latitude: Number(data.lat ?? coordinates.latitude), longitude: Number(data.lon ?? coordinates.longitude) }
	geocodeCache.set(result)
	return result
}
