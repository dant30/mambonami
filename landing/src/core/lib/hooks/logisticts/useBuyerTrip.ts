import { useEffect, useState } from 'react'

import { getBuyerTrip } from '../../services'
import { logisticsStore } from '../../stores'
import type { Trip } from '../../types'

export function useBuyerTrip(uuid: string) {
	const [trip, setTrip] = useState<Trip | null>(() => logisticsStore.getBuyerTrip())
	const [isLoading, setIsLoading] = useState(Boolean(uuid) && logisticsStore.getBuyerTrip() === null)
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

		getBuyerTrip(uuid)
			.then((nextTrip) => {
				if (!active) return
				logisticsStore.setBuyerTrip(nextTrip)
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
