type LogMethod = (...values: unknown[]) => void

const isDevelopment = (import.meta.env as ImportMetaEnv & { DEV?: boolean }).DEV ?? false

function write(method: LogMethod, values: unknown[]): void {
	if (typeof console === 'undefined') return
	method(...values)
}

export const logger = {
	debug: (...values: unknown[]) => {
		if (isDevelopment) write(console.debug.bind(console), values)
	},
	info: (...values: unknown[]) => write(console.info.bind(console), values),
	warn: (...values: unknown[]) => write(console.warn.bind(console), values),
	error: (...values: unknown[]) => write(console.error.bind(console), values),
}

export function logError(error: unknown, context?: string): void {
	logger.error(context ? `[${context}]` : '[Error]', error)
}
