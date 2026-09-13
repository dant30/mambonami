import type { Notification, NotificationPreference } from '../../types'

let cachedNotifications: Notification[] = []
let cachedPreferences: NotificationPreference[] = []
let activePreference: NotificationPreference | null = null

export const notificationStore = {
	getNotifications(): Notification[] {
		return cachedNotifications
	},
	setNotifications(notifications: Notification[]) {
		cachedNotifications = notifications
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
	},
}
