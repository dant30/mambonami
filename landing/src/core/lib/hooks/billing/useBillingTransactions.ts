import { useEffect, useState } from 'react'

import { listBillingTransactions } from '../../services'
import { billingStore } from '../../stores'
import type { BillingTransaction } from '../../types'

export function useBillingTransactions(enabled = true) {
	const cachedTransactions = billingStore.getTransactions()
	const [transactions, setTransactions] = useState<BillingTransaction[]>(cachedTransactions)
	const [isLoading, setIsLoading] = useState(enabled && cachedTransactions.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		if (!enabled) {
			setIsLoading(false)
			return
		}
		let active = true
		setIsLoading(true)
		setError(null)
		listBillingTransactions().then((next) => {
			if (!active) return
			billingStore.setTransactions(next)
			setTransactions(next)
		}).catch((requestError: unknown) => {
			if (active) setError(requestError)
		}).finally(() => {
			if (active) setIsLoading(false)
		})
		return () => { active = false }
	}, [enabled])

	return { transactions, isLoading, error, isEmpty: !isLoading && transactions.length === 0 }
}
