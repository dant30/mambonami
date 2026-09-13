import { useEffect, useState } from 'react'

import { getFarmerPayoutSummary, listFarmerPayouts } from '../../services'
import { farmerStore } from '../../stores'
import type { Payout, PayoutSummary } from '../../types'

export function useFarmerEarnings(enabled = true) {
	const [payouts, setPayouts] = useState<Payout[]>(farmerStore.getPayouts())
	const [summary, setSummary] = useState<PayoutSummary | null>(farmerStore.getPayoutSummary())
	const [isLoading, setIsLoading] = useState(enabled && farmerStore.getPayoutSummary() === null)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		Promise.all([listFarmerPayouts(), getFarmerPayoutSummary()]).then(([nextPayouts, nextSummary]) => {
			if (!active) return
			farmerStore.setPayouts(nextPayouts)
			farmerStore.setPayoutSummary(nextSummary)
			setPayouts(nextPayouts)
			setSummary(nextSummary)
		}).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { payouts, summary, isLoading, error }
}
