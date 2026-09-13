import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { AuthField } from '../src/features/auth/components/AuthField'

describe('auth form accessibility', () => {
	it('associates each visible label with its input', () => {
		render(<AuthField label="Phone number" required autoComplete="tel" />)

		const input = screen.getByRole('textbox', { name: 'Phone number' })
		expect(input).toHaveAccessibleName('Phone number')
		expect(input).toHaveAttribute('id')
	})

	it('exposes password validation state and a labelled visibility control', () => {
		render(<AuthField label="Password" type="password" error="Password is required" />)

		expect(screen.getByRole('textbox', { name: 'Password' })).toHaveAttribute('aria-invalid', 'true')
		expect(screen.getByRole('button', { name: 'Show password' })).toBeInTheDocument()
	})
})
