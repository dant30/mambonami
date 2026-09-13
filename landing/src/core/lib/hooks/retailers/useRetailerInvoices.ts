import { useEffect, useState } from 'react'

import { deriveRetailerInvoices, listRetailerOrders } from '../../services'
import { retailerStore } from '../../stores'
import type { RetailerInvoice } from '../../types'

export function useRetailerInvoices(enabled = true) {
	const cached = retailerStore.getInvoices()
	const [invoices, setInvoices] = useState<RetailerInvoice[]>(cached)
	const [isLoading, setIsLoading] = useState(enabled && cached.length === 0)
	const [error, setError] = useState<unknown>(null)
	useEffect(() => {
		if (!enabled) { setIsLoading(false); return }
		let active = true
		setIsLoading(true)
		setError(null)
		listRetailerOrders().then((orders) => {
			if (!active) return
			const next = deriveRetailerInvoices(orders)
			retailerStore.setOrders(orders)
			retailerStore.setInvoices(next)
			setInvoices(next)
		}).catch((requestError: unknown) => { if (active) setError(requestError) }).finally(() => { if (active) setIsLoading(false) })
		return () => { active = false }
	}, [enabled])
	return { invoices, isLoading, error, isEmpty: !isLoading && invoices.length === 0 }
}
