import { useEffect, useState, type FormEvent } from 'react'

import { updateAdminProduct } from '../../../../../core/lib'
import type { AdminProduct } from '../../../../../core/lib/types/admin'
import { Button, Input, Modal, Textarea } from '../../../../../shared/components/ui'

export function ProductEditModal({ product, onClose, onSaved }: { product: AdminProduct | null; onClose: () => void; onSaved: () => void }) {
	const [saving, setSaving] = useState(false)
	const [error, setError] = useState('')
	const [active, setActive] = useState(true)

	useEffect(() => {
		if (product) setActive(product.is_active !== false)
	}, [product])

	const submit = async (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		if (!product) return
		const values = new FormData(event.currentTarget)
		setSaving(true)
		setError('')
		try {
			await updateAdminProduct(product.uuid, {
				name: String(values.get('name') || '').trim(),
				variety: String(values.get('variety') || '').trim(),
				price_per_unit: String(values.get('price_per_unit') || ''),
				available_quantity: String(values.get('available_quantity') || ''),
				harvest_date: String(values.get('harvest_date') || ''),
				description: String(values.get('description') || '').trim(),
				is_active: active,
			})
			onSaved()
		} catch (requestError) {
			setError(requestError instanceof Error ? requestError.message : 'Could not update product details.')
		} finally {
			setSaving(false)
		}
	}

	return <Modal isOpen={Boolean(product)} onClose={() => saving ? undefined : onClose()} title="Edit product" subtitle={product?.sku || product?.uuid} maxWidth="lg">
		{product && <form onSubmit={(event) => void submit(event)} className="space-y-4">
			<div className="grid gap-4 sm:grid-cols-2">
				<FormField name="name" label="Product name" value={product.name} required />
				<FormField name="variety" label="Variety" value={product.variety || ''} />
				<FormField name="price_per_unit" label="Price per unit (KES)" value={String(product.price_per_unit)} type="number" min="0.01" step="0.01" required />
				<FormField name="available_quantity" label="Available quantity" value={String(product.available_quantity)} type="number" min="0" step="0.01" required />
				<FormField name="harvest_date" label="Harvest date" value={product.harvest_date || ''} type="date" />
			</div>
			<label className="flex items-center gap-3 text-sm font-semibold text-foreground"><input type="checkbox" checked={active} onChange={(event) => setActive(event.target.checked)} className="h-4 w-4 accent-primary" />Visible in the marketplace</label>
			<label className="block text-sm font-semibold">Description<Textarea name="description" defaultValue={product.description || ''} rows={4} className="mt-1" /></label>
			{error && <p role="alert" className="text-sm text-destructive">{error}</p>}
			<div className="flex justify-end gap-2 border-t border-border pt-4"><Button type="button" variant="outline" disabled={saving} onClick={onClose}>Cancel</Button><Button type="submit" isLoading={saving}>Save product</Button></div>
		</form>}
	</Modal>
}

function FormField({ name, label, value, type = 'text', required = false, min, step }: { name: string; label: string; value: string; type?: string; required?: boolean; min?: string; step?: string }) {
	return <label className="block text-sm font-semibold text-foreground">{label}<Input name={name} type={type} min={min} step={step} defaultValue={value} required={required} className="mt-1" /></label>
}