const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i

export function isCorrelationId(value: string): boolean {
	return UUID_PATTERN.test(value)
}

export function getResponseCorrelationId(headers: Headers, body?: unknown): string | null {
	const headerValue = headers.get('X-Request-ID') || headers.get('X-Correlation-ID')
	if (headerValue && /^[A-Za-z0-9._:-]{1,100}$/.test(headerValue)) return headerValue

	if (!body || typeof body !== 'object') return null
	const data = body as Record<string, unknown>
	const bodyValue = data.request_id ?? data.correlation_id
	return typeof bodyValue === 'string' && /^[A-Za-z0-9._:-]{1,100}$/.test(bodyValue) ? bodyValue : null
}

export function createCorrelationId(): string {
	if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
		return crypto.randomUUID()
	}

	if (typeof crypto !== 'undefined' && typeof crypto.getRandomValues === 'function') {
		const bytes = crypto.getRandomValues(new Uint8Array(16))
		bytes[6] = (bytes[6] & 0x0f) | 0x40
		bytes[8] = (bytes[8] & 0x3f) | 0x80
		const hex = Array.from(bytes, (byte) => byte.toString(16).padStart(2, '0')).join('')
		return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`
	}

	return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (character) => {
		const random = Math.floor(Math.random() * 16)
		return (character === 'x' ? random : (random & 0x3) | 0x8).toString(16)
	})
}
