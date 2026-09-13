import { useEffect, useState } from 'react'

import { getRetailerOrder, listRetailerOrders } from '../../services'
import { retailerStore } from '../../stores'
import type { Order } from '../../types'

export function useRetailerOrders(enabled = true) {
	const cached = retailerStore.getOrders()
	const [orders, setOrders] = useState<Order[]>(cached)
	const [isLoading, setIsLoading] = useState(enabled && cached.length === 0)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		listRetailerOrders().then((next) => { if (active) { retailerStore.setOrders(next); setOrders(next) } }).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { orders, isLoading, error, isEmpty: !isLoading && orders.length === 0 }
}

export function useRetailerOrder(uuid: string, enabled = true) {
	const [order, setOrder] = useState<Order | null>(null)
	const [isLoading, setIsLoading] = useState(Boolean(uuid) && enabled)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled || !uuid) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		getRetailerOrder(uuid).then((next) => { if (active) setOrder(next) }).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled, uuid])
	return { order, isLoading, error }
}
