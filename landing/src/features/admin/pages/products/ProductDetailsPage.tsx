import { ArrowLeft, Image, Package, Pencil } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'

import { StatCard } from '../../../../shared/components/cards'
import { Card } from '../../../../shared/components/cards/Card'
import { Badge, Button } from '../../../../shared/components/ui'
import { AdminPageLayout } from '../../components'
import { getAdminProduct } from '../../../../core/lib'
import type { AdminProduct } from '../../../../core/lib/types/admin'
import { ProductEditModal } from './components/ProductEditModal'

const fallbackImage = '/assets/images/produce.jpg'

export function ProductDetailsPage() {
	const { uuid = '' } = useParams()
	const [product, setProduct] = useState<AdminProduct | null>(null)
	const [loading, setLoading] = useState(true)
	const [error, setError] = useState('')
	const [editing, setEditing] = useState(false)
	const [reloadKey, setReloadKey] = useState(0)

	useEffect(() => {
		let active = true
		setLoading(true)
		setError('')
		getAdminProduct(uuid).then((result) => {
			if (active) setProduct(result)
		}).catch((requestError) => {
			if (active) setError(requestError instanceof Error ? requestError.message : 'Could not load product details.')
		}).finally(() => {
			if (active) setLoading(false)
		})
		return () => { active = false }
	}, [uuid, reloadKey])

	const refresh = () => setReloadKey((current) => current + 1)
	const image = product?.image_url || product?.image || fallbackImage

	return <AdminPageLayout section="products" title={product?.name || 'Product details'} loading={loading} error={error} onRefresh={refresh}>
		{product && <div className="space-y-5">
			<div className="flex flex-wrap items-center justify-between gap-3"><Link to="/app/admin/products" className="inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-primary hover:text-primary-dark"><ArrowLeft className="h-4 w-4" />All products</Link><div className="flex items-center gap-2"><Badge variant={product.is_active ? 'success' : 'neutral'}>{product.is_active ? 'Active listing' : 'Inactive listing'}</Badge><Button type="button" size="sm" leftIcon={<Pencil className="h-4 w-4" />} onClick={() => setEditing(true)}>Edit product</Button></div></div>
			<div className="grid grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-4"><StatCard title="Price" value={`KES ${Number(product.price_per_unit).toLocaleString()}`} subtitle={`Per ${product.unit}`} variant="flat" /><StatCard title="Available" value={product.available_quantity} subtitle={`${product.reserved_quantity ?? 0} reserved`} variant="flat" /><StatCard title="Rating" value={Number(product.rating ?? 0).toFixed(1)} subtitle={`${product.review_count ?? 0} reviews`} variant="flat" /><StatCard title="Wishlist saves" value={product.wishlist_count ?? 0} subtitle="Buyer interest" variant="flat" /></div>
			<div className="grid gap-4 lg:grid-cols-[minmax(0,1fr)_minmax(0,1.2fr)]">
				<div className="overflow-hidden rounded-xl border border-border bg-card"><img src={image} alt={product.name} className="aspect-square w-full object-cover" onError={(event) => { event.currentTarget.src = fallbackImage }} /></div>
				<Card padding="md"><h2 className="flex items-center gap-2 text-base font-semibold text-primary-dark"><Package className="h-4 w-4" />Listing details</h2><dl className="mt-4 grid grid-cols-2 gap-x-5 gap-y-4 text-sm"><Detail label="Product" value={product.name} /><Detail label="Variety" value={product.variety} /><Detail label="SKU" value={product.sku} /><Detail label="Category" value={product.category_detail?.name} /><Detail label="Farmer" value={product.farmer_name} /><Detail label="Farmer phone" value={product.farmer_phone} /><Detail label="Harvest date" value={product.harvest_date} /><Detail label="Shelf life" value={product.shelf_life_days ? `${product.shelf_life_days} days` : undefined} /><Detail label="Organic" value={product.is_organic ? 'Yes' : 'No'} /><Detail label="Weight per unit" value={product.weight_per_unit == null ? undefined : `${product.weight_per_unit} kg`} /><Detail label="Pickup coordinates" value={product.pickup_lat != null && product.pickup_lng != null ? `${product.pickup_lat}, ${product.pickup_lng}` : undefined} /><Detail label="Created" value={product.created_at ? new Date(product.created_at).toLocaleString() : undefined} /></dl>{product.description && <div className="mt-5 border-t border-border pt-4"><h3 className="text-xs font-semibold text-muted-foreground">Description</h3><p className="mt-2 whitespace-pre-wrap text-sm leading-6">{product.description}</p></div>}{(product.bulk_price_tiers?.length ?? 0) > 0 && <div className="mt-5 border-t border-border pt-4"><h3 className="text-xs font-semibold text-muted-foreground">Bulk pricing</h3><ul className="mt-2 space-y-2">{product.bulk_price_tiers?.map((tier) => <li key={`${tier.buyer_role}-${tier.minimum_quantity}`} className="flex justify-between gap-3 text-sm"><span>{tier.buyer_role} · from {tier.minimum_quantity} {product.unit}</span><span className="font-semibold">KES {tier.unit_price}</span></li>)}</ul></div>}</Card>
			</div>
			{!product.image_url && !product.image && <p className="sr-only"><Image aria-hidden="true" />No product image uploaded</p>}
		</div>}
		<ProductEditModal product={editing ? product : null} onClose={() => setEditing(false)} onSaved={() => { setEditing(false); refresh() }} />
	</AdminPageLayout>
}

function Detail({ label, value }: { label: string; value?: string | number | null }) {
	return <div className="min-w-0"><dt className="text-xs text-muted-foreground">{label}</dt><dd className="mt-1 break-words font-medium text-foreground">{value ?? 'Not provided'}</dd></div>
}
