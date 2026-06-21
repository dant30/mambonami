// web/src/core/types/user.ts
/**
 * User domain types
 */

export type UserRole = 'admin' | 'retailer' | 'driver' | 'customer' | 'support';

export interface UserProfile {
	id: string | number;
	firstName: string;
	lastName?: string;
	email?: string;
	phone?: string;
	avatarUrl?: string | null;
	role?: UserRole;
	isActive?: boolean;
	createdAt?: string;
	updatedAt?: string;
}

export interface MinimalUser {
	id: string | number;
	displayName: string;
	phone?: string;
}
