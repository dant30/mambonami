import { useEffect, useSyncExternalStore } from 'react'

import { orderStore } from '../../stores'

const CART_STORAGE_KEY = 'orders_cart'

export function useCartItemCount() {
	const count = useSyncExternalStore(
		orderStore.subscribeToCart,
		orderStore.getCartItemCount,
		() => 0,
	)

	useEffect(() => {
		const syncFromOtherTab = (event: StorageEvent) => {
			if (event.key === CART_STORAGE_KEY || event.key === null) orderStore.refreshCartFromStorage()
		}
		window.addEventListener('storage', syncFromOtherTab)
		return () => window.removeEventListener('storage', syncFromOtherTab)
	}, [])

	return count
}
