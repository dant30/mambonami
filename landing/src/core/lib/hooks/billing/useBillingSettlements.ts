import { useEffect, useState } from 'react'

import { listBillingSettlements } from '../../services'
import { billingStore } from '../../stores'
import type { BillingSettlement } from '../../types'

export function useBillingSettlements(enabled = true) {
	const cachedSettlements = billingStore.getSettlements()
	const [settlements, setSettlements] = useState<BillingSettlement[]>(cachedSettlements)
	const [isLoading, setIsLoading] = useState(enabled && cachedSettlements.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		if (!enabled) {
			setIsLoading(false)
			return
		}
		let active = true
		setIsLoading(true)
		setError(null)
		listBillingSettlements().then((next) => {
			if (!active) return
			billingStore.setSettlements(next)
			setSettlements(next)
		}).catch((requestError: unknown) => {
			if (active) setError(requestError)
		}).finally(() => {
			if (active) setIsLoading(false)
		})
		return () => { active = false }
	}, [enabled])

	return { settlements, isLoading, error, isEmpty: !isLoading && settlements.length === 0 }
}
