import { useEffect, useState } from 'react'

import { getBuyerDashboardData, summarizeBuyerDashboard } from '../../services'
import { buyerStore } from '../../stores'
import type { BuyerDashboardData, BuyerDashboardSummary } from '../../types'

export function useBuyerDashboard(enabled = true) {
	const [data, setData] = useState<BuyerDashboardData | null>(null)
	const [summary, setSummary] = useState<BuyerDashboardSummary | null>(buyerStore.getSummary())
	const [isLoading, setIsLoading] = useState(enabled && buyerStore.getSummary() === null)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		getBuyerDashboardData().then((nextData) => {
			if (!active) return
			const nextSummary = summarizeBuyerDashboard(nextData)
			buyerStore.setDashboardData(nextData, nextSummary)
			setData(nextData)
			setSummary(nextSummary)
		}).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { data, summary, isLoading, error }
}
