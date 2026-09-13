import { useEffect, useState } from 'react'

import { getFarmerDashboardData, summarizeFarmerDashboard } from '../../services'
import { farmerStore } from '../../stores'
import type { FarmerDashboardData, FarmerDashboardSummary } from '../../types'

export function useFarmerDashboard(enabled = true) {
	const [data, setData] = useState<FarmerDashboardData | null>(null)
	const [summary, setSummary] = useState<FarmerDashboardSummary | null>(farmerStore.getSummary())
	const [isLoading, setIsLoading] = useState(enabled && farmerStore.getSummary() === null)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		getFarmerDashboardData().then((nextData) => {
			if (!active) return
			const nextSummary = summarizeFarmerDashboard(nextData)
			farmerStore.setDashboardData(nextData, nextSummary)
			setData(nextData)
			setSummary(nextSummary)
		}).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { data, summary, isLoading, error }
}
