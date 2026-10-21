import { useEffect, useState, type FormEvent } from 'react'
import { Save } from 'lucide-react'

import type { Order, OrderStatus } from '../../../../../core/lib/types/orders'
import { Button, Modal, Select } from '../../../../../shared/components/ui'

const statuses: OrderStatus[] = ['cart', 'placed', 'paid_escrow', 'transport_assigned', 'picked_up', 'delivered', 'cancelled', 'disputed']

export function OrderStatusModal({
	order,
	busy,
	error,
	onClose,
	onSave,
}: {
	order: Order | null
	busy: boolean
	error: string
	onClose: () => void
	onSave: (status: OrderStatus) => void
}) {
	const [status, setStatus] = useState<OrderStatus>(order?.status ?? 'placed')

	useEffect(() => {
		if (order) setStatus(order.status)
	}, [order])

	const submit = (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		if (order && status !== order.status) onSave(status)
	}

	return <Modal isOpen={Boolean(order)} onClose={busy ? () => undefined : onClose} title="Update order status" subtitle={order?.account_number || order?.uuid} maxWidth="md">
		{order && <form onSubmit={submit} className="space-y-5">
			<p className="text-sm text-muted-foreground">Choose the next order status. The order state machine will validate the transition.</p>
			<Select aria-label="Order status" value={status} onChange={(value) => setStatus(value as OrderStatus)} options={statuses.map((value) => ({ value, label: value.replaceAll('_', ' ') }))} />
			{error && <p role="alert" className="text-sm text-destructive">{error}</p>}
			<div className="flex justify-end gap-2 border-t border-border pt-4">
				<Button type="button" variant="outline" disabled={busy} onClick={onClose}>Cancel</Button>
				<Button type="submit" isLoading={busy} disabled={busy || status === order.status} leftIcon={<Save className="h-4 w-4" />}>Save status</Button>
			</div>
		</form>}
	</Modal>
}