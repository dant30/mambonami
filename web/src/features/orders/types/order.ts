import { Product } from '../../products/types/product';

/**
 * Order domain types
 */

export interface OrderItem {
	id?: string | number;
	product?: Product;
	product_detail?: Product;
	quantity: number;
	unit_price: number;
	total_price?: number;
}

export type OrderStatus =
	| 'cart'
	| 'placed'
	| 'paid_escrow'
	| 'transport_assigned'
	| 'picked_up'
	| 'delivered'
	| 'cancelled'
	| 'disputed';

export type SubOrderStatus = 'pending' | 'confirmed' | 'ready' | 'cancelled';

export interface SubOrder {
	id: string | number;
	farmer?: string | number;
	farmer_phone?: string;
	status: SubOrderStatus;
	subtotal: number;
	farmer_commission?: number;
	items?: OrderItem[];
	confirmed_at?: string | null;
	ready_at?: string | null;
}

export interface Order {
	id: string | number;
	uuid: string;
	buyer?: string | number;
	buyer_phone?: string;
	total_amount: number;
	delivery_fee?: number;
	platform_commission?: number;
	status: OrderStatus;
	account_number?: string | null;
	delivery_address?: string;
	delivery_lat?: number | null;
	delivery_lng?: number | null;
	total_weight_kg?: number;
	scheduled_date?: string;
	scheduled_time_window?: string;
	assigned_provider?: string | number | null;
	sub_orders?: SubOrder[];
	created_at?: string;
	paid_at?: string | null;
	delivered_at?: string | null;
	items?: OrderItem[];
}

export interface ListResponse<T = unknown> {
	results: T[];
	count?: number;
	next?: string | null;
	previous?: string | null;
}
