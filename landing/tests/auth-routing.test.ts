import { describe, expect, it } from 'vitest'

import { determinePostLoginDestination } from '../src/features/auth/pages/LoginPage'

describe('post-login routing', () => {
	it.each([
		['buyer', '/app/buyer'],
		['farmer', '/app/farmer'],
		['retailer', '/app/retailer'],
		['transport_provider', '/app/transport'],
	])('routes %s users to their workspace', (role, destination) => {
		expect(determinePostLoginDestination({ role })).toBe(destination)
	})

	it('prioritizes staff access and falls back safely for unknown roles', () => {
		expect(determinePostLoginDestination({ role: 'buyer', is_staff: true })).toBe('/app/admin')
		expect(determinePostLoginDestination({ role: 'unknown' })).toBe('/app/buyer')
	})
})