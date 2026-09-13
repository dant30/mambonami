export type BillingTransactionStatus = 'received' | 'validated' | 'matched' | 'allocated' | 'completed' | 'orphaned' | 'refund_pending' | 'refunded' | 'failed' | 'reversed'
export type SettlementStatus = 'pending' | 'settled' | 'failed'

export interface BillingTransaction {
	id: number
	uuid: string
	transaction_code: string
	amount: string | number
	account_number: string
	sender_phone: string
	payer_first_name?: string
	payer_middle_name?: string
	payer_last_name?: string
	business_shortcode?: string
	transaction_type?: string
	currency: string
	transaction_time: string
	status: BillingTransactionStatus
	matched_order_id?: number | null
	order_uuid?: string | null
	running_balance: string | number
	notes?: string
	created_at: string
}

export interface BillingSettlement {
	id: number
	uuid: string
	settlement_date: string
	amount: string | number
	reference?: string
	status: SettlementStatus
	bank_account?: string
	initiated_at?: string | null
	completed_at?: string | null
	created_at: string
	updated_at: string
}

export interface FloatBalance {
	float_balance: string | number
}

export interface PayBillSimulationInput {
	TransactionCode: string
	Amount: string | number
	AccountNumber: string
	PhoneNumber: string
	Time: string
	BillRefNumber?: string
	FirstName?: string
	MiddleName?: string
	LastName?: string
	BusinessShortCode?: string
	TransactionType?: string
}

export interface PayBillSimulationResult {
	success: boolean
	message: string
	order_id?: number | null
}
