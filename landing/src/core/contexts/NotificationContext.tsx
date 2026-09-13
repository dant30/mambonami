import { createContext, useContext, useState, type ReactNode } from 'react'

export interface NotificationItem {
	id: string | number
	title: string
	message: string
	read?: boolean
	type?: 'info' | 'success' | 'warning' | 'error'
	createdAt?: string
}

interface NotificationContextValue {
	notifications: NotificationItem[]
	unreadCount: number
	addNotification(notification: Omit<NotificationItem, 'read'>): void
	markAsRead(id: NotificationItem['id']): void
	removeNotification(id: NotificationItem['id']): void
	clearNotifications(): void
}

const NotificationContext = createContext<NotificationContextValue | undefined>(undefined)

export function NotificationProvider({ children }: { children: ReactNode }) {
	const [notifications, setNotifications] = useState<NotificationItem[]>([])

	const addNotification = (notification: Omit<NotificationItem, 'read'>) => {
		setNotifications((current) => [{ ...notification, read: false }, ...current])
	}
	const markAsRead = (id: NotificationItem['id']) => setNotifications((current) => current.map((item) => item.id === id ? { ...item, read: true } : item))
	const removeNotification = (id: NotificationItem['id']) => setNotifications((current) => current.filter((item) => item.id !== id))
	const clearNotifications = () => setNotifications([])

	return <NotificationContext.Provider value={{ notifications, unreadCount: notifications.filter((item) => !item.read).length, addNotification, markAsRead, removeNotification, clearNotifications }}>{children}</NotificationContext.Provider>
}

export function useNotifications() {
	const context = useContext(NotificationContext)
	if (!context) throw new Error('useNotifications must be used inside NotificationProvider')
	return context
}
