import { useEffect, useState } from 'react'

import { getProduct } from '../../services'
import type { Product } from '../../types'

export function useProduct(uuid: string) {
	const [product, setProduct] = useState<Product | null>(null)
	const [isLoading, setIsLoading] = useState(Boolean(uuid))
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		if (!uuid) {
			setProduct(null)
			setIsLoading(false)
			return
		}

		let active = true
		setIsLoading(true)
		setError(null)

		getProduct(uuid)
			.then((nextProduct) => {
				if (active) setProduct(nextProduct)
			})
			.catch((requestError: unknown) => {
				if (active) setError(requestError)
			})
			.finally(() => {
				if (active) setIsLoading(false)
			})

		return () => {
			active = false
		}
	}, [uuid])

	return { product, isLoading, error }
}
