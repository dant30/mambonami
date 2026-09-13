import { useCallback } from 'react'

import { useAuth } from '../../../contexts/AuthContext'
import { startRegistration, verifyRegistration } from '../../services'
import type { AuthRole, RegisterInitInput, RegisterInput } from '../../types'
import { useAuthRequest } from './useAuthRequest'

export function useRegistration(role?: AuthRole) {
	const { setSession } = useAuth()
	const init = useAuthRequest((input: RegisterInitInput) => startRegistration({ ...input, role: role ?? input.role }))
	const verify = useAuthRequest(async (input: RegisterInput) => {
		const response = await verifyRegistration(input)
		setSession(response.user, response.tokens ?? null)
		return response
	})

	const begin = useCallback((input: RegisterInitInput) => init.execute(input), [init])
	return { begin, verify: verify.execute, isLoading: init.isLoading || verify.isLoading, error: init.error ?? verify.error }
}