import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient, apiRequest } from '../src/core/api/apiClient'
import { createCorrelationId, getResponseCorrelationId, isCorrelationId } from '../src/core/api/correlation'
import { getLocale, setLocale, translate } from '../src/core/i18n'
import { localStorageStore } from '../src/core/storage'

function jsonResponse(body: unknown, status = 200) {
	return new Response(JSON.stringify(body), {
		status,
		headers: { 'Content-Type': 'application/json' },
	})
}

describe('request correlation', () => {
	afterEach(() => {
		apiClient.setAccessToken(null)
	})

	it('creates UUID-shaped correlation IDs', () => {
		const requestId = createCorrelationId()
		expect(isCorrelationId(requestId)).toBe(true)
		expect(isCorrelationId('not-a-request-id')).toBe(false)
	})

	it('reads a backend request ID from response headers or error data', () => {
		expect(getResponseCorrelationId(new Headers({ 'X-Request-ID': 'trace-123' }))).toBe('trace-123')
		expect(getResponseCorrelationId(new Headers(), { request_id: 'trace-456' })).toBe('trace-456')
		expect(getResponseCorrelationId(new Headers(), { request_id: '<invalid>' })).toBeNull()
	})

	it('reuses the same request ID when retrying after token refresh', async () => {
		apiClient.setAccessToken('expired-token')
		const sentRequestIds: string[] = []
		let protectedRequestCount = 0
		vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
			const url = String(input)
			if (url.includes('/api/token/refresh/')) return jsonResponse({ access: 'fresh-token' })

			const headers = new Headers(init?.headers)
			sentRequestIds.push(headers.get('X-Request-ID') || '')
			protectedRequestCount += 1
			return protectedRequestCount === 1 ? jsonResponse({ detail: 'expired' }, 401) : jsonResponse({ ok: true })
		}))

		await expect(apiRequest('/api/orders/')).resolves.toEqual({ ok: true })
		expect(sentRequestIds).toHaveLength(2)
		expect(sentRequestIds[0]).toBeTruthy()
		expect(sentRequestIds[0]).toBe(sentRequestIds[1])
	})
})

describe('locale foundation', () => {
	afterEach(() => setLocale('en'))

	it('persists language selection and translates interpolated messages', () => {
		setLocale('sw')

		expect(getLocale()).toBe('sw')
		expect(window.localStorage.getItem('mambonami_locale')).toBe('sw')
		expect(translate('checkout.orderReference', { reference: 'ORD-123' })).toBe('Rejeleo la agizo: ORD-123')
	})

	it('updates the document language and renders English translations', () => {
		setLocale('sw')
		expect(document.documentElement.lang).toBe('sw')
		setLocale('en')
		expect(translate('errors.requestId', { requestId: 'trace-123' })).toBe('Reference: trace-123')
	})
})

describe('browser storage', () => {
	it('safely handles a blocked localStorage getter', () => {
		const descriptor = Object.getOwnPropertyDescriptor(window, 'localStorage')
		Object.defineProperty(window, 'localStorage', {
			configurable: true,
			get: () => { throw new DOMException('Storage is blocked', 'SecurityError') },
		})

		try {
			expect(localStorageStore.get('blocked-key')).toBeNull()
			expect(() => localStorageStore.set('blocked-key', 'value')).not.toThrow()
		} finally {
			if (descriptor) Object.defineProperty(window, 'localStorage', descriptor)
			else Reflect.deleteProperty(window, 'localStorage')
		}
	})
})