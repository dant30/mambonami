import { useEffect, useState } from 'react'

import { listRetailerProducts } from '../../services'
import { retailerStore } from '../../stores'
import type { Product } from '../../types'

export function useRetailerProducts(enabled = true) {
	const cached = retailerStore.getProducts()
	const [products, setProducts] = useState<Product[]>(cached)
	const [isLoading, setIsLoading] = useState(enabled && cached.length === 0)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		listRetailerProducts().then((next) => { if (active) { retailerStore.setProducts(next); setProducts(next) } }).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { products, isLoading, error, isEmpty: !isLoading && products.length === 0 }
}
