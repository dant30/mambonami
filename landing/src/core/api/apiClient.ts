import { createCorrelationId, getResponseCorrelationId } from './correlation'

export type QueryValue = string | number | boolean | null | undefined;

export interface ApiRequestOptions extends RequestInit {
	params?: Record<string, QueryValue>;
	_retry?: boolean;
}

export class ApiError extends Error {
	readonly status: number;
	readonly data: unknown;
	readonly requestId: string | null;

	constructor(status: number, data: unknown, requestId: string | null = null) {
		super(`API request failed with status ${status}`);
		this.name = 'ApiError';
		this.status = status;
		this.data = data;
		this.requestId = requestId;
	}
}

const API_BASE = (import.meta.env.VITE_API_URL?.trim() || '').replace(/\/$/, '');
let accessToken: string | null = null;
let refreshPromise: Promise<string | null> | null = null;

function getAccessToken() {
	return accessToken;
}

function makeUrl(path: string, params?: Record<string, QueryValue>) {
	const url = new URL(`${API_BASE}${path}`, window.location.origin);

	Object.entries(params ?? {}).forEach(([key, value]) => {
		if (value !== undefined && value !== null) {
			url.searchParams.set(key, String(value));
		}
	});

	return API_BASE ? url.toString() : `${url.pathname}${url.search}`;
}

async function parseResponse(response: Response) {
	if (response.status === 204) return null;

	const contentType = response.headers.get('content-type') ?? '';
	return contentType.includes('application/json') ? response.json() : response.text();
}

async function refreshAccessToken() {
	if (refreshPromise) return refreshPromise;
	refreshPromise = refreshAccessTokenRequest()
	try {
		return await refreshPromise;
	} finally {
		refreshPromise = null;
	}
}

async function refreshAccessTokenRequest() {
	const requestId = createCorrelationId();
	const response = await fetch(makeUrl('/api/token/refresh/'), {
		method: 'POST',
		headers: { 'Content-Type': 'application/json', 'X-Request-ID': requestId },
		credentials: 'include',
		body: JSON.stringify({}),
	});

	if (!response.ok) {
		const data = await parseResponse(response);
		if (response.status === 429 || response.status >= 500) {
			throw new ApiError(response.status, data, getResponseCorrelationId(response.headers, data));
		}
		accessToken = null;
		return null;
	}

	const data = (await response.json()) as { access?: string };
	if (!data.access) {
		accessToken = null;
		return null;
	}

	accessToken = data.access;
	return data.access;
}

export async function apiRequest<T>(path: string, options: ApiRequestOptions = {}): Promise<T> {
	const { params, _retry, body, headers: requestHeaders, ...requestInit } = options;
	const headers = new Headers(requestHeaders);
	const token = getAccessToken();

	if (!headers.has('X-Request-ID')) headers.set('X-Request-ID', createCorrelationId());
	if (token) headers.set('Authorization', `Bearer ${token}`);
	if (body && !(body instanceof FormData) && !headers.has('Content-Type')) {
		headers.set('Content-Type', 'application/json');
	}

	const response = await fetch(makeUrl(path, params), {
		...requestInit,
		body,
		headers,
		credentials: 'include',
	});

	if (response.status === 401 && !_retry && !path.includes('/token/refresh/')) {
		const access = await refreshAccessToken();
		if (access) return apiRequest<T>(path, { ...options, headers, _retry: true });
		accessToken = null;
	}

	const data = await parseResponse(response);
	if (!response.ok) throw new ApiError(response.status, data, getResponseCorrelationId(response.headers, data));
	return data as T;
}

export const apiClient = {
	setAccessToken: (token: string | null) => {
		accessToken = token;
	},
	get: <T>(path: string, options?: ApiRequestOptions) => apiRequest<T>(path, { ...options, method: 'GET' }),
	post: <T>(path: string, body?: unknown, options?: ApiRequestOptions) =>
		apiRequest<T>(path, { ...options, method: 'POST', body: body instanceof FormData ? body : JSON.stringify(body ?? {}) }),
	put: <T>(path: string, body?: unknown, options?: ApiRequestOptions) =>
		apiRequest<T>(path, { ...options, method: 'PUT', body: body instanceof FormData ? body : JSON.stringify(body ?? {}) }),
	patch: <T>(path: string, body?: unknown, options?: ApiRequestOptions) =>
		apiRequest<T>(path, { ...options, method: 'PATCH', body: body instanceof FormData ? body : JSON.stringify(body ?? {}) }),
	delete: <T>(path: string, options?: ApiRequestOptions) => apiRequest<T>(path, { ...options, method: 'DELETE' }),
};
