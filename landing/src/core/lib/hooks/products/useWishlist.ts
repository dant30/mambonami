import { useEffect, useState } from 'react'

import { listWishlist } from '../../services'
import { productStore } from '../../stores'
import type { WishlistItem } from '../../types'

export function useWishlist(enabled = true) {
	const cachedItems = productStore.getWishlist()
	const [items, setItems] = useState<WishlistItem[]>(cachedItems)
	const [isLoading, setIsLoading] = useState(enabled && cachedItems.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		if (!enabled) {
			setIsLoading(false)
			return
		}
		let active = true
		setIsLoading(true)
		setError(null)

		listWishlist()
			.then((nextItems) => {
				if (!active) return
				productStore.setWishlist(nextItems)
				setItems(nextItems)
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
	}, [enabled])

	return { items, isLoading, error, isEmpty: !isLoading && items.length === 0 }
}
