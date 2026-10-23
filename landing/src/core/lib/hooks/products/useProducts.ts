import { useEffect, useState } from 'react'

import { useBuyerDeliveryLocation } from '../../../hooks'
import { listProducts } from '../../services'
import { productStore } from '../../stores'
import type { Product, ProductListParams } from '../../types'

export function useProducts(params: ProductListParams = {}) {
	const { location } = useBuyerDeliveryLocation()
	const buyerLat = params.buyer_lat ?? params.lat ?? location?.latitude
	const buyerLng = params.buyer_lng ?? params.lng ?? location?.longitude
	const cachedProducts = productStore.getProducts()
	const [products, setProducts] = useState<Product[]>(location ? [] : cachedProducts)
	const [pageInfo, setPageInfo] = useState({ count: cachedProducts.length, next: null as string | null, previous: null as string | null })
	const [isLoading, setIsLoading] = useState(cachedProducts.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		setError(null)
		if (buyerLat !== undefined || buyerLng !== undefined) setProducts([])
		listProducts({ ...params, buyer_lat: buyerLat, buyer_lng: buyerLng })
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
	}, [buyerLat, buyerLng, params.category, params.is_organic, params.min_price, params.max_price, params.min_rating, params.in_stock, params.page, params.page_size, params.search, params.ordering])

	return { products, ...pageInfo, isLoading, error, isEmpty: !isLoading && products.length === 0 }
}
