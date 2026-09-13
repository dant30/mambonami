import { useCallback, useState } from 'react'

export function useAuthRequest<TArgs extends unknown[], TResult>(request: (...args: TArgs) => Promise<TResult>) {
	const [isLoading, setIsLoading] = useState(false)
	const [error, setError] = useState<unknown>(null)

	const execute = useCallback(async (...args: TArgs) => {
		setIsLoading(true)
		setError(null)
		try {
			return await request(...args)
		} catch (requestError) {
			setError(requestError)
			throw requestError
		} finally {
			setIsLoading(false)
		}
	}, [request])

	return { execute, isLoading, error }
}