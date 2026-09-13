import { useEffect, useState } from 'react'

import { getRetailerDashboardData, summarizeRetailerDashboard } from '../../services'
import { retailerStore } from '../../stores'
import type { RetailerDashboardData, RetailerDashboardSummary } from '../../types'

export function useRetailerDashboard(enabled = true) {
	const [data, setData] = useState<RetailerDashboardData | null>(null)
	const [summary, setSummary] = useState<RetailerDashboardSummary | null>(retailerStore.getSummary())
	const [isLoading, setIsLoading] = useState(enabled && retailerStore.getSummary() === null)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		getRetailerDashboardData().then((nextData) => {
			if (!active) return
			const nextSummary = summarizeRetailerDashboard(nextData)
			retailerStore.setDashboardData(nextData, nextSummary)
			setData(nextData)
			setSummary(nextSummary)
		}).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { data, summary, isLoading, error }
}
