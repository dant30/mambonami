import { useEffect, useState } from 'react'

import { listPayouts } from '../../services'
import { payoutStore } from '../../stores'
import type { Payout } from '../../types'

export function usePayouts() {
	const cachedPayouts = payoutStore.getPayouts()
	const [payouts, setPayouts] = useState<Payout[]>(cachedPayouts)
	const [isLoading, setIsLoading] = useState(cachedPayouts.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		setError(null)

		listPayouts()
			.then((nextPayouts) => {
				if (!active) return
				payoutStore.setPayouts(nextPayouts)
				setPayouts(nextPayouts)
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

	return { payouts, isLoading, error, isEmpty: !isLoading && payouts.length === 0 }
}
