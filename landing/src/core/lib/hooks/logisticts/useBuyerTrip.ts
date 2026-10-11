import { useEffect, useState } from 'react'

import { getBuyerTripForOrder } from '../../services'
import type { Trip } from '../../types'

export function useBuyerTrip(orderUuid: string, enabled = true) {
	const [trip, setTrip] = useState<Trip | null>(null)
	const [isLoading, setIsLoading] = useState(Boolean(orderUuid) && enabled)
	const [error, setError] = useState<unknown>(null)
	const [reloadKey, setReloadKey] = useState(0)
	const refresh = () => setReloadKey((key) => key + 1)

	useEffect(() => {
		if (!orderUuid || !enabled) {
			setTrip(null)
			setIsLoading(false)
			return
		}

		let active = true
		setIsLoading(true)
		setError(null)

		getBuyerTripForOrder(orderUuid)
			.then((nextTrip) => {
				if (!active) return
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
	}, [enabled, orderUuid, reloadKey])

	return { trip, isLoading, error, refresh }
}
