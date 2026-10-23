import { useEffect, useState, type FormEvent } from 'react'

import { updateAdminProduct } from '../../../../../core/lib'
import { useProductCategories, useProductUnits } from '../../../../../core/lib'
import type { AdminProduct } from '../../../../../core/lib/types/admin'
import { Button, Input, Modal, Select, Textarea } from '../../../../../shared/components/ui'

export function ProductEditModal({ product, onClose, onSaved }: { product: AdminProduct | null; onClose: () => void; onSaved: () => void }) {
	const [saving, setSaving] = useState(false)
	const [error, setError] = useState('')
	const [active, setActive] = useState(true)
	const [organic, setOrganic] = useState(false)
	const [category, setCategory] = useState('')
	const [unit, setUnit] = useState('')
	const { categories } = useProductCategories()
	const { units } = useProductUnits()

	useEffect(() => {
		if (!product) return
		setActive(product.is_active !== false)
		setOrganic(product.is_organic === true)
		setCategory(String(product.category_detail?.id ?? (typeof product.category === 'number' ? product.category : '')))
		setUnit(product.unit)
	}, [product])

	const submit = async (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		if (!product) return
		if (!category) {
			setError('Choose a product category.')
			return
		}
		const values = new FormData(event.currentTarget)
		setSaving(true)
		setError('')
		try {
			const shelfLife = String(values.get('shelf_life_days') || '').trim()
			const weightPerUnit = String(values.get('weight_per_unit') || '').trim()
			const pickupLatitude = String(values.get('pickup_lat') || '').trim()
			const pickupLongitude = String(values.get('pickup_lng') || '').trim()
			await updateAdminProduct(product.uuid, {
				name: String(values.get('name') || '').trim(),
				variety: String(values.get('variety') || '').trim(),
				category: Number(category),
				price_per_unit: String(values.get('price_per_unit') || ''),
				available_quantity: String(values.get('available_quantity') || ''),
				unit,
				harvest_date: String(values.get('harvest_date') || ''),
				shelf_life_days: shelfLife ? Number(shelfLife) : null,
				weight_per_unit: weightPerUnit ? Number(weightPerUnit) : null,
				pickup_lat: pickupLatitude || null,
				pickup_lng: pickupLongitude || null,
				is_organic: organic,
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
				<label className="block text-sm font-semibold text-foreground">Category<Select aria-label="Product category" required value={category} onChange={setCategory} options={categories.map((item) => ({ value: String(item.id), label: item.name }))} className="mt-1" /></label>
				<label className="block text-sm font-semibold text-foreground">Unit<Select aria-label="Product unit" value={unit} onChange={setUnit} options={units.map((item) => ({ value: item.code, label: item.name }))} className="mt-1" /></label>
				<FormField name="price_per_unit" label="Price per unit (KES)" value={String(product.price_per_unit)} type="number" min="0.01" step="0.01" required />
				<FormField name="available_quantity" label="Available quantity" value={String(product.available_quantity)} type="number" min="0" step="0.01" required />
				<FormField name="harvest_date" label="Harvest date" value={product.harvest_date || ''} type="date" />
				<FormField name="shelf_life_days" label="Shelf life (days)" value={product.shelf_life_days == null ? '' : String(product.shelf_life_days)} type="number" min="0" step="1" />
				<FormField name="weight_per_unit" label="Weight per unit (kg)" value={product.weight_per_unit == null ? '' : String(product.weight_per_unit)} type="number" min="0" step="0.01" />
				<FormField name="pickup_lat" label="Pickup latitude" value={product.pickup_lat == null ? '' : String(product.pickup_lat)} type="number" step="0.000001" />
				<FormField name="pickup_lng" label="Pickup longitude" value={product.pickup_lng == null ? '' : String(product.pickup_lng)} type="number" step="0.000001" />
			</div>
			<label className="flex items-center gap-3 text-sm font-semibold text-foreground"><input type="checkbox" checked={organic} onChange={(event) => setOrganic(event.target.checked)} className="h-4 w-4 accent-primary" />Certified organic listing</label>
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