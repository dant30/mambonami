/**
 * Dispute domain types
 */

export type DisputeStatus = 'open' | 'investigating' | 'resolved' | 'rejected' | 'closed';

export interface DisputeComment {
	id?: string | number;
	authorId?: string | number;
	message: string;
	createdAt?: string;
}

export interface Dispute {
	id: string | number;
	reporterId: string | number;
	assigneeId?: string | number | null;
	orderId?: string | number | null;
	tripId?: string | number | null;
	reason: string;
	details?: string | null;
	status: DisputeStatus;
	comments?: DisputeComment[];
	createdAt?: string;
	resolvedAt?: string | null;
}
