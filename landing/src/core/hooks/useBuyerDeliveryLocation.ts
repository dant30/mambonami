import { useEffect, useState } from 'react'

import { localStorageStore } from '../storage'
import { getCurrentLocation, isWithinKenya } from '../utils/location'
import type { Coordinates } from '../utils/location'

const STORAGE_KEY = 'buyer_delivery_location'
const LOCATION_CHANGED_EVENT = 'mambonami:buyer-delivery-location-changed'

function readStoredLocation(): Coordinates | null {
	const stored = localStorageStore.get<Partial<Coordinates>>(STORAGE_KEY)
	if (typeof stored?.latitude !== 'number' || typeof stored.longitude !== 'number') return null
	if (!Number.isFinite(stored.latitude) || !Number.isFinite(stored.longitude)) return null
	const coordinates = { latitude: stored.latitude, longitude: stored.longitude }
	return isWithinKenya(coordinates) ? coordinates : null
}

export function useBuyerDeliveryLocation() {
	const [location, setLocationState] = useState<Coordinates | null>(readStoredLocation)
	const [isLocating, setIsLocating] = useState(false)
	const [error, setError] = useState('')

	useEffect(() => {
		const syncLocation = () => setLocationState(readStoredLocation())
		window.addEventListener(LOCATION_CHANGED_EVENT, syncLocation)
		window.addEventListener('storage', syncLocation)
		return () => {
			window.removeEventListener(LOCATION_CHANGED_EVENT, syncLocation)
			window.removeEventListener('storage', syncLocation)
		}
	}, [])

	const setLocation = (nextLocation: Coordinates | null) => {
		setError('')
		setLocationState(nextLocation)
		if (nextLocation) {
			localStorageStore.set(STORAGE_KEY, {
				latitude: nextLocation.latitude,
				longitude: nextLocation.longitude,
			})
		} else {
			localStorageStore.remove(STORAGE_KEY)
		}
		window.dispatchEvent(new Event(LOCATION_CHANGED_EVENT))
	}

	const requestCurrentLocation = async () => {
		setIsLocating(true)
		setError('')
		try {
			const currentLocation = await getCurrentLocation()
			if (!isWithinKenya(currentLocation)) throw new Error('Choose a delivery location within Kenya.')
			setLocation(currentLocation)
		} catch (locationError) {
			setError(locationError instanceof Error ? locationError.message : 'Unable to determine your location.')
		} finally {
			setIsLocating(false)
		}
	}

	return { location, setLocation, requestCurrentLocation, isLocating, error }
}