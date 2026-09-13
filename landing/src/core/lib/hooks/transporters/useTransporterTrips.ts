import { useEffect, useState } from 'react'

import { getTransportTrip, listTransportTrips } from '../../services'
import { transporterStore } from '../../stores'
import type { Trip } from '../../types'

export function useTransporterTrips(enabled = true) {
	const cached = transporterStore.getTrips()
	const [trips, setTrips] = useState<Trip[]>(cached)
	const [isLoading, setIsLoading] = useState(enabled && cached.length === 0)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		listTransportTrips().then((next) => { if (active) { transporterStore.setTrips(next); setTrips(next) } }).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { trips, isLoading, error, isEmpty: !isLoading && trips.length === 0 }
}

export function useTransporterTrip(uuid: string, enabled = true) {
	const [trip, setTrip] = useState<Trip | null>(transporterStore.getCurrentTrip())
	const [isLoading, setIsLoading] = useState(Boolean(uuid) && enabled)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled || !uuid) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		getTransportTrip(uuid).then((next) => { if (active) { transporterStore.setCurrentTrip(next); setTrip(next) } }).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled, uuid])
	return { trip, isLoading, error }
}
