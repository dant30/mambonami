import { useEffect, useState } from 'react'

import { listFarmerProducts } from '../../services'
import { productStore } from '../../stores'
import type { Product } from '../../types'

export function useFarmerProducts() {
	const cachedProducts = productStore.getFarmerProducts()
	const [products, setProducts] = useState<Product[]>(cachedProducts)
	const [isLoading, setIsLoading] = useState(cachedProducts.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		setError(null)

		listFarmerProducts()
			.then((nextProducts) => {
				if (!active) return
				productStore.setFarmerProducts(nextProducts)
				setProducts(nextProducts)
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
	}, [])

	return { products, isLoading, error, isEmpty: !isLoading && products.length === 0 }
}
