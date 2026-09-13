import { useEffect, useState } from 'react'

import { getDispute } from '../../services'
import { disputeStore } from '../../stores'
import type { Dispute } from '../../types'

export function useDispute(uuid: string) {
	const [dispute, setDispute] = useState<Dispute | null>(() => disputeStore.getCurrentDispute())
	const [isLoading, setIsLoading] = useState(Boolean(uuid) && disputeStore.getCurrentDispute() === null)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		if (!uuid) {
			setDispute(null)
			setIsLoading(false)
			return
		}

		let active = true
		setIsLoading(true)
		setError(null)

		getDispute(uuid)
			.then((nextDispute) => {
				if (!active) return
				disputeStore.setCurrentDispute(nextDispute)
				setDispute(nextDispute)
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
	}, [uuid])

	return { dispute, isLoading, error }
}
