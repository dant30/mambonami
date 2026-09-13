export type PasswordStrengthLevel = 'weak' | 'fair' | 'good' | 'strong'

export type PasswordStrengthResult = {
	level: PasswordStrengthLevel
	label: string
	percentage: number
	criteria: Array<{ id: string; label: string; met: boolean }>
}

export function evaluatePasswordStrength(password: string): PasswordStrengthResult {
	const criteria = [
		{id: 'length', label: 'At least 8 characters', met: password.length >= 8},
		{id: 'lowercase', label: 'A lowercase letter', met: /[a-z]/.test(password)},
		{id: 'uppercase', label: 'An uppercase letter', met: /[A-Z]/.test(password)},
		{id: 'number', label: 'A number', met: /\d/.test(password)},
		{id: 'symbol', label: 'A special character', met: /[^A-Za-z0-9]/.test(password)},
	]
	const score = criteria.filter((criterion) => criterion.met).length
	const level = score <= 1 ? 'weak' : score === 2 ? 'fair' : score === 3 ? 'good' : 'strong'
	return {
		level,
		label: level[0].toUpperCase() + level.slice(1),
		percentage: Math.round((score / criteria.length) * 100),
		criteria,
	}
}
