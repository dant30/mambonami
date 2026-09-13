import { useEffect, useState } from 'react'

import { getBuyerActiveOrder, getBuyerOrder, listBuyerOrders } from '../../services'
import { buyerStore } from '../../stores'
import type { Order } from '../../types'

export function useBuyerOrders(enabled = true) {
	const cached = buyerStore.getOrders()
	const [orders, setOrders] = useState<Order[]>(cached)
	const [isLoading, setIsLoading] = useState(enabled && cached.length === 0)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		listBuyerOrders().then((next) => { if (active) { buyerStore.setOrders(next); setOrders(next) } }).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { orders, isLoading, error, isEmpty: !isLoading && orders.length === 0 }
}

export function useBuyerActiveOrder(enabled = true) {
	const [order, setOrder] = useState<Order | null>(buyerStore.getActiveOrder())
	const [isLoading, setIsLoading] = useState(enabled)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		getBuyerActiveOrder().then((next) => { if (active) { buyerStore.setActiveOrder(next); setOrder(next) } }).catch((requestError: unknown) => { if (active) { setError(requestError); setOrder(null) } }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { order, isLoading, error }
}

export function useBuyerOrder(uuid: string, enabled = true) {
	const [order, setOrder] = useState<Order | null>(null)
	const [isLoading, setIsLoading] = useState(Boolean(uuid) && enabled)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled || !uuid) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		getBuyerOrder(uuid).then((next) => { if (active) setOrder(next) }).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled, uuid])
	return { order, isLoading, error }
}
