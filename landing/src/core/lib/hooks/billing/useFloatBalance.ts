import { useEffect, useState } from 'react'

import { getFloatBalance } from '../../services'
import { billingStore } from '../../stores'
import type { FloatBalance } from '../../types'

export function useFloatBalance(enabled = true) {
	const cachedBalance = billingStore.getFloatBalance()
	const [balance, setBalance] = useState<FloatBalance | null>(cachedBalance)
	const [isLoading, setIsLoading] = useState(enabled && cachedBalance === null)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		if (!enabled) {
			setIsLoading(false)
			return
		}
		let active = true
		setIsLoading(true)
		setError(null)
		getFloatBalance().then((next) => {
			if (!active) return
			billingStore.setFloatBalance(next)
			setBalance(next)
		}).catch((requestError: unknown) => {
			if (active) setError(requestError)
		}).finally(() => {
			if (active) setIsLoading(false)
		})
		return () => { active = false }
	}, [enabled])

	return { balance, isLoading, error }
}
