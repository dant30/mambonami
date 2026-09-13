import { useState } from 'react'

import { removeBuyerSavedProduct, saveBuyerProduct } from '../../services'

export function useBuyerWishlistActions() {
	const [isBusy, setIsBusy] = useState(false)
	const [error, setError] = useState<unknown>(null)
	const run = async <T,>(action: () => Promise<T>) => {
		setIsBusy(true)
		setError(null)
		try { return await action() } catch (requestError) { setError(requestError); throw requestError } finally { setIsBusy(false) }
	}
	return {
		isBusy,
		error,
		save: (uuid: string) => run(() => saveBuyerProduct(uuid)),
		remove: (uuid: string) => run(() => removeBuyerSavedProduct(uuid)),
	}
}
