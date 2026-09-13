import { useState } from 'react'

import { confirmFarmerOrder, markFarmerOrderReady } from '../../services'

export function useFarmerOrderActions() {
	const [busyId, setBusyId] = useState<number | null>(null)
	const [error, setError] = useState<unknown>(null)
	const run = async <T,>(id: number, action: () => Promise<T>) => {
		setBusyId(id)
		setError(null)
		try { return await action() } catch (requestError) { setError(requestError); throw requestError } finally { setBusyId(null) }
	}
	return {
		busyId,
		error,
		confirm: (id: number) => run(id, () => confirmFarmerOrder(id, 'confirm')),
		reject: (id: number) => run(id, () => confirmFarmerOrder(id, 'reject')),
		markReady: (id: number) => run(id, () => markFarmerOrderReady(id)),
	}
}
