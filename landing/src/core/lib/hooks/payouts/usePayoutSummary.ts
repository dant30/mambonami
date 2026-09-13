import { useEffect, useState } from 'react'

import { getPayoutSummary } from '../../services'
import { payoutStore } from '../../stores'
import type { PayoutSummary } from '../../types'

export function usePayoutSummary() {
	const cachedSummary = payoutStore.getSummary()
	const [summary, setSummary] = useState<PayoutSummary | null>(cachedSummary)
	const [isLoading, setIsLoading] = useState(cachedSummary === null)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		setError(null)

		getPayoutSummary()
			.then((nextSummary) => {
				if (!active) return
				payoutStore.setSummary(nextSummary)
				setSummary(nextSummary)
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

	return { summary, isLoading, error }
}
