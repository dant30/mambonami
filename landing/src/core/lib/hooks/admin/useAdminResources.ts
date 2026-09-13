import { useEffect, useState } from 'react'

import { getAdminDashboardData } from '../../services'
import { adminStore } from '../../stores'
import type { AdminDashboardData } from '../../types'

export function useAdminResources(enabled = true) {
	const [data, setData] = useState<AdminDashboardData | null>(null)
	const [isLoading, setIsLoading] = useState(enabled && adminStore.getUsers().length === 0)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		getAdminDashboardData().then((next) => {
			if (!active) return
			adminStore.setOrders(next.orders)
			adminStore.setUsers(next.users)
			adminStore.setFarmers(next.farmers)
			adminStore.setTransportProviders(next.transportProviders)
			adminStore.setDisputes(next.disputes)
			adminStore.setPayouts(next.payouts)
			adminStore.setAuditLogs(next.auditLogs)
			setData(next)
		}).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { data, isLoading, error }
}
