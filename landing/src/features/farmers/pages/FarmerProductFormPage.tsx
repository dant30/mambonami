import { ArrowLeft, ImagePlus, Package, Sprout } from 'lucide-react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { useEffect, useState } from 'react'

import { createFarmerProduct, updateFarmerProduct, useFarmerProductsWorkspace, useProductCategories } from '../../../core/lib'
import type { ProductCreateInput } from '../../../core/lib'
import { FormActions, FormField, FormSection, ValidationErrors } from '../../../shared/components/forms'

interface ProductFormState {
	name: string
	variety: string
	category: string
	price_per_unit: string
	available_quantity: string
	reserved_quantity: string
	unit: string
	harvest_date: string
	shelf_life_days: string
	weight_per_unit: string
	pickup_lat: string
	pickup_lng: string
	description: string
	is_organic: boolean
	is_active: boolean
}

const today = new Date().toISOString().slice(0, 10)
const initialForm: ProductFormState = { name: '', variety: '', category: '', price_per_unit: '', available_quantity: '', reserved_quantity: '0', unit: 'kg', harvest_date: today, shelf_life_days: '3', weight_per_unit: '0', pickup_lat: '', pickup_lng: '', description: '', is_organic: false, is_active: true }

function toFormState(product: NonNullable<ReturnType<typeof useFarmerProductsWorkspace>['products']>[number]): ProductFormState {
	return { name: product.name, variety: product.variety ?? '', category: String(product.category ?? ''), price_per_unit: String(product.price_per_unit), available_quantity: String(product.available_quantity), reserved_quantity: String(product.reserved_quantity ?? 0), unit: product.unit, harvest_date: product.harvest_date ?? today, shelf_life_days: String(product.shelf_life_days ?? 3), weight_per_unit: String(product.weight_per_unit ?? 0), pickup_lat: product.pickup_lat == null ? '' : String(product.pickup_lat), pickup_lng: product.pickup_lng == null ? '' : String(product.pickup_lng), description: product.description ?? '', is_organic: Boolean(product.is_organic), is_active: product.is_active !== false }
}

