export type { Dispute, DisputeStatus, DisputeComment } from '../../../core/types';

export type DisputeWorkflowStatus = 'open' | 'under_review' | 'resolved' | 'closed';

export type DisputeResolutionType = 'full_refund' | 'partial_refund' | 'penalty' | 'no_action';

export interface DisputeListFilters {
	status?: DisputeWorkflowStatus;
	search?: string;
}

export interface DisputeResolutionForm {
	resolution_type: DisputeResolutionType;
	resolved_amount?: number;
	notes?: string;
}

export interface DisputeRecord {
	uuid: string;
	order_id?: number;
	order_number?: string;
	reason: string;
	description?: string;
	status: DisputeWorkflowStatus | 'investigating' | 'rejected';
	raised_by?: string;
	raised_by_phone?: string;
	created_at?: string;
	updated_at?: string;
	evidence_photos?: string[];
	resolved_amount?: number;
	resolution_type?: DisputeResolutionType;
	resolved_by?: string;
	resolved_at?: string;
}

export interface DisputeListSummary {
	total: number;
	open: number;
	under_review: number;
	resolved: number;
	closed: number;
}
