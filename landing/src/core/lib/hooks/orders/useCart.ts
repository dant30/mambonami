import { useEffect, useMemo, useState } from 'react'

import { getCart, getCartSummary } from '../../services'
import { orderStore } from '../../stores'
import type { CartItem, CartSummary } from '../../types'

export function useCart() {
	const initialCart = orderStore.getCart()
	const [cart, setCart] = useState<CartItem[]>(initialCart)
	const [isLoading, setIsLoading] = useState(false)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		setCart(orderStore.getCart())
	}, [])

	const summary = useMemo<CartSummary>(() => getCartSummary(cart), [cart])

	const refresh = async () => {
		setIsLoading(true)
		setError(null)

		try {
			const nextCart = getCart()
			setCart(nextCart)
			return nextCart
		} catch (requestError) {
			setError(requestError)
			throw requestError
		} finally {
			setIsLoading(false)
		}
	}

	return {
		cart,
		summary,
		isLoading,
		error,
		refresh,
		isEmpty: cart.length === 0,
	}
}
