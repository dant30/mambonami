import { useEffect, useState } from 'react'

import { getNotificationPreference } from '../../services'
import { notificationStore } from '../../stores'
import type { NotificationPreference } from '../../types'

export function useNotificationPreference(id: number) {
	const [preference, setPreference] = useState<NotificationPreference | null>(() => notificationStore.getActivePreference())
	const [isLoading, setIsLoading] = useState(Boolean(id) && notificationStore.getActivePreference() === null)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		if (!id) {
			setPreference(null)
			setIsLoading(false)
			return
		}

		let active = true
		setIsLoading(true)
		setError(null)

		getNotificationPreference(id)
			.then((nextPreference) => {
				if (!active) return
				notificationStore.setActivePreference(nextPreference)
				setPreference(nextPreference)
			})
			.catch((requestError: unknown) => {
				if (active) setError(requestError)
			})
			.finally(() => {
				if (active) setIsLoading(false)
			})

		return () => {
			active = false
		}
	}, [id])

	return { preference, isLoading, error }
}
