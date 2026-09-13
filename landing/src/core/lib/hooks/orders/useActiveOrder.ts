import { useEffect, useState } from 'react'

import { getActiveOrder } from '../../services'
import { orderStore } from '../../stores'
import type { Order } from '../../types'

export function useActiveOrder() {
	const [order, setOrder] = useState<Order | null>(() => orderStore.getActiveOrder())
	const [isLoading, setIsLoading] = useState(true)

	useEffect(() => {
		let active = true
		getActiveOrder().then((nextOrder) => {
			if (!active) return
			orderStore.setActiveOrder(nextOrder)
			setOrder(nextOrder)
		}).catch(() => {
			if (active) {
				orderStore.setActiveOrder(null)
				setOrder(null)
			}
		}).finally(() => {
			if (active) setIsLoading(false)
		})
		return () => { active = false }
	}, [])

	return { order, isLoading }
}