import { useEffect, useState } from 'react'

import { listBuyerWishlist } from '../../services'
import { buyerStore } from '../../stores'
import type { WishlistItem } from '../../types'

export function useBuyerWishlist(enabled = true) {
	const cached = buyerStore.getWishlist()
	const [items, setItems] = useState<WishlistItem[]>(cached)
	const [isLoading, setIsLoading] = useState(enabled && cached.length === 0)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		listBuyerWishlist().then((next) => { if (active) { buyerStore.setWishlist(next); setItems(next) } }).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { items, isLoading, error, isEmpty: !isLoading && items.length === 0 }
}
