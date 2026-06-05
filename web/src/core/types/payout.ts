/**
 * Payout domain types
 */

export type PayoutStatus = 'pending' | 'processing' | 'paid' | 'failed' | 'cancelled';

export interface Payout {
	id: string | number;
	recipientId: string | number;
	amount: number;
	currency?: string;
	status: PayoutStatus;
	method?: string | null;
	reference?: string | null;
	processedAt?: string | null;
	createdAt?: string;
	updatedAt?: string;
}
