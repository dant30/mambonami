export interface NotificationPreference {
	id: number
	uuid: string
	user: number
	channel: 'push' | 'email' | 'sms' | 'whatsapp' | 'in_app'
	category:
		| 'order'
		| 'delivery'
		| 'payment'
		| 'dispute'
		| 'review'
		| 'promotion'
		| 'verification'
		| 'system'
	enabled: boolean
	quiet_hours_start?: string | null
	quiet_hours_end?: string | null
	language?: string
	created_at?: string
	updated_at?: string
}

export interface NotificationPreferenceInput {
	channel: NotificationPreference['channel']
	category: NotificationPreference['category']
	enabled?: boolean
	quiet_hours_start?: string | null
	quiet_hours_end?: string | null
	language?: string
}

export interface Notification {
	id: number
	uuid: string
	user: number
	channel: NotificationPreference['channel']
	category: NotificationPreference['category']
	priority: 'low' | 'normal' | 'high' | 'critical'
	title: string
	body: string
	metadata?: Record<string, unknown>
	delivery_status: 'pending' | 'queued' | 'sent' | 'failed'
	status?: string
	notification_type?: string
	type?: string
	is_unread?: boolean
	time_ago?: string
	is_read: boolean
	action_url?: string
	image?: string
	external_id?: string
	error_message?: string
	delivered_at?: string | null
	read_at?: string | null
	expires_at?: string | null
	created_at?: string
	updated_at?: string
}

export interface NotificationListResponse {
	count?: number
	next?: string | null
	previous?: string | null
	results?: Notification[]
	[key: string]: unknown
}

export interface MarkReadInput {
	notification_ids: number[]
}
