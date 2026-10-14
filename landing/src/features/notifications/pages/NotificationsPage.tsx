import { useState } from 'react'
import { ArrowUpRight, Bell, Check, CheckCheck, RotateCw } from 'lucide-react'
import { Link } from 'react-router-dom'

import { useNotifications, type Notification } from '../../../core/lib'
import { EmptyState } from '../../../shared/components/feedback'
import { Button, PageHeader, Skeleton } from '../../../shared/components/ui'

function getActionPath(notification: Notification): string | null {
	const actionUrl = notification.action_url?.trim()
	return actionUrl?.startsWith('/') && !actionUrl.startsWith('//') ? actionUrl : null
}

function getTimestamp(notification: Notification): string {
	if (notification.time_ago) return notification.time_ago
	if (!notification.created_at) return ''
	const date = new Date(notification.created_at)
	return Number.isNaN(date.getTime()) ? '' : date.toLocaleString()
}

export function NotificationsPage() {
	const { notifications, isLoading, error, markAsRead, refresh } = useNotifications()
	const [actionError, setActionError] = useState('')
	const unreadNotifications = notifications.filter((notification) => !notification.is_read)

	const markRead = async (ids: number[]) => {
		setActionError('')
		try {
			await markAsRead(ids)
		} catch {
			setActionError('We could not update these notifications. Please try again.')
		}
	}

	return (
		<main className="mx-auto max-w-4xl px-4 py-5 sm:px-6 sm:py-8 lg:px-8">
			<PageHeader
				variant="minimal"
				eyebrow="Inbox"
				title="Notifications"
				description="Order, delivery, and account updates in one place."
				icon={<Bell className="h-5 w-5" />}
				actions={(
					<div className="flex shrink-0 items-center gap-2">
						<Button type="button" variant="outline" size="sm" onClick={refresh} leftIcon={<RotateCw className="h-4 w-4" />}>
							Refresh
						</Button>
						{unreadNotifications.length > 0 && (
							<Button type="button" size="sm" onClick={() => void markRead(unreadNotifications.map((item) => item.id))} leftIcon={<CheckCheck className="h-4 w-4" />}>
								Mark all read
							</Button>
						)}
					</div>
				)}
			/>

			{actionError && <p role="alert" className="mb-3 rounded-xl border border-destructive/30 bg-destructive/10 p-3 text-sm text-destructive">{actionError}</p>}
			{Boolean(error) && notifications.length > 0 && <p role="status" className="mb-3 rounded-xl border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900">Showing saved notifications. Refresh to try loading the latest.</p>}

			{isLoading && notifications.length === 0 ? (
				<div className="space-y-3" aria-label="Loading notifications">
					{[0, 1, 2].map((item) => <Skeleton key={item} className="h-28 w-full rounded-xl" />)}
				</div>
			) : error && notifications.length === 0 ? (
				<EmptyState
					title="Notifications are unavailable"
					description="We could not reach your inbox. Try again in a moment."
					icon={<Bell className="h-6 w-6" />}
					action={<Button type="button" onClick={refresh} leftIcon={<RotateCw className="h-4 w-4" />}>Try again</Button>}
				/>
			) : notifications.length === 0 ? (
				<EmptyState
					title="You’re all caught up"
					description="New order and account updates will appear here."
					icon={<Bell className="h-6 w-6" />}
					action={<Link to="/home" className="inline-flex min-h-10 items-center gap-2 rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-primary-foreground">Go to marketplace <ArrowUpRight className="h-4 w-4" /></Link>}
				/>
			) : (
				<div className="divide-y divide-border overflow-hidden rounded-xl border border-border bg-card">
					{notifications.map((notification) => {
						const actionPath = getActionPath(notification)
						return (
							<article key={notification.uuid || notification.id} className={`flex min-w-0 gap-3 p-4 sm:gap-4 sm:p-5 ${notification.is_read ? '' : 'bg-primary/[0.035]'}`}>
								<span className={`mt-0.5 flex h-9 w-9 shrink-0 items-center justify-center rounded-lg ${notification.is_read ? 'bg-muted text-muted-foreground' : 'bg-primary/10 text-primary'}`}>
									<Bell className="h-4 w-4" />
								</span>
								<div className="min-w-0 flex-1">
									<div className="flex flex-wrap items-center gap-x-2 gap-y-1">
										<h2 className="min-w-0 break-words text-sm font-semibold text-foreground">{notification.title}</h2>
										{!notification.is_read && <span className="h-2 w-2 shrink-0 rounded-full bg-primary" aria-label="Unread" />}
									</div>
									<p className="mt-1 whitespace-pre-wrap break-words text-sm leading-6 text-muted-foreground">{notification.body}</p>
									<div className="mt-3 flex flex-wrap items-center gap-x-4 gap-y-2 text-xs text-muted-foreground">
										{getTimestamp(notification) && <span>{getTimestamp(notification)}</span>}
										<span className="capitalize">{notification.category.replaceAll('_', ' ')}</span>
										{actionPath && <Link to={actionPath} className="inline-flex items-center gap-1 font-semibold text-primary hover:underline">Open <ArrowUpRight className="h-3.5 w-3.5" /></Link>}
									</div>
								</div>
								{!notification.is_read && (
									<button type="button" aria-label={`Mark ${notification.title} as read`} onClick={() => void markRead([notification.id])} className="flex h-9 w-9 shrink-0 items-center justify-center self-start rounded-lg text-muted-foreground hover:bg-muted hover:text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary">
										<Check className="h-4 w-4" />
									</button>
								)}
							</article>
						)
					})}
				</div>
			)}
		</main>
	)
}