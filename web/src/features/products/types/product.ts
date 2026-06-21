// web/src/core/types/product.ts
/**
 * Product domain types
 */

export interface ProductImage {
	url: string;
	alt?: string;
}

export interface Product {
	id: string | number;
	uuid?: string;
	name?: string;
	farmer?: string | number;
	farmer_phone?: string;
	farmer_name?: string;
	category?: string | number;
	category_detail?: {
		id: number;
		code?: string;
		name?: string;
	} | null;
	description?: string | null;
	variety?: string | null;
	price_per_unit?: number;
	available_quantity?: number;
	reserved_quantity?: number;
	unit?: string;
	harvest_date?: string | null;
	shelf_life_days?: number;
	expiry_date?: string | null;
	is_organic?: boolean;
	is_active?: boolean;
	image?: string | null;
	pickup_lat?: number | string | null;
	pickup_lng?: number | string | null;
	weight_per_unit?: number | string | null;
	remaining_shelf_life?: number;
	created_at?: string;
	updated_at?: string;
	images?: ProductImage[];
}
