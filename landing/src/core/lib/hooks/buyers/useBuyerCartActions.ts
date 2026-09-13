import { useState } from 'react'

import { addBuyerCartItem, clearBuyerCart, removeBuyerCartItem, updateBuyerCartItem } from '../../services'
import type { CartItemInput } from '../../types'

export function useBuyerCartActions() {
	const [isBusy, setIsBusy] = useState(false)
	const [error, setError] = useState<unknown>(null)
	const run = async <T,>(action: () => T) => {
		setIsBusy(true)
		setError(null)
		try { return action() } catch (requestError) { setError(requestError); throw requestError } finally { setIsBusy(false) }
	}
	return {
		isBusy,
		error,
		add: (item: CartItemInput) => run(() => addBuyerCartItem(item)),
		update: (uuid: string, quantity: string | number) => run(() => updateBuyerCartItem(uuid, quantity)),
		remove: (uuid: string) => run(() => removeBuyerCartItem(uuid)),
		clear: () => run(() => clearBuyerCart()),
	}
}
