import { useEffect, useState } from 'react'

import { listProductUnits } from '../../services'
import { productStore } from '../../stores'
import type { ProductUnitOption } from '../../types'

export function useProductUnits() {
	const cachedUnits = productStore.getUnits()
	const [units, setUnits] = useState<ProductUnitOption[]>(cachedUnits)
	const [isLoading, setIsLoading] = useState(cachedUnits.length === 0)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		let active = true
		setIsLoading(true)
		setError(null)

		listProductUnits()
			.then((nextUnits) => {
				if (!active) return
				productStore.setUnits(nextUnits)
				setUnits(nextUnits)
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

	return { units, isLoading, error }
}
