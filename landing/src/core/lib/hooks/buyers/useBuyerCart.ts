import { useEffect, useMemo, useState } from 'react'

import { getBuyerCart, getBuyerCartSummary } from '../../services'
import { buyerStore } from '../../stores'
import type { CartItem, CartSummary } from '../../types'

export function useBuyerCart() {
	const [cart, setCart] = useState<CartItem[]>(buyerStore.getCart())
	const [isLoading, setIsLoading] = useState(false)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => { const next = getBuyerCart(); buyerStore.setCart(next); buyerStore.setCartSummary(getBuyerCartSummary(next)); setCart(next) }, [])
	const summary = useMemo<CartSummary>(() => getBuyerCartSummary(cart), [cart])
	const refresh = async () => {
		setIsLoading(true)
		setError(null)
		try { const next = getBuyerCart(); buyerStore.setCart(next); buyerStore.setCartSummary(getBuyerCartSummary(next)); setCart(next); return next } catch (requestError) { setError(requestError); throw requestError } finally { setIsLoading(false) }
	}
	return { cart, summary, isLoading, error, refresh, isEmpty: cart.length === 0 }
}
