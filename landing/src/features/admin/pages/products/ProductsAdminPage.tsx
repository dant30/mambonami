import { useState } from 'react'

import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { adminResourceCaches, listAdminProducts, setAdminProductActive, useAdminResource } from '../../../../core/lib'
import type { AdminProduct } from '../../../../core/lib/types/admin'
import { ProductAvailabilityAction } from './components/ProductAvailabilityAction'

export function ProductsAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminProducts, adminResourceCaches.products)
	const [query, setQuery] = useState('')
	const products = (data ?? []).filter((product) => `${product.name} ${product.variety ?? ''} ${product.farmer_name ?? ''} ${product.farmer_phone ?? ''}`.toLowerCase().includes(query.trim().toLowerCase()))
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
		<div className="mb-4 flex justify-end"><input aria-label="Search products" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search product or farmer" className="min-h-10 w-full max-w-sm rounded-md border border-border bg-background px-3 text-sm" /></div>
		<DataTable data={products} columns={columns} keyExtractor={(product) => product.uuid} emptyMessage="No matching products found." />
	</AdminPageLayout>
}