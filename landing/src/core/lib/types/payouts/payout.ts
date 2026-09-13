export type PayoutRecipientType = 'farmer' | 'transport_provider' | 'buyer_refund'
export type PayoutStatus = 'pending' | 'processing' | 'completed' | 'failed' | 'retry'

export interface Payout {
	id: number
	uuid: string
	order: number
	order_uuid?: string
	recipient_type: PayoutRecipientType
	recipient_user: number
	recipient_phone?: string
	amount: string | number
	b2c_transaction_id?: string
	status: PayoutStatus
	error_message?: string
	retry_count?: number
	paid_at?: string | null
	created_at?: string
	updated_at?: string
}

export interface PayoutListResponse {
	count?: number
	next?: string | null
	previous?: string | null
	results?: Payout[]
	[key: string]: unknown
}

export interface PayoutSummary {
	total_payout_amount: number
	completed_payout_amount: number
	pending_payout_amount: number
	today_payout_amount: number
	completed_payout_count: number
	pending_payout_count: number
	latest_paid_at?: string | null
}
