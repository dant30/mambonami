export interface ProductCategory {
	id: number
	code: string
	name: string
}

export interface ProductUnitOption {
	code: string
	name: string
}

export interface BulkPriceTier {
	id?: number
	buyer_role: 'any' | 'buyer' | 'retailer'
	minimum_quantity: string | number
	unit_price: string | number
}

export interface Product {
	id: number
	uuid: string
	sku: string
	name: string
	variety?: string | null
	price_per_unit: string | number
	available_quantity: string | number
	reserved_quantity?: string | number
	unit: string
	image_url?: string | null
	image?: string | null
	description?: string | null
	is_organic?: boolean
	is_active?: boolean
	category?: number | string | null
	category_detail?: ProductCategory | null
	farmer?: number | null
	farmer_phone?: string | null
	farmer_name?: string | null
	farmer_verified?: boolean
	farmer_rating?: number | null
	harvest_date?: string | null
	shelf_life_days?: number | string | null
	expiry_date?: string | null
	remaining_shelf_life?: number | null
	pickup_lat?: string | number | null
	pickup_lng?: string | number | null
	weight_per_unit?: string | number | null
	bulk_price_tiers?: BulkPriceTier[]
	rating?: number | null
	review_count?: number
	wishlist_count?: number
	distance_km?: number | null
	created_at?: string
	updated_at?: string
}

export interface ProductListResponse {
	count?: number
	next?: string | null
	previous?: string | null
	results?: Product[]
	[key: string]: unknown
}

export interface ProductListParams {
	category?: string
	is_organic?: boolean
	min_price?: number
	max_price?: number
	min_rating?: number
	in_stock?: boolean
	search?: string
	page?: number
	page_size?: number
	buyer_lat?: number
	buyer_lng?: number
	lat?: number
	lng?: number
	ordering?: string
	farmer_phone?: string
}

export interface WishlistItem {
	id: number
	product: Product
	created_at: string
}

export interface ProductReview {
	id: number
	uuid: string
	product: number
	buyer_name?: string
	rating: number
	comment: string
	created_at: string
}

export interface ProductCreateInput {
	sku?: string
	category?: number | string | null
	name: string
	variety?: string | null
	price_per_unit: string | number
	available_quantity: string | number
	reserved_quantity?: string | number
	unit: string
	harvest_date?: string | null
	shelf_life_days?: number | string | null
	expiry_date?: string | null
	is_organic?: boolean
	image?: File | string | null
	description?: string | null
	is_active?: boolean
	pickup_lat?: string | number | null
	pickup_lng?: string | number | null
	weight_per_unit?: string | number | null
	bulk_price_tiers?: Array<Pick<BulkPriceTier, 'buyer_role' | 'minimum_quantity' | 'unit_price'>>
}

export type ProductUpdateInput = ProductCreateInput
