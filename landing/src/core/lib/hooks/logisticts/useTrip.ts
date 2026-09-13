import { useEffect, useState } from 'react'

import { getTrip } from '../../services'
import { logisticsStore } from '../../stores'
import type { Trip } from '../../types'

export function useTrip(uuid: string) {
	const [trip, setTrip] = useState<Trip | null>(() => logisticsStore.getCurrentTrip())
	const [isLoading, setIsLoading] = useState(Boolean(uuid) && logisticsStore.getCurrentTrip() === null)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		if (!uuid) {
			setTrip(null)
			setIsLoading(false)
			return
		}

		let active = true
		setIsLoading(true)
		setError(null)

		getTrip(uuid)
			.then((nextTrip) => {
				if (!active) return
				logisticsStore.setCurrentTrip(nextTrip)
				setTrip(nextTrip)
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
	}, [uuid])

	return { trip, isLoading, error }
}
