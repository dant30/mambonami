import { ChevronLeft, ChevronRight, Search, SlidersHorizontal } from 'lucide-react'
import { useEffect, useState } from 'react'
import { useSearchParams } from 'react-router-dom'

import { useDebounce } from '../../../core/hooks'
import { useProductCategories, useProducts } from '../../../core/lib'
import { MarketplaceProductGrid } from '../components/MarketplaceProductGrid'

const PAGE_SIZE = 24

export function ProductsPage() {
	const [searchParams] = useSearchParams()
	const [search, setSearch] = useState(() => searchParams.get('q') || '')
	const [activeSearch, setActiveSearch] = useState('')
	const debouncedSearch = useDebounce(search, 300)
	const [category, setCategory] = useState(() => searchParams.get('category') || '')
	const [organic, setOrganic] = useState(false)
	const [inStock, setInStock] = useState(false)
	const [minPrice, setMinPrice] = useState('')
	const [maxPrice, setMaxPrice] = useState('')
	const [minRating, setMinRating] = useState('')
	const [sort, setSort] = useState('')
	const [page, setPage] = useState(1)
	const { products, count, next, previous, isLoading, error } = useProducts({ search: activeSearch, category: category || undefined, is_organic: organic || undefined, in_stock: inStock || undefined, min_price: minPrice ? Number(minPrice) : undefined, max_price: maxPrice ? Number(maxPrice) : undefined, min_rating: minRating ? Number(minRating) : undefined, ordering: sort || undefined, page, page_size: PAGE_SIZE })
	const { categories, error: categoryError } = useProductCategories()

	useEffect(() => {
		setPage(1)
		setActiveSearch(debouncedSearch)
	}, [debouncedSearch])

	useEffect(() => {
		setActiveSearch(searchParams.get('q') || '')
		setSearch(searchParams.get('q') || '')
		setCategory(searchParams.get('category') || '')
	}, [searchParams])

	const pageCount = Math.max(1, Math.ceil(count / PAGE_SIZE))

	return (
		<div>
			<main className="mx-auto max-w-7xl px-4 py-5 sm:px-6 lg:px-8 lg:py-8">
				<div className="mb-5 flex items-end justify-between gap-4"><div><p className="text-[11px] font-bold uppercase tracking-[0.18em] text-primary">The harvest</p><h1 className="mt-1 text-2xl font-semibold text-primary-dark sm:text-3xl">Fresh produce</h1></div><p className="hidden text-sm text-muted-foreground sm:block">Search, filter, and shop from trusted growers.</p></div>
				<div className="mb-6 flex flex-wrap gap-2" aria-label="Browse categories">
					<button type="button" onClick={() => { setCategory(''); setPage(1) }} className={`rounded-full border px-4 py-2 text-sm font-semibold ${!category ? 'border-primary bg-primary text-primary-foreground' : 'border-border text-primary-dark hover:bg-muted'}`}>All produce</button>
					{categories.map((item) => <button key={item.id} type="button" onClick={() => { setCategory(item.code); setPage(1) }} className={`rounded-full border px-4 py-2 text-sm font-semibold ${category === item.code ? 'border-primary bg-primary text-primary-foreground' : 'border-border text-primary-dark hover:bg-muted'}`}>{item.name}</button>)}
					{Boolean(categoryError) && <span className="self-center text-xs text-muted-foreground">Categories are temporarily unavailable.</span>}
				</div>
				<div className="mb-8 flex flex-col gap-4 rounded-2xl border border-border bg-card p-4 shadow-sm lg:flex-row lg:items-center">
					<label className="relative flex-1"><span className="sr-only">Search products</span><Search className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search tomatoes, potatoes, eggs..." className="w-full rounded-full border border-border bg-background py-3 pl-11 pr-4 text-sm outline-none ring-primary transition focus:ring-2" /></label>
					<div className="flex flex-wrap items-center gap-3"><select aria-label="Sort products" value={sort} onChange={(event) => { setSort(event.target.value); setPage(1) }} className="rounded-full border border-border bg-background px-4 py-3 text-sm font-semibold outline-none"><option value="">Sort: Featured</option><option value="price_per_unit">Price: low to high</option><option value="-price_per_unit">Price: high to low</option><option value="-rating">Top rated</option><option value="-created_at">Newest</option></select><label className="flex items-center gap-2 rounded-full border border-border px-4 py-3 text-sm font-semibold"><SlidersHorizontal className="h-4 w-4 text-primary" /><input type="checkbox" checked={organic} onChange={(event) => { setOrganic(event.target.checked); setPage(1) }} className="accent-primary" />Organic</label><label className="flex items-center gap-2 rounded-full border border-border px-4 py-3 text-sm font-semibold"><input type="checkbox" checked={inStock} onChange={(event) => { setInStock(event.target.checked); setPage(1) }} className="accent-primary" />In stock</label></div>
					<div className="grid gap-3 border-t border-border pt-4 sm:grid-cols-3"><label className="text-xs font-bold uppercase tracking-wide text-muted-foreground">Min price<input aria-label="Minimum price" type="number" min="0" value={minPrice} onChange={(event) => { setMinPrice(event.target.value); setPage(1) }} placeholder="Any" className="mt-1 w-full rounded-xl border border-border bg-background px-3 py-2.5 text-sm font-normal outline-none focus:ring-2 focus:ring-primary" /></label><label className="text-xs font-bold uppercase tracking-wide text-muted-foreground">Max price<input aria-label="Maximum price" type="number" min="0" value={maxPrice} onChange={(event) => { setMaxPrice(event.target.value); setPage(1) }} placeholder="Any" className="mt-1 w-full rounded-xl border border-border bg-background px-3 py-2.5 text-sm font-normal outline-none focus:ring-2 focus:ring-primary" /></label><label className="text-xs font-bold uppercase tracking-wide text-muted-foreground">Minimum rating<select aria-label="Minimum rating" value={minRating} onChange={(event) => { setMinRating(event.target.value); setPage(1) }} className="mt-1 w-full rounded-xl border border-border bg-background px-3 py-2.5 text-sm font-normal outline-none focus:ring-2 focus:ring-primary"><option value="">Any rating</option><option value="4">4+ stars</option><option value="3">3+ stars</option><option value="2">2+ stars</option></select></label></div>
				</div>
				{error ? <p role="alert" className="rounded-xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive">We could not load the harvest right now. Please try again.</p> : <MarketplaceProductGrid products={products} loading={isLoading} />}
				{!isLoading && !error && products.length > 0 && <div className="mt-10 flex items-center justify-between border-t border-border pt-5"><p className="text-sm text-muted-foreground">Page {page} of {pageCount}</p><div className="flex gap-2"><button type="button" disabled={!previous || page === 1} onClick={() => setPage((current) => Math.max(1, current - 1))} className="inline-flex items-center gap-1 rounded-full border border-border px-4 py-2 text-sm font-bold text-primary-dark disabled:cursor-not-allowed disabled:opacity-40"><ChevronLeft className="h-4 w-4" />Previous</button><button type="button" disabled={!next} onClick={() => setPage((current) => current + 1)} className="inline-flex items-center gap-1 rounded-full border border-border px-4 py-2 text-sm font-bold text-primary-dark disabled:cursor-not-allowed disabled:opacity-40">Next<ChevronRight className="h-4 w-4" /></button></div></div>}
			</main>
		</div>
	)
}
