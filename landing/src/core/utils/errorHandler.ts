export interface NormalizedError {
	message: string
	status?: number
	code?: string
	details?: unknown
}

export function getErrorMessage(error: unknown, fallback = 'Something went wrong.'): string {
	if (typeof error === 'string' && error.trim()) return error.trim()

	if (isRecord(error)) {
		const dataMessage = extractNestedMessage(error.data)
		if (dataMessage) return dataMessage

		const recordMessage = extractNestedMessage(error)
		if (recordMessage) return recordMessage
	}

	if (error instanceof Error && error.message.trim()) {
		return error.message
	}

	return fallback
}

export function normalizeError(error: unknown, fallback?: string): NormalizedError {
	const normalized: NormalizedError = { message: getErrorMessage(error, fallback) }
	if (isRecord(error)) {
		if (typeof error.status === 'number') normalized.status = error.status
		if (typeof error.code === 'string') normalized.code = error.code
		if ('data' in error) normalized.details = error.data
	}
	return normalized
}

export function isApiError(error: unknown): error is { status: number; data?: unknown } {
	return isRecord(error) && typeof error.status === 'number'
}

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === 'object' && value !== null
}

function extractNestedMessage(value: unknown): string | null {
	if (typeof value === 'string' && value.trim()) return value.trim()

	if (Array.isArray(value)) {
		for (const item of value) {
			const extracted = extractNestedMessage(item)
			if (extracted) return extracted
		}
		return null
	}

	if (isRecord(value)) {
		for (const key of ['data', 'detail', 'message', 'error', 'non_field_errors']) {
			const extracted = extractNestedMessage(value[key])
			if (extracted) return extracted
		}

		for (const key of Object.keys(value)) {
			if (['data', 'detail', 'message', 'error', 'non_field_errors'].includes(key)) continue
			const extracted = extractNestedMessage(value[key])
			if (extracted) return extracted
		}
	}

	return null
}
