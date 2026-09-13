import { useEffect, useState } from 'react'

import { getTransportPayoutSummary, listTransportPayouts } from '../../services'
import { transporterStore } from '../../stores'
import type { Payout, PayoutSummary } from '../../types'

export function useTransporterEarnings(enabled = true) {
	const [payouts, setPayouts] = useState<Payout[]>(transporterStore.getPayouts())
	const [summary, setSummary] = useState<PayoutSummary | null>(transporterStore.getPayoutSummary())
	const [isLoading, setIsLoading] = useState(enabled && transporterStore.getPayoutSummary() === null)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		Promise.all([listTransportPayouts(), getTransportPayoutSummary()]).then(([nextPayouts, nextSummary]) => {
			if (!active) return
			transporterStore.setPayouts(nextPayouts)
			transporterStore.setPayoutSummary(nextSummary)
			setPayouts(nextPayouts)
			setSummary(nextSummary)
		}).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { payouts, summary, isLoading, error }
}
