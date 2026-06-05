/**
 * Common API utility types used across the application
 */

/** Standard API error shape returned from backend */
export interface ApiError {
	code?: string;
	message: string;
	details?: Record<string, any> | string;
}

/** Standard API response wrapper */
export interface ApiResponse<T = any> {
	data?: T;
	results?: T[];
	error?: ApiError | null;
	detail?: string;
	message?: string;
	status?: string;
	meta?: Record<string, any>;
	[key: string]: any;
}

/** Paginated response type */
export interface PaginatedResponse<T> extends ApiResponse<T> {
	count: number;
	next: string | null;
	previous: string | null;
	results: T[];
}

/** Pagination metadata */
export interface Pagination {
	page: number;
	pageSize: number;
	total: number;
	totalPages: number;
}

/** Common shape for list responses */
export interface ListResponse<T = any> extends ApiResponse<T[]> {
	meta: {
		pagination: Pagination;
		[key: string]: any;
	};
}

export interface ApiErrorResponse {
	status: number;
	message: string;
	errors?: Record<string, string[]>;
	detail?: string;
}

export interface AsyncState<T> {
	data: T | null;
	loading: boolean;
	error: ApiErrorResponse | null;
}
