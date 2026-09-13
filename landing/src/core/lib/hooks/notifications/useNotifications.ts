import { useEffect, useState } from 'react'

import { listNotifications } from '../../services'
import { notificationStore } from '../../stores'
import type { Notification } from '../../types'

export function useNotifications(enabled = true) {
	const cachedNotifications = notificationStore.getNotifications()
	const [notifications, setNotifications] = useState<Notification[]>(cachedNotifications)
	const [isLoading, setIsLoading] = useState(enabled && cachedNotifications.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		if (!enabled) {
			setIsLoading(false)
			return
		}
		let active = true
		setIsLoading(true)
		setError(null)

		listNotifications()
			.then((nextNotifications) => {
				if (!active) return
				notificationStore.setNotifications(nextNotifications)
				setNotifications(nextNotifications)
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
	}, [enabled])

	return { notifications, isLoading, error, isEmpty: !isLoading && notifications.length === 0 }
}
