import { useEffect, useState } from 'react'

import { listOrders } from '../../services'
import { orderStore } from '../../stores'
import type { Order } from '../../types'

export function useOrders(): {
	orders: Order[]
	isLoading: boolean
	error: string | null
	isEmpty: boolean
} {
	const cachedOrders = orderStore.getOrders()
	const [orders, setOrders] = useState<Order[]>(cachedOrders)
	const [isLoading, setIsLoading] = useState(cachedOrders.length === 0)
	const [error, setError] = useState<string | null>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		listOrders().then((nextOrders) => {
			if (!active) return
			orderStore.setOrders(nextOrders)
			setOrders(nextOrders)
		}).catch((requestError: unknown) => {
			if (active) setError(requestError instanceof Error ? requestError.message : 'Unable to load orders.')
		}).finally(() => {
			if (active) setIsLoading(false)
		})
		return () => { active = false }
	}, [])

	return { orders, isLoading, error, isEmpty: !isLoading && orders.length === 0 }
}