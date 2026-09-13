import { useEffect, useState } from 'react'

import { listProductCategories } from '../../services'
import { productStore } from '../../stores'
import type { ProductCategory } from '../../types'

export function useProductCategories() {
	const cachedCategories = productStore.getCategories()
	const [categories, setCategories] = useState<ProductCategory[]>(cachedCategories)
	const [isLoading, setIsLoading] = useState(cachedCategories.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		setError(null)

		listProductCategories()
			.then((nextCategories) => {
				if (!active) return
				productStore.setCategories(nextCategories)
				setCategories(nextCategories)
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

	return { categories, isLoading, error }
}
