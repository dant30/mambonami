import { useState } from 'react'

import { StatCard } from '../../../../shared/components/cards'
import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { adminResourceCaches, listAdminProducts, setAdminProductActive, useAdminResource } from '../../../../core/lib'
import type { AdminProduct } from '../../../../core/lib/types/admin'
import { ProductAvailabilityAction } from './components/ProductAvailabilityAction'

export function ProductsAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminProducts, adminResourceCaches.products)
	const [query, setQuery] = useState('')
	const allProducts = data ?? []
	const products = allProducts.filter((product) => `${product.name} ${product.variety ?? ''} ${product.farmer_name ?? ''} ${product.farmer_phone ?? ''}`.toLowerCase().includes(query.trim().toLowerCase()))
	const toggle = (product: AdminProduct) => {
		const nextState = !product.is_active
		if (!window.confirm(`${nextState ? 'Activate' : 'Deactivate'} ${product.name}?`)) return
		void runAction(product.uuid, () => setAdminProductActive(product.uuid, nextState), `Product ${nextState ? 'activated' : 'deactivated'}.`)
	}
	const columns = [
		{ header: 'Product', render: (product: AdminProduct) => <div><p className="font-semibold">{product.name}{product.variety ? ` · ${product.variety}` : ''}</p><p className="text-xs text-muted-foreground">{product.category_detail?.name || 'Uncategorized'} · {product.sku}</p></div> },
		{ header: 'Farmer', render: (product: AdminProduct) => <div>{product.farmer_name || 'Unknown'}<p className="text-xs text-muted-foreground">{product.farmer_phone || 'No phone'}</p></div> },
		{ header: 'Price / stock', render: (product: AdminProduct) => `KES ${product.price_per_unit} / ${product.unit} · ${product.available_quantity} available` },
		{ header: 'Listing', render: (product: AdminProduct) => product.is_active ? 'Active' : 'Inactive' },
		{ header: 'Action', render: (product: AdminProduct) => <ProductAvailabilityAction product={product} busy={busy === product.uuid} onToggle={() => toggle(product)} /> },
	]
	return <AdminPageLayout section="products" title="Products" loading={loading} error={error} notice={notice} onRefresh={refresh}>
		<div className="mb-4 grid grid-cols-2 gap-3 sm:mb-6 sm:gap-4 xl:grid-cols-4"><StatCard title="Products" value={allProducts.length} subtitle="All storefront listings" variant="flat" /><StatCard title="Active" value={allProducts.filter((product) => product.is_active).length} subtitle="Visible to shoppers" variant="flat" /><StatCard title="Inactive" value={allProducts.filter((product) => !product.is_active).length} subtitle="Hidden listings" variant="flat" /><StatCard title="Out of stock" value={allProducts.filter((product) => Number(product.available_quantity) <= 0).length} subtitle="Active or inactive listings" variant="flat" /></div>
		<div className="mb-4 flex justify-end"><input aria-label="Search products" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search product or farmer" className="min-h-10 w-full max-w-sm rounded-md border border-border bg-background px-3 text-sm" /></div>
		<DataTable data={products} columns={columns} keyExtractor={(product) => product.uuid} emptyMessage="No matching products found." />
	</AdminPageLayout>
}