export interface Farmer {
	id: number;
	user_id: number;
	user_phone: string;
	user_username: string;
	user_email: string;
	farm_gps: string;
	coop_name: string;
	coop_verified: boolean;
	mpesa_number: string;
	total_sales: number;
	rating: number;
	created_at: string;
	updated_at: string;
}

export interface FarmerFilters {
	status?: 'pending' | 'approved';
	search?: string;
}

export interface FarmerSummary {
	total: number;
	pending: number;
	approved: number;
	verified: number;
}
