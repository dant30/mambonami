import { Search } from 'lucide-react'
import { useEffect, useState } from 'react'

import { useDebounce } from '../../../core/hooks'
import { useProductCategories, useProducts } from '../../../core/lib'
import { DeliveryAreaControl } from '../../home/components/DeliveryAreaControl'
import { MarketplaceProductGrid } from '../../home/components/MarketplaceProductGrid'

export function RetailerProductsPage() {
	const [search, setSearch] = useState('')
	const [activeSearch, setActiveSearch] = useState('')
	const debouncedSearch = useDebounce(search, 300)
	const [category, setCategory] = useState('')
	const { products, isLoading, error } = useProducts({ search: activeSearch, category: category || undefined, page_size: 24 })
	const { categories } = useProductCategories()
	useEffect(() => {
		setActiveSearch(debouncedSearch)
	}, [debouncedSearch])
	return <main className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8"><div className="flex flex-col gap-5 border-b border-border pb-8 sm:flex-row sm:items-end sm:justify-between"><div><p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Business procurement</p><h1 className="mt-2 text-3xl font-semibold text-primary-dark sm:text-4xl">Source at scale.</h1><p className="mt-3 text-sm text-muted-foreground">Compare fresh supply and find products that keep your shelves moving.</p></div><label className="relative w-full sm:max-w-sm"><span className="sr-only">Search products</span><Search className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search wholesale produce..." className="w-full rounded-full border border-border bg-card py-3 pl-11 pr-4 text-sm outline-none focus:ring-2 focus:ring-primary" /></label></div><DeliveryAreaControl className="mt-5 rounded-xl border border-border bg-card px-4 py-3" /><div className="mt-6 flex gap-2 overflow-x-auto pb-2">{[{ code: '', name: 'All products' }, ...categories].map((item) => <button key={item.code || 'all'} type="button" onClick={() => setCategory(item.code)} className={`shrink-0 rounded-full border px-4 py-2 text-sm font-semibold ${category === item.code ? 'border-primary bg-primary text-primary-foreground' : 'border-border text-primary-dark hover:bg-muted'}`}>{item.name}</button>)}</div><div className="mt-8">{error ? <p role="alert" className="rounded-xl bg-destructive/10 p-4 text-sm text-destructive">Unable to load procurement products.</p> : <MarketplaceProductGrid products={products} loading={isLoading} />}</div></main>
}
