import { ArrowLeft, ImagePlus, MapPin, Package, Sprout } from 'lucide-react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { useEffect, useMemo, useState } from 'react'
import type { FormEvent } from 'react'

import { createFarmerProduct, updateFarmerProduct, useFarmerProductsWorkspace, useProductCategories, useProductUnits } from '../../../core/lib'
import type { Product, ProductCreateInput } from '../../../core/lib'
import { getErrorMessage, isApiError } from '../../../core/utils'
import type { Coordinates } from '../../../core/utils'
import { FormActions, FormField, FormSection, ValidationErrors } from '../../../shared/components/forms'
import { MapPicker } from '../../../shared/components/ui'

interface ProductFormState {
	name: string
	variety: string
	category: string
	price_per_unit: string
	available_quantity: string
	unit: string
	harvest_date: string
	shelf_life_days: string
	weight_per_unit: string
	description: string
	is_organic: boolean
	is_active: boolean
}

type FieldErrors = Record<string, string>

function without(errors: FieldErrors, key: string): FieldErrors {
	if (!(key in errors)) return errors
	const next = { ...errors }
	delete next[key]
	return next
}

const MAX_IMAGE_BYTES = 5 * 1024 * 1024
const FALLBACK_UNITS = ['kg', 'piece', 'litre', 'tray', 'bunch', 'bag', 'crate', 'box'].map((code) => ({ code, name: code }))
const inputClass = 'mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 outline-none focus:ring-2 focus:ring-primary'

function localToday() {
	const now = new Date()
	return new Date(now.getTime() - now.getTimezoneOffset() * 60000).toISOString().slice(0, 10)
}

function emptyForm(): ProductFormState {
	return { name: '', variety: '', category: '', price_per_unit: '', available_quantity: '', unit: 'kg', harvest_date: localToday(), shelf_life_days: '3', weight_per_unit: '0', description: '', is_organic: false, is_active: true }
}

function toFormState(product: Product): ProductFormState {
	return {
		name: product.name,
		variety: product.variety ?? '',
		category: String(product.category ?? product.category_detail?.id ?? ''),
		price_per_unit: String(product.price_per_unit),
		available_quantity: String(product.available_quantity),
		unit: product.unit,
		harvest_date: product.harvest_date ?? localToday(),
		shelf_life_days: String(product.shelf_life_days ?? 3),
		weight_per_unit: String(product.weight_per_unit ?? 0),
		description: product.description ?? '',
		is_organic: Boolean(product.is_organic),
		is_active: product.is_active !== false,
	}
}

function toLocation(product: Product): Coordinates | null {
	const latitude = Number(product.pickup_lat)
	const longitude = Number(product.pickup_lng)
	return product.pickup_lat == null || product.pickup_lng == null || !Number.isFinite(latitude) || !Number.isFinite(longitude) ? null : { latitude, longitude }
}

/** Maps DRF field errors ({ field: ['msg'] }) onto form fields; anything else becomes a general message. */
function toFieldErrors(error: unknown): FieldErrors {
	if (isApiError(error) && error.data && typeof error.data === 'object' && !Array.isArray(error.data)) {
		const entries = Object.entries(error.data as Record<string, unknown>).flatMap(([field, value]) => {
			const message = Array.isArray(value) ? value.find((item) => typeof item === 'string') : value
			return typeof message === 'string' ? [[field === 'detail' || field === 'non_field_errors' ? 'form' : field, message] as const] : []
		})
		if (entries.length > 0) return Object.fromEntries(entries)
	}
	return { form: getErrorMessage(error, 'We could not save this product. Check the details and try again.') }
}

