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

// Intersection of Kenya's extent and the backend limits (lat -12..5, lng 34..42) so accepted points never fail server validation.
const KENYA_BOUNDS = { minLat: -4.9, maxLat: 5.0, minLng: 34.0, maxLng: 41.95 }

export function roundCoordinate(value: number): number {
	return Math.round(value * 1e6) / 1e6
}

export function isWithinKenya({ latitude, longitude }: Pick<Coordinates, 'latitude' | 'longitude'>): boolean {
	return latitude >= KENYA_BOUNDS.minLat && latitude <= KENYA_BOUNDS.maxLat && longitude >= KENYA_BOUNDS.minLng && longitude <= KENYA_BOUNDS.maxLng
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
	const data = await response.json() as { display_name?: string }
	// Keyed by the requested point (not Nominatim's snapped one) so repeat lookups hit the cache.
	const result: GeocodeResult = { displayName: data.display_name ?? 'Selected location', latitude: coordinates.latitude, longitude: coordinates.longitude }
	geocodeCache.set(result)
	return result
}

export interface SearchPlacesOptions {
	countryCodes?: string
	limit?: number
	signal?: AbortSignal
}

/** Forward geocoding. Call on explicit submit only (Nominatim usage policy forbids autocomplete-style requests). */
export async function searchPlaces(query: string, { countryCodes = 'ke', limit = 6, signal }: SearchPlacesOptions = {}): Promise<GeocodeResult[]> {
	const trimmed = query.trim()
	if (trimmed.length < 3) return []
	const params = new URLSearchParams({ q: trimmed, format: 'jsonv2', limit: String(limit), addressdetails: '0' })
	if (countryCodes) params.set('countrycodes', countryCodes)
	const response = await fetch(`https://nominatim.openstreetmap.org/search?${params.toString()}`, { headers: { Accept: 'application/json' }, signal })
	if (!response.ok) throw new Error('Place search is temporarily unavailable.')
	const data = await response.json() as Array<{ display_name?: string; lat?: string; lon?: string }>
	return data
		.map((item) => ({ displayName: item.display_name ?? 'Unnamed place', latitude: Number(item.lat), longitude: Number(item.lon) }))
		.filter((item) => Number.isFinite(item.latitude) && Number.isFinite(item.longitude))
}
