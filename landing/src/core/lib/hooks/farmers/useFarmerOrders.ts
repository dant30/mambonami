import { useCallback, useEffect, useState } from 'react'

import { listFarmerOrders, listFarmerSubOrdersForWorkspace } from '../../services'
import { farmerStore } from '../../stores'
import type { FarmerOrder, Order } from '../../types'

export function useFarmerOrders(enabled = true) {
	const cached = farmerStore.getOrders()
	const [orders, setOrders] = useState<Order[]>(cached)
	const [isLoading, setIsLoading] = useState(enabled && cached.length === 0)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		listFarmerOrders().then((next) => { if (active) { farmerStore.setOrders(next); setOrders(next) } }).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { orders, isLoading, error, isEmpty: !isLoading && orders.length === 0 }
}

export function useFarmerSubOrders(enabled = true) {
	const cached = farmerStore.getSubOrders()
	const [subOrders, setSubOrders] = useState<FarmerOrder[]>(cached)
	const [isLoading, setIsLoading] = useState(enabled && cached.length === 0)
	const [error, setError] = useState<unknown>(null)
	const [reloadToken, setReloadToken] = useState(0)
	const refresh = useCallback(() => setReloadToken((token) => token + 1), [])
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		listFarmerSubOrdersForWorkspace().then((next) => { if (active) { farmerStore.setSubOrders(next); setSubOrders(next) } }).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled, reloadToken])
	return { subOrders, isLoading, error, isEmpty: !isLoading && subOrders.length === 0, refresh }
}
