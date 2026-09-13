import { useEffect, useState } from 'react'

import { listMyTrips } from '../../services'
import { logisticsStore } from '../../stores'
import type { Trip } from '../../types'

export function useMyTrips() {
	const cachedTrips = logisticsStore.getMyTrips()
	const [trips, setTrips] = useState<Trip[]>(cachedTrips)
	const [isLoading, setIsLoading] = useState(cachedTrips.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		setError(null)

		listMyTrips()
			.then((nextTrips) => {
				if (!active) return
				logisticsStore.setMyTrips(nextTrips)
				setTrips(nextTrips)
			})
			.catch((requestError: unknown) => {
				if (active) setError(requestError)
			})
			.finally(() => {
				if (active) setIsLoading(false)
			})

		return () => {
			active = false
		}
	}, [])

	return { trips, isLoading, error, isEmpty: !isLoading && trips.length === 0 }
}
