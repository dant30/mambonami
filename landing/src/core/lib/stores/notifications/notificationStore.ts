import type { Notification, NotificationPreference } from '../../types'

let cachedNotifications: Notification[] = []
let cachedPreferences: NotificationPreference[] = []
let activePreference: NotificationPreference | null = null
const notificationListeners = new Set<() => void>()

export const notificationStore = {
	getNotifications(): Notification[] {
		return cachedNotifications
	},
	setNotifications(notifications: Notification[]) {
		cachedNotifications = notifications
		notificationListeners.forEach((listener) => listener())
	},
	subscribe(listener: () => void) {
		notificationListeners.add(listener)
		return () => {
			notificationListeners.delete(listener)
		}
	},
	getPreferences(): NotificationPreference[] {
		return cachedPreferences
	},
	setPreferences(preferences: NotificationPreference[]) {
		cachedPreferences = preferences
	},
	getActivePreference(): NotificationPreference | null {
		return activePreference
	},
	setActivePreference(preference: NotificationPreference | null) {
		activePreference = preference
	},
	clear() {
		cachedNotifications = []
		cachedPreferences = []
		activePreference = null
		notificationListeners.forEach((listener) => listener())
	},
}
