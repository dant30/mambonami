const KENYAN_MOBILE = /^(?:\+254|254|0)(?:1|7)\d{8}$/

export function normalizeKenyanPhone(value: string): string {
	const digits = value.trim().replace(/[\s().-]/g, '')
	if (!KENYAN_MOBILE.test(digits)) return ''
	if (digits.startsWith('+254')) return digits
	if (digits.startsWith('254')) return `+${digits}`
	return `+254${digits.slice(1)}`
}

export function isValidKenyanPhone(value: string): boolean {
	return Boolean(normalizeKenyanPhone(value))
}
