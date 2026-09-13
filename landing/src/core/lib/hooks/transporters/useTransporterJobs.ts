import { useEffect, useState } from 'react'

import { listTransportJobs } from '../../services'
import { transporterStore } from '../../stores'
import type { Trip } from '../../types'

export function useTransporterJobs(enabled = true) {
	const cached = transporterStore.getAvailableJobs()
	const [jobs, setJobs] = useState<Trip[]>(cached)
	const [isLoading, setIsLoading] = useState(enabled && cached.length === 0)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		listTransportJobs().then((next) => { if (active) { transporterStore.setAvailableJobs(next); setJobs(next) } }).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { jobs, isLoading, error, isEmpty: !isLoading && jobs.length === 0 }
}
