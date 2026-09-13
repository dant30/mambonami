import { useEffect, useState } from 'react'

import { listDisputes } from '../../services'
import { disputeStore } from '../../stores'
import type { Dispute } from '../../types'

export function useDisputes() {
	const cachedDisputes = disputeStore.getDisputes()
	const [disputes, setDisputes] = useState<Dispute[]>(cachedDisputes)
	const [isLoading, setIsLoading] = useState(cachedDisputes.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		setError(null)

		listDisputes()
			.then((nextDisputes) => {
				if (!active) return
				disputeStore.setDisputes(nextDisputes)
				setDisputes(nextDisputes)
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

	return { disputes, isLoading, error, isEmpty: !isLoading && disputes.length === 0 }
}
