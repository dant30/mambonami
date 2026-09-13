import { useEffect, useState } from 'react'

import { deriveRetailerSuppliers, listRetailerProducts } from '../../services'
import { retailerStore } from '../../stores'
import type { RetailerSupplier } from '../../types'

export function useRetailerSuppliers(enabled = true) {
	const cached = retailerStore.getSuppliers()
	const [suppliers, setSuppliers] = useState<RetailerSupplier[]>(cached)
	const [isLoading, setIsLoading] = useState(enabled && cached.length === 0)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		listRetailerProducts().then((products) => {
			if (!active) return
			const next = deriveRetailerSuppliers(products)
			retailerStore.setProducts(products)
			retailerStore.setSuppliers(next)
			setSuppliers(next)
		}).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { suppliers, isLoading, error, isEmpty: !isLoading && suppliers.length === 0 }
}
