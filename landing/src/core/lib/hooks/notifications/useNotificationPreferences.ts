import { useEffect, useState } from 'react'

import { listNotificationPreferences } from '../../services'
import { notificationStore } from '../../stores'
import type { NotificationPreference } from '../../types'

export function useNotificationPreferences() {
	const cachedPreferences = notificationStore.getPreferences()
	const [preferences, setPreferences] = useState<NotificationPreference[]>(cachedPreferences)
	const [isLoading, setIsLoading] = useState(cachedPreferences.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		setError(null)

		listNotificationPreferences()
			.then((nextPreferences) => {
				if (!active) return
				notificationStore.setPreferences(nextPreferences)
				setPreferences(nextPreferences)
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
	}, [])

	return { preferences, isLoading, error, isEmpty: !isLoading && preferences.length === 0 }
}
