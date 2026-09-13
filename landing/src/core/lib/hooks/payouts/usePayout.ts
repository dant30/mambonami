import { useEffect, useState } from 'react'

import { getPayout } from '../../services'
import { payoutStore } from '../../stores'
import type { Payout } from '../../types'

export function usePayout(uuid: string) {
	const [payout, setPayout] = useState<Payout | null>(() => payoutStore.getCurrentPayout())
	const [isLoading, setIsLoading] = useState(Boolean(uuid) && payoutStore.getCurrentPayout() === null)
	const [error, setError] = useState<unknown>(null)

	useEffect(() => {
		if (!uuid) {
			setPayout(null)
			setIsLoading(false)
			return
		}

		let active = true
		setIsLoading(true)
		setError(null)

		getPayout(uuid)
			.then((nextPayout) => {
				if (!active) return
				payoutStore.setCurrentPayout(nextPayout)
				setPayout(nextPayout)
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

	return { payout, isLoading, error }
}
