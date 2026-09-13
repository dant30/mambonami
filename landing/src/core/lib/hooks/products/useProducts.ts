import { useEffect, useState } from 'react'

import { listProducts } from '../../services'
import { productStore } from '../../stores'
import type { Product, ProductListParams } from '../../types'

export function useProducts(params: ProductListParams = {}) {
	const cachedProducts = productStore.getProducts()
	const [products, setProducts] = useState<Product[]>(cachedProducts)
	const [pageInfo, setPageInfo] = useState({ count: cachedProducts.length, next: null as string | null, previous: null as string | null })
	const [isLoading, setIsLoading] = useState(cachedProducts.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		setError(null)
		listProducts(params)
			.then((response) => {
				if (!active) return
				const nextProducts = response.results ?? []
				productStore.setProducts(nextProducts)
				setProducts(nextProducts)
				setPageInfo({ count: response.count ?? nextProducts.length, next: response.next ?? null, previous: response.previous ?? null })
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
	}, [params.category, params.is_organic, params.min_price, params.max_price, params.min_rating, params.in_stock, params.page, params.page_size, params.search, params.ordering])

	return { products, ...pageInfo, isLoading, error, isEmpty: !isLoading && products.length === 0 }
}
