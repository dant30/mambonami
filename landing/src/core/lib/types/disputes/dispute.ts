export type DisputeReason =
	| 'not_fresh'
	| 'wrong_quantity'
	| 'wrong_item'
	| 'delivery_not_received'
	| 'damaged'
	| 'poor_quality'
	| 'late_delivery'
	| 'payment'
	| 'other'

export type DisputeStatus =
	| 'open'
	| 'under_review'
	| 'waiting_customer'
	| 'waiting_farmer'
	| 'waiting_provider'
	| 'escalated'
	| 'resolved'
	| 'rejected'
	| 'closed'

export type DisputePriority = 'low' | 'medium' | 'high' | 'urgent'

export type DisputeResolution =
	| 'full_refund'
	| 'partial_refund'
	| 'replacement'
	| 'store_credit'
	| 'compensate_farmer'
	| 'compensate_provider'
	| 'no_action'

export interface Dispute {
	id: number
	uuid: string
	order: number
	order_detail?: Record<string, unknown>
	raised_by: number
	raised_by_phone?: string
	assigned_to?: number | null
	assigned_to_phone?: string | null
	reason: DisputeReason
	description: string
	evidence: unknown[]
	status: DisputeStatus
	priority?: DisputePriority
	resolution?: DisputeResolution | null
	resolution_notes?: string
	internal_notes?: string
	refund_amount?: string | number
	penalty_amount?: string | number
	penalty_user?: number | null
	resolved_by?: number | null
	resolved_at?: string | null
	closed_at?: string | null
	created_at?: string
	updated_at?: string
	events?: DisputeEvent[]
}

export interface DisputeEvent {
	id: number
	event_type: string
	actor?: number | null
	actor_phone?: string | null
	details?: string
	metadata?: Record<string, unknown>
	created_at?: string
}

export interface DisputeListResponse {
	count?: number
	next?: string | null
	previous?: string | null
	results?: Dispute[]
	[key: string]: unknown
}

export interface DisputeCreateInput {
	order: number
	reason: DisputeReason
	description: string
	evidence?: unknown[]
}

export interface DisputeResolutionInput {
	resolution: DisputeResolution
	refund_amount?: string | number
	penalty_amount?: string | number
	penalty_user_id?: number | null
	resolution_notes?: string
}
