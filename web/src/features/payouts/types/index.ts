import type { Payout, PayoutStatus } from '../../../core/types';

export type { Payout, PayoutStatus };

export type PayoutWorkflowStatus = PayoutStatus | 'completed';

export interface PayoutListFilters {
	status?: PayoutWorkflowStatus | 'all';
	search?: string;
}

export interface PayoutListSummary {
	total: number;
	pending: number;
	processing: number;
	completed: number;
	failed: number;
}

export interface PayoutRecord {
	uuid: string;
	farmer_name: string;
	farmer_phone: string;
	amount: number;
	status: PayoutWorkflowStatus;
	mpesa_transaction_id?: string;
	error_message?: string;
	created_at: string;
	updated_at?: string;
	recipient_id?: string | number;
	currency?: string;
	method?: string | null;
	reference?: string | null;
	processed_at?: string | null;
}

export interface PayoutDetailViewModel extends PayoutRecord {
	notes?: string;
	retry_count?: number;
}
