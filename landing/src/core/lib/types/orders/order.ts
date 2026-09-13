import type { Product } from '../products'

export type OrderStatus = 'cart' | 'placed' | 'paid_escrow' | 'transport_assigned' | 'picked_up' | 'delivered' | 'cancelled' | 'disputed'
export type SubOrderStatus = 'pending' | 'confirmed' | 'ready' | 'cancelled'

export interface OrderItem {
	id: number
	product: number
	product_detail?: Product
	quantity: string | number
	unit_price: string | number
	total_price: string | number
}

export interface SubOrder {
	id: number
	farmer: number
	farmer_phone?: string
	status: SubOrderStatus
	subtotal: string | number
	farmer_payout: string | number
	items: OrderItem[]
	confirmed_at?: string | null
	ready_at?: string | null
	created_at: string
}

export interface Order {
	id: number
	uuid: string
	buyer: number
	buyer_phone?: string
	buyer_name?: string
	total_amount: string | number
	delivery_fee: string | number
	platform_commission: string | number
	promo_code?: string
	discount_amount: string | number
	status: OrderStatus
	account_number?: string
	delivery_address?: string
	delivery_street?: string
	delivery_city?: string
	delivery_postal_code?: string
	delivery_landmark?: string | null
	delivery_lat?: string | number | null
	delivery_lng?: string | number | null
	total_weight_kg?: string | number
	scheduled_date: string
	scheduled_time_window: string
	assigned_provider?: number | null
	sub_orders: SubOrder[]
	created_at: string
	paid_at?: string | null
	delivered_at?: string | null
	time_ago?: string
	item_summary?: string
}

export interface OrderListResponse {
	count?: number
	next?: string | null
	previous?: string | null
	results?: Order[]
	[key: string]: unknown
}

export interface CartItem {
	id?: string | number
	product_uuid: string
	quantity: string | number
	unit_price?: string | number
	total_price?: string | number
	product_detail?: Product
}

export interface CartSummary {
	itemCount: number
	totalQuantity: number
	subtotal: number
	delivery_fee: number
	total: number
}

export interface CartItemInput {
	product_uuid: string
	quantity: string | number
	unit_price?: string | number
	product_detail?: Product
}

export interface CreateOrderInput {
	delivery_address?: string
	delivery_street?: string
	delivery_city?: string
	delivery_postal_code?: string
	delivery_landmark?: string | null
	delivery_lat: number
	delivery_lng: number
	scheduled_date: string
	scheduled_time_window: string
	payment_method?: string | null
	promo_code?: string
	items: CartItemInput[]
}

export interface CreateOrderResponse {
	id: number
	uuid: string
	order_uuid: string
	account_number: string
	subtotal: number
	delivery_fee: number
	platform_commission: number
	total_amount: string | number
	discount_amount: number
	paybill_number: string
	instructions: string
}