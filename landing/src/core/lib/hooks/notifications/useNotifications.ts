import { useEffect, useState } from 'react'

import { listNotifications, markNotificationsRead } from '../../services'
import { notificationStore } from '../../stores'
import type { Notification } from '../../types'

export function useNotifications(enabled = true) {
	const cachedNotifications = notificationStore.getNotifications()
	const [notifications, setNotifications] = useState<Notification[]>(cachedNotifications)
	const [isLoading, setIsLoading] = useState(enabled && cachedNotifications.length === 0)
	const [error, setError] = useState<unknown>(null)
	const [refreshKey, setRefreshKey] = useState(0)

	useEffect(() => notificationStore.subscribe(() => {
		setNotifications(notificationStore.getNotifications())
	}), [])

	useEffect(() => {
		if (!enabled) {
			setIsLoading(false)
			return
		}
		if (refreshKey === 0 && notificationStore.getNotifications().length > 0) {
			setNotifications(notificationStore.getNotifications())
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
	}, [enabled, refreshKey])

	const markAsRead = async (notificationIds: number[]) => {
		if (notificationIds.length === 0) return
		await markNotificationsRead({ notification_ids: notificationIds })
		const ids = new Set(notificationIds)
		const updated = notificationStore.getNotifications().map((notification) =>
			ids.has(notification.id)
				? { ...notification, is_read: true, is_unread: false, read_at: new Date().toISOString() }
				: notification,
		)
		notificationStore.setNotifications(updated)
	}

	return {
		notifications,
		isLoading,
		error,
		isEmpty: !isLoading && notifications.length === 0,
		markAsRead,
		refresh: () => setRefreshKey((key) => key + 1),
	}
}
