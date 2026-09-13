import { useEffect, useState } from 'react'

import { getOrder } from '../../services'
import type { Order } from '../../types'

export function useOrder(uuid: string) {
	const [order, setOrder] = useState<Order | null>(null)
	const [isLoading, setIsLoading] = useState(true)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		setError(null)
		getOrder(uuid).then((nextOrder) => {
			if (active) setOrder(nextOrder)
		}).catch((requestError: unknown) => {
			if (active) setError(requestError)
		}).finally(() => {
			if (active) setIsLoading(false)
		})
		return () => { active = false }
	}, [uuid])

	return { order, isLoading, error }
}