export function FarmerProductFormPage() {
	const navigate = useNavigate()
	const { id } = useParams()
	const editing = Boolean(id)
	const { products, isLoading: productsLoading } = useFarmerProductsWorkspace()
	const { categories, isLoading: categoriesLoading } = useProductCategories()
	const [form, setForm] = useState<ProductFormState>(initialForm)
	const [image, setImage] = useState<File | null>(null)
	const [imagePreview, setImagePreview] = useState<string | null>(null)
	const [isSaving, setIsSaving] = useState(false)
	const [errors, setErrors] = useState<string[] | Record<string, string>>([])

	useEffect(() => {
		if (!id) return
		const product = products.find((item) => item.uuid === id)
		if (product) {
			setForm(toFormState(product))
			setImagePreview(product.image_url || product.image || null)
		}
	}, [id, products])

	const update = <Key extends keyof ProductFormState>(key: Key, value: ProductFormState[Key]) => setForm((current) => ({ ...current, [key]: value }))
	const selectImage = (file: File | undefined) => {
		if (!file) return
		setImage(file)
		setImagePreview(URL.createObjectURL(file))
	}
	const validate = () => {
		const nextErrors: Record<string, string> = {}
		if (!form.name.trim()) nextErrors.name = 'Product name is required.'
		if (!form.category) nextErrors.category = 'Choose a product category.'
		if (!form.harvest_date) nextErrors.harvest_date = 'Harvest date is required.'
		if (Number(form.price_per_unit) <= 0) nextErrors.price_per_unit = 'Price must be greater than zero.'
		if (Number(form.available_quantity) < 0) nextErrors.available_quantity = 'Available quantity cannot be negative.'
		if (Number(form.reserved_quantity) < 0 || Number(form.reserved_quantity) > Number(form.available_quantity)) nextErrors.reserved_quantity = 'Reserved quantity cannot exceed available quantity.'
		if (Number(form.shelf_life_days) < 1) nextErrors.shelf_life_days = 'Shelf life must be at least one day.'
		return nextErrors
	}
	const submit = async (event: React.FormEvent) => {
		event.preventDefault()
		const clientErrors = validate()
		if (Object.keys(clientErrors).length > 0) { setErrors(clientErrors); return }
		setErrors([])
		setIsSaving(true)
		try {
			const input: ProductCreateInput = { name: form.name.trim(), variety: form.variety.trim(), category: form.category, price_per_unit: form.price_per_unit, available_quantity: form.available_quantity, reserved_quantity: form.reserved_quantity, unit: form.unit, harvest_date: form.harvest_date, shelf_life_days: form.shelf_life_days, weight_per_unit: form.weight_per_unit, pickup_lat: form.pickup_lat || null, pickup_lng: form.pickup_lng || null, description: form.description.trim(), is_organic: form.is_organic, is_active: form.is_active, image: image ?? undefined }
			if (editing && id) await updateFarmerProduct(id, input)
			else await createFarmerProduct(input)
			navigate('/app/farmer/products')
		} catch (requestError) {
			setErrors([requestError instanceof Error ? requestError.message : 'We could not save this product. Check the details and try again.'])
		} finally { setIsSaving(false) }
	}

	if (editing && productsLoading) return <main className="mx-auto max-w-3xl px-4 py-16 sm:px-6 lg:px-8"><div className="h-96 animate-pulse rounded-2xl bg-muted" /></main>
	return <main className="mx-auto max-w-3xl px-4 py-10 sm:px-6 lg:px-8"><Link to="/app/farmer/products" className="inline-flex items-center gap-2 text-sm font-bold text-primary"><ArrowLeft className="h-4 w-4" />Back to products</Link><div className="mt-8"><p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Farm inventory</p><h1 className="mt-2 text-3xl font-semibold text-primary-dark">{editing ? 'Edit product' : 'Add a product'}</h1><p className="mt-3 text-sm text-muted-foreground">Capture the details buyers and fulfilment teams need to trust and order your harvest.</p></div><form id="farmer-product-form" onSubmit={submit} className="mt-8 rounded-2xl border border-border bg-card p-6 sm:p-8"><ValidationErrors errors={errors} /><FormSection title="Product identity" description="Name and classify the harvest buyers will see." icon={<Sprout className="h-4 w-4" />}><div className="grid gap-5 sm:grid-cols-2"><FormField label="Product name" htmlFor="product-name" required error={typeof errors === 'object' && !Array.isArray(errors) ? errors.name : undefined}><input id="product-name" required value={form.name} onChange={(event) => update('name', event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 outline-none focus:ring-2 focus:ring-primary" /></FormField><FormField label="Variety" htmlFor="product-variety" helperText="Optional, for example Roma or Ngowe."><input id="product-variety" value={form.variety} onChange={(event) => update('variety', event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 outline-none focus:ring-2 focus:ring-primary" /></FormField><FormField label="Category" htmlFor="product-category" required error={typeof errors === 'object' && !Array.isArray(errors) ? errors.category : undefined}><select id="product-category" required disabled={categoriesLoading} value={form.category} onChange={(event) => update('category', event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 outline-none focus:ring-2 focus:ring-primary"><option value="">{categoriesLoading ? 'Loading categories...' : 'Choose category'}</option>{categories.map((category) => <option key={category.id} value={category.id}>{category.name}</option>)}</select></FormField><FormField label="Unit" htmlFor="product-unit" required><select id="product-unit" value={form.unit} onChange={(event) => update('unit', event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 outline-none focus:ring-2 focus:ring-primary"><option value="kg">Kilogram</option><option value="piece">Piece</option><option value="litre">Litre</option><option value="tray">Tray</option><option value="bunch">Bunch</option><option value="bag">Bag</option><option value="crate">Crate</option><option value="box">Box</option></select></FormField></div></FormSection><FormSection title="Pricing and inventory" description="Set the commercial and stock values used for ordering." icon={<Package className="h-4 w-4" />}><div className="grid gap-5 sm:grid-cols-2"><NumberField id="price-per-unit" label="Price per unit (KSh)" value={form.price_per_unit} onChange={(value) => update('price_per_unit', value)} required min="0.01" error={typeof errors === 'object' && !Array.isArray(errors) ? errors.price_per_unit : undefined} /><NumberField id="available-quantity" label="Available quantity" value={form.available_quantity} onChange={(value) => update('available_quantity', value)} required min="0" error={typeof errors === 'object' && !Array.isArray(errors) ? errors.available_quantity : undefined} /><NumberField id="reserved-quantity" label="Reserved quantity" value={form.reserved_quantity} onChange={(value) => update('reserved_quantity', value)} min="0" error={typeof errors === 'object' && !Array.isArray(errors) ? errors.reserved_quantity : undefined} /><NumberField id="weight-per-unit" label="Weight per unit (kg)" value={form.weight_per_unit} onChange={(value) => update('weight_per_unit', value)} min="0" /><NumberField id="shelf-life-days" label="Shelf life (days)" value={form.shelf_life_days} onChange={(value) => update('shelf_life_days', value)} required min="1" error={typeof errors === 'object' && !Array.isArray(errors) ? errors.shelf_life_days : undefined} /><FormField label="Harvest date" htmlFor="harvest-date" required error={typeof errors === 'object' && !Array.isArray(errors) ? errors.harvest_date : undefined}><input id="harvest-date" required type="date" max={today} value={form.harvest_date} onChange={(event) => update('harvest_date', event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 outline-none focus:ring-2 focus:ring-primary" /></FormField></div></FormSection><FormSection title="Pickup and presentation" description="Help buyers understand where the harvest comes from and how it looks." icon={<ImagePlus className="h-4 w-4" />}><div className="grid gap-5 sm:grid-cols-2"><NumberField id="pickup-lat" label="Pickup latitude" value={form.pickup_lat} onChange={(value) => update('pickup_lat', value)} min="-12" max="5" step="any" /><NumberField id="pickup-lng" label="Pickup longitude" value={form.pickup_lng} onChange={(value) => update('pickup_lng', value)} min="34" max="42" step="any" /></div><FormField label="Description" htmlFor="product-description" helperText="Include quality, handling, and buyer-facing details."><textarea id="product-description" rows={5} value={form.description} onChange={(event) => update('description', event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 outline-none focus:ring-2 focus:ring-primary" /></FormField><FormField label="Product image" htmlFor="product-image" helperText="Upload a clear image of this harvest."><input id="product-image" type="file" accept="image/*" onChange={(event) => selectImage(event.target.files?.[0])} className="mt-2 block w-full rounded-xl border border-border bg-background px-4 py-3 text-sm" />{imagePreview && <img src={imagePreview} alt="Product preview" className="mt-3 h-32 w-32 rounded-xl object-cover" />}</FormField><div className="flex flex-wrap gap-6"><label className="flex items-center gap-2 text-sm font-semibold text-primary-dark"><input type="checkbox" checked={form.is_organic} onChange={(event) => update('is_organic', event.target.checked)} className="accent-primary" />Organic certified</label><label className="flex items-center gap-2 text-sm font-semibold text-primary-dark"><input type="checkbox" checked={form.is_active} onChange={(event) => update('is_active', event.target.checked)} className="accent-primary" />Visible to buyers</label></div></FormSection><FormActions formId="farmer-product-form" submitLabel={editing ? 'Save product changes' : 'Publish product'} loading={isSaving} onCancel={() => navigate('/app/farmer/products')} /></form></main>
}

function NumberField({ id, label, value, onChange, required = false, min, max, step = '0.01', error }: { id: string; label: string; value: string; onChange: (value: string) => void; required?: boolean; min?: string; max?: string; step?: string; error?: string }) { return <FormField label={label} htmlFor={id} required={required} error={error}><input id={id} required={required} type="number" min={min} max={max} step={step} value={value} onChange={(event) => onChange(event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 outline-none focus:ring-2 focus:ring-primary" /></FormField> }