export function FarmerProductEditorPage() {
	const navigate = useNavigate()
	const { id } = useParams()
	const editing = Boolean(id)
	const { products, isLoading: productsLoading } = useFarmerProductsWorkspace()
	const { categories, isLoading: categoriesLoading } = useProductCategories()
	const { units } = useProductUnits()
	const [form, setForm] = useState<ProductFormState>(emptyForm)
	const [location, setLocation] = useState<Coordinates | null>(null)
	const [reservedQuantity, setReservedQuantity] = useState(0)
	const [image, setImage] = useState<File | null>(null)
	const [imagePreview, setImagePreview] = useState<string | null>(null)
	const [isSaving, setIsSaving] = useState(false)
	const [errors, setErrors] = useState<FieldErrors>({})
	const [loadedId, setLoadedId] = useState<string | null>(null)

	const editingProduct = useMemo(() => products.find((item) => item.uuid === id), [id, products])
	const unitOptions = units.length > 0 ? units : FALLBACK_UNITS

	// Hydrate once per product so background refreshes never overwrite what the farmer is typing.
	useEffect(() => {
		if (!id) {
			setForm(emptyForm())
			setLocation(null)
			setReservedQuantity(0)
			setImage(null)
			setImagePreview(null)
			setLoadedId(null)
			return
		}
		if (!editingProduct || loadedId === id) return
		setForm(toFormState(editingProduct))
		setLocation(toLocation(editingProduct))
		setReservedQuantity(Number(editingProduct.reserved_quantity ?? 0))
		setImagePreview(editingProduct.image_url || editingProduct.image || null)
		setLoadedId(id)
	}, [id, editingProduct, loadedId])

	useEffect(() => () => { if (imagePreview?.startsWith('blob:')) URL.revokeObjectURL(imagePreview) }, [imagePreview])

	const update = <Key extends keyof ProductFormState>(key: Key, value: ProductFormState[Key]) => {
		setForm((current) => ({ ...current, [key]: value }))
		setErrors((current) => without(current, key))
	}
	const selectImage = (file: File | undefined) => {
		if (!file) return
		if (!['image/jpeg', 'image/png', 'image/webp'].includes(file.type)) { setErrors((current) => ({ ...current, image: 'Choose a JPG, PNG or WebP image.' })); return }
		if (file.size > MAX_IMAGE_BYTES) { setErrors((current) => ({ ...current, image: 'Image must be 5 MB or smaller.' })); return }
		setErrors((current) => without(current, 'image'))
		setImage(file)
		setImagePreview(URL.createObjectURL(file))
	}
	const validate = (): FieldErrors => {
		const next: FieldErrors = {}
		if (!form.name.trim()) next.name = 'Product name is required.'
		if (!form.category) next.category = 'Choose a product category.'
		if (!form.harvest_date) next.harvest_date = 'Harvest date is required.'
		else if (form.harvest_date > localToday()) next.harvest_date = 'Harvest date cannot be in the future.'
		if (!(Number(form.price_per_unit) > 0)) next.price_per_unit = 'Price must be greater than zero.'
		if (form.available_quantity === '' || Number(form.available_quantity) < 0) next.available_quantity = 'Enter the quantity available (0 or more).'
		else if (Number(form.available_quantity) < reservedQuantity) next.available_quantity = `${reservedQuantity} ${form.unit} is already reserved by open orders.`
		if (!(Number(form.shelf_life_days) >= 1)) next.shelf_life_days = 'Shelf life must be at least one day.'
		if (Number(form.weight_per_unit) < 0) next.weight_per_unit = 'Weight cannot be negative.'
		return next
	}
	const submit = async (event: FormEvent) => {
		event.preventDefault()
		const clientErrors = validate()
		if (Object.keys(clientErrors).length > 0) { setErrors(clientErrors); return }
		setErrors({})
		setIsSaving(true)
		try {
			const input: ProductCreateInput = {
				name: form.name.trim(),
				variety: form.variety.trim(),
				category: form.category,
				price_per_unit: form.price_per_unit,
				available_quantity: form.available_quantity,
				reserved_quantity: reservedQuantity,
				unit: form.unit,
				harvest_date: form.harvest_date,
				shelf_life_days: form.shelf_life_days,
				weight_per_unit: form.weight_per_unit,
				pickup_lat: location ? location.latitude : null,
				pickup_lng: location ? location.longitude : null,
				description: form.description.trim(),
				is_organic: form.is_organic,
				is_active: form.is_active,
				image: image ?? undefined,
			}
			if (editing && id) await updateFarmerProduct(id, input)
			else await createFarmerProduct(input)
			navigate('/app/farmer/products')
		} catch (requestError) {
			setErrors(toFieldErrors(requestError))
		} finally { setIsSaving(false) }
	}

	if (editing && productsLoading && !editingProduct) return <main className="mx-auto max-w-3xl px-4 py-16 sm:px-6 lg:px-8"><div className="h-96 animate-pulse rounded-2xl bg-muted" /></main>
	if (editing && !productsLoading && !editingProduct) {
		return (
			<main className="mx-auto max-w-2xl px-4 py-24 text-center">
				<h1 className="text-3xl font-semibold text-primary-dark">We could not find that product.</h1>
				<p className="mt-3 text-sm text-muted-foreground">It may have been removed from your listings.</p>
				<Link to="/app/farmer/products" className="mt-8 inline-flex rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground">Back to my products</Link>
			</main>
		)
	}

	const generalErrors = Object.entries(errors).filter(([field]) => !(field in form) && !['image', 'pickup_lat', 'pickup_lng'].includes(field)).map(([, message]) => message)
	const text = (key: keyof ProductFormState) => String(form[key])

	return (
		<main className="mx-auto max-w-3xl px-4 py-10 sm:px-6 lg:px-8">
			<Link to="/app/farmer/products" className="inline-flex items-center gap-2 text-sm font-bold text-primary"><ArrowLeft className="h-4 w-4" />Back to products</Link>
			<div className="mt-8">
				<p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Farm inventory</p>
				<h1 className="mt-2 text-3xl font-semibold text-primary-dark">{editing ? 'Edit product' : 'Add a product'}</h1>
				<p className="mt-3 text-sm text-muted-foreground">Capture the details buyers and transporters need to trust, order and collect your harvest.</p>
			</div>

			<form id="farmer-product-form" onSubmit={(event) => void submit(event)} noValidate className="mt-8 rounded-2xl border border-border bg-card p-6 sm:p-8">
				<ValidationErrors errors={generalErrors} />

				<FormSection title="Product identity" description="Name and classify the harvest buyers will see." icon={<Sprout className="h-4 w-4" />}>
					<div className="grid gap-5 sm:grid-cols-2">
						<FormField label="Product name" htmlFor="product-name" required error={errors.name}>
							<input id="product-name" value={form.name} onChange={(event) => update('name', event.target.value)} className={inputClass} />
						</FormField>
						<FormField label="Variety" htmlFor="product-variety" helperText="Optional, for example Roma or Ngowe." error={errors.variety}>
							<input id="product-variety" value={form.variety} onChange={(event) => update('variety', event.target.value)} className={inputClass} />
						</FormField>
						<FormField label="Category" htmlFor="product-category" required error={errors.category}>
							<select id="product-category" disabled={categoriesLoading} value={form.category} onChange={(event) => update('category', event.target.value)} className={inputClass}>
								<option value="">{categoriesLoading ? 'Loading categories...' : 'Select a category'}</option>
								{categories.map((category) => <option key={category.id} value={String(category.id)}>{category.name}</option>)}
							</select>
						</FormField>
						<label className="flex items-center gap-3 self-end rounded-xl border border-border px-4 py-3 text-sm font-semibold text-foreground">
							<input type="checkbox" checked={form.is_organic} onChange={(event) => update('is_organic', event.target.checked)} className="h-4 w-4 accent-primary" />
							Grown organically
						</label>
					</div>
				</FormSection>

				<FormSection title="Pricing and stock" description="Set what you charge and how much is ready to sell." icon={<Package className="h-4 w-4" />}>
					<div className="grid gap-5 sm:grid-cols-2">
						<NumberField id="product-price" label="Price per unit (KSh)" value={text('price_per_unit')} onChange={(value) => update('price_per_unit', value)} required min="0" error={errors.price_per_unit} />
						<FormField label="Unit" htmlFor="product-unit" required error={errors.unit}>
							<select id="product-unit" value={form.unit} onChange={(event) => update('unit', event.target.value)} className={inputClass}>
								{unitOptions.map((unit) => <option key={unit.code} value={unit.code}>{unit.name}</option>)}
							</select>
						</FormField>
						<NumberField id="product-quantity" label="Quantity available" value={text('available_quantity')} onChange={(value) => update('available_quantity', value)} required min="0" error={errors.available_quantity} helperText={reservedQuantity > 0 ? `${reservedQuantity} ${form.unit} is currently reserved by open orders.` : undefined} />
						<NumberField id="product-weight" label="Weight per unit (kg)" value={text('weight_per_unit')} onChange={(value) => update('weight_per_unit', value)} min="0" error={errors.weight_per_unit} helperText="Used to plan transport capacity. Leave 0 if the unit is already in kg." />
					</div>
				</FormSection>

				<FormSection title="Freshness" description="Buyers see the harvest date and remaining shelf life." icon={<Sprout className="h-4 w-4" />}>
					<div className="grid gap-5 sm:grid-cols-2">
						<FormField label="Harvest date" htmlFor="product-harvest" required error={errors.harvest_date}>
							<input id="product-harvest" type="date" max={localToday()} value={form.harvest_date} onChange={(event) => update('harvest_date', event.target.value)} className={inputClass} />
						</FormField>
						<NumberField id="product-shelf-life" label="Shelf life (days)" value={text('shelf_life_days')} onChange={(value) => update('shelf_life_days', value)} required min="1" step="1" error={errors.shelf_life_days} />
					</div>
				</FormSection>

				<FormSection title="Pickup location" description="Drop a pin where the harvest will be collected. Transporters and delivery fees are based on this point." icon={<MapPin className="h-4 w-4" />}>
					<MapPicker label="Harvest pickup point" value={location} onChange={setLocation} restrictToKenya helperText="Search for your village, town or landmark, tap the map, or use your current location." />
					{(errors.pickup_lat || errors.pickup_lng) && <p role="alert" className="text-xs font-medium text-destructive">{errors.pickup_lat ?? errors.pickup_lng}</p>}
					{!location && <p className="text-xs text-muted-foreground">If you skip this, your farm location from your profile is used instead.</p>}
				</FormSection>

				<FormSection title="Photo and description" description="A clear photo helps your harvest sell faster." icon={<ImagePlus className="h-4 w-4" />}>
					<FormField label="Product photo" htmlFor="product-image" helperText="JPG, PNG or WebP, up to 5 MB." error={errors.image}>
						<input id="product-image" type="file" accept="image/jpeg,image/png,image/webp" onChange={(event) => selectImage(event.target.files?.[0])} className="mt-2 block w-full text-sm file:mr-4 file:rounded-full file:border-0 file:bg-primary file:px-4 file:py-2 file:text-sm file:font-semibold file:text-primary-foreground" />
					</FormField>
					{imagePreview && <img src={imagePreview} alt="Product preview" className="h-40 w-40 rounded-2xl border border-border object-cover" />}
					<FormField label="Description" htmlFor="product-description" error={errors.description}>
						<textarea id="product-description" rows={4} value={form.description} onChange={(event) => update('description', event.target.value)} className={inputClass} />
					</FormField>
					<label className="flex items-center gap-3 text-sm font-semibold text-foreground">
						<input type="checkbox" checked={form.is_active} onChange={(event) => update('is_active', event.target.checked)} className="h-4 w-4 accent-primary" />
						Listed and visible to buyers
					</label>
				</FormSection>

				<FormActions formId="farmer-product-form" submitLabel={editing ? 'Save changes' : 'Publish product'} loading={isSaving} onCancel={() => navigate('/app/farmer/products')} />
			</form>
		</main>
	)
}

interface NumberFieldProps {
	id: string
	label: string
	value: string
	onChange: (value: string) => void
	required?: boolean
	min?: string
	step?: string
	error?: string
	helperText?: string
}

function NumberField({ id, label, value, onChange, required = false, min, step = '0.01', error, helperText }: NumberFieldProps) {
	return (
		<FormField label={label} htmlFor={id} required={required} error={error} helperText={helperText}>
			<input id={id} type="number" inputMode="decimal" min={min} step={step} value={value} onChange={(event) => onChange(event.target.value)} className={inputClass} />
		</FormField>
	)
}
