import { useCallback } from 'react'

import { useAuth } from '../../../contexts/AuthContext'
import { login } from '../../services'
import type { LoginInput } from '../../types'
import { useAuthRequest } from './useAuthRequest'

export function useLogin() {
	const { setSession } = useAuth()
	const request = useCallback(async (input: LoginInput) => {
		const response = await login(input)
		setSession(response.user, response.tokens ?? null)
		return response
	}, [setSession])

	return useAuthRequest(request)
}