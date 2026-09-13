import { useEffect, useState } from 'react'

import { listAdminOrders } from '../../services'
import { adminOrderStore } from '../../stores'
import type { Order } from '../../types'

export function useAdminOrders(): {
	orders: Order[]
	isLoading: boolean
	hasError: boolean
} {
	const cachedOrders = adminOrderStore.getOrders()
	const [orders, setOrders] = useState<Order[]>(cachedOrders)
	const [isLoading, setIsLoading] = useState(cachedOrders.length === 0)
	const [error, setError] = useState<string | null>(null)

	useEffect(() => {
		let active = true
		listAdminOrders().then((nextOrders) => {
			if (!active) return
			adminOrderStore.setOrders(nextOrders)
			setOrders(nextOrders)
		}).catch((requestError: unknown) => {
			if (active) setError(requestError instanceof Error ? requestError.message : 'Unable to load admin orders.')
		}).finally(() => {
			if (active) setIsLoading(false)
		})
		return () => { active = false }
	}, [])

	return { orders, isLoading, hasError: error !== null }
}