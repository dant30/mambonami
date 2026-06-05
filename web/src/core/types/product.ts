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
	description?: string | null;
	price: number;
	currency?: string;
	available?: boolean;
	stock?: number | null;
	vendorId?: string | number | null;
	images?: ProductImage[];
	createdAt?: string;
	updatedAt?: string;
}
