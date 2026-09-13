import { localStorageStore } from './localStorage'

export interface CachedGeocode {
	displayName: string
	latitude: number
	longitude: number
	cachedAt: number
}

const KEY = 'mambonami_geocode_cache'
const TTL_MS = 1000 * 60 * 60 * 24 * 30
const PRECISION = 4

function cacheKey(latitude: number, longitude: number): string {
	return `${latitude.toFixed(PRECISION)},${longitude.toFixed(PRECISION)}`
}

function readCache(): Record<string, CachedGeocode> {
	return localStorageStore.get<Record<string, CachedGeocode>>(KEY) ?? {}
}

export const geocodeCache = {
	get(latitude: number, longitude: number): CachedGeocode | null {
		const entry = readCache()[cacheKey(latitude, longitude)]
		if (!entry || Date.now() - entry.cachedAt > TTL_MS) return null
		return entry
	},
	set(value: Omit<CachedGeocode, 'cachedAt'>): void {
		const cache = readCache()
		cache[cacheKey(value.latitude, value.longitude)] = { ...value, cachedAt: Date.now() }
		localStorageStore.set(KEY, cache)
	},
	clear(): void {
		localStorageStore.remove(KEY)
	},
}
