import { useEffect, useState } from 'react'

import { getTransportDashboardData, summarizeTransportDashboard } from '../../services'
import { transporterStore } from '../../stores'
import type { TransportDashboardData, TransportDashboardSummary } from '../../types'

export function useTransporterDashboard(enabled = true) {
	const [data, setData] = useState<TransportDashboardData | null>(null)
	const [summary, setSummary] = useState<TransportDashboardSummary | null>(transporterStore.getSummary())
	const [isLoading, setIsLoading] = useState(enabled && transporterStore.getSummary() === null)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		getTransportDashboardData().then((nextData) => {
			if (!active) return
			const nextSummary = summarizeTransportDashboard(nextData)
			transporterStore.setDashboardData(nextData, nextSummary)
			setData(nextData)
			setSummary(nextSummary)
		}).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { data, summary, isLoading, error }
}
