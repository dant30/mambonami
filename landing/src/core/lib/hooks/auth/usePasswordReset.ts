import { useCallback } from 'react'

import { requestPasswordReset, resetPassword } from '../../services'
import type { PasswordResetInput } from '../../types'
import { useAuthRequest } from './useAuthRequest'

export function usePasswordReset() {
	const request = useAuthRequest(requestPasswordReset)
	const reset = useAuthRequest((input: PasswordResetInput) => resetPassword(input))
	const start = useCallback((phone: string) => request.execute(phone), [request])
	return { start, reset: reset.execute, isLoading: request.isLoading || reset.isLoading, error: request.error ?? reset.error }
}