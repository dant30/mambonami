import { useEffect, useState } from 'react'

import { listAvailableOrders } from '../../services'
import { logisticsStore } from '../../stores'
import type { Trip } from '../../types'

export function useAvailableOrders() {
	const cachedOrders = logisticsStore.getAvailableOrders()
	const [orders, setOrders] = useState<Trip[]>(cachedOrders)
	const [isLoading, setIsLoading] = useState(cachedOrders.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		setError(null)

		listAvailableOrders()
			.then((nextOrders) => {
				if (!active) return
				logisticsStore.setAvailableOrders(nextOrders)
				setOrders(nextOrders)
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

	return { orders, isLoading, error, isEmpty: !isLoading && orders.length === 0 }
}
