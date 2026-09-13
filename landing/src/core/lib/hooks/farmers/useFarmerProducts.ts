import { useEffect, useState } from 'react'

import { listFarmerProductsForWorkspace } from '../../services'
import { farmerStore } from '../../stores'
import type { Product } from '../../types'

export function useFarmerProductsWorkspace(enabled = true) {
	const cached = farmerStore.getProducts()
	const [products, setProducts] = useState<Product[]>(cached)
	const [isLoading, setIsLoading] = useState(enabled && cached.length === 0)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		listFarmerProductsForWorkspace().then((next) => { if (active) { farmerStore.setProducts(next); setProducts(next) } }).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { products, isLoading, error, isEmpty: !isLoading && products.length === 0 }
}
