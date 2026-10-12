import { ChevronLeft, ChevronRight, Search, SlidersHorizontal } from 'lucide-react'
import { useEffect, useState } from 'react'
import { useSearchParams } from 'react-router-dom'

import { useDebounce } from '../../../core/hooks'
import { useProductCategories, useProducts } from '../../../core/lib'
import { Select } from '../../../shared/components/ui'
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
				<div className="mb-4 flex items-end justify-between gap-3 sm:mb-5 sm:gap-4"><div><p className="text-[10px] font-bold uppercase tracking-[0.18em] text-primary sm:text-[11px]">The harvest</p><h1 className="mt-1 text-2xl font-semibold text-primary-dark sm:text-3xl">Fresh produce</h1></div><p className="hidden text-sm text-muted-foreground sm:block">Search, filter, and shop from trusted growers.</p></div>
				<div className="mobile-scroll-row mb-4 flex gap-2 overflow-x-auto pb-1 sm:mb-6 sm:flex-wrap" aria-label="Browse categories">
					<button type="button" onClick={() => { setCategory(''); setPage(1) }} className={`min-h-11 shrink-0 rounded-full border px-3 py-2 text-xs font-semibold sm:px-4 sm:text-sm ${!category ? 'border-primary bg-primary text-primary-foreground' : 'border-border text-primary-dark hover:bg-muted'}`}>All produce</button>
					{categories.map((item) => <button key={item.id} type="button" onClick={() => { setCategory(item.code); setPage(1) }} className={`min-h-11 shrink-0 rounded-full border px-3 py-2 text-xs font-semibold sm:px-4 sm:text-sm ${category === item.code ? 'border-primary bg-primary text-primary-foreground' : 'border-border text-primary-dark hover:bg-muted'}`}>{item.name}</button>)}
					{Boolean(categoryError) && <span className="self-center text-xs text-muted-foreground">Categories are temporarily unavailable.</span>}
				</div>
				<div className="mb-5 flex flex-col gap-3 rounded-xl border border-border bg-card p-3 shadow-sm sm:mb-8 sm:gap-4 sm:rounded-2xl sm:p-4 lg:flex-row lg:items-center">
					<label className="relative flex-1"><span className="sr-only">Search products</span><Search className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search tomatoes, potatoes, eggs..." className="min-h-11 w-full rounded-full border border-border bg-background py-2.5 pl-11 pr-4 text-sm outline-none ring-primary transition focus:ring-2" /></label>
					<div className="grid grid-cols-2 items-center gap-2 sm:flex sm:flex-wrap sm:gap-3"><div className="col-span-2 sm:col-span-1"><Select aria-label="Sort products" value={sort} onChange={(value) => { setSort(value); setPage(1) }} options={[{ value: '', label: 'Sort: Featured' }, { value: 'price_per_unit', label: 'Price: low to high' }, { value: '-price_per_unit', label: 'Price: high to low' }, { value: '-rating', label: 'Top rated' }, { value: '-created_at', label: 'Newest' }]} /></div><label className="flex min-h-11 items-center justify-center gap-2 rounded-full border border-border px-3 py-2 text-xs font-semibold sm:px-4 sm:py-3 sm:text-sm"><SlidersHorizontal className="h-4 w-4 text-primary" /><input type="checkbox" checked={organic} onChange={(event) => { setOrganic(event.target.checked); setPage(1) }} className="accent-primary" />Organic</label><label className="flex min-h-11 items-center justify-center gap-2 rounded-full border border-border px-3 py-2 text-xs font-semibold sm:px-4 sm:py-3 sm:text-sm"><input type="checkbox" checked={inStock} onChange={(event) => { setInStock(event.target.checked); setPage(1) }} className="accent-primary" />In stock</label></div>
					<div className="grid grid-cols-2 gap-2 border-t border-border pt-3 sm:grid-cols-3 sm:gap-3 sm:pt-4"><label className="text-[10px] font-bold uppercase tracking-wide text-muted-foreground sm:text-xs">Min price<input aria-label="Minimum price" type="number" min="0" value={minPrice} onChange={(event) => { setMinPrice(event.target.value); setPage(1) }} placeholder="Any" className="mt-1 min-h-11 w-full rounded-xl border border-border bg-background px-3 py-2.5 text-sm font-normal outline-none focus:ring-2 focus:ring-primary" /></label><label className="text-[10px] font-bold uppercase tracking-wide text-muted-foreground sm:text-xs">Max price<input aria-label="Maximum price" type="number" min="0" value={maxPrice} onChange={(event) => { setMaxPrice(event.target.value); setPage(1) }} placeholder="Any" className="mt-1 min-h-11 w-full rounded-xl border border-border bg-background px-3 py-2.5 text-sm font-normal outline-none focus:ring-2 focus:ring-primary" /></label><div className="col-span-2 sm:col-span-1"><Select label="Minimum rating" value={minRating} onChange={(value) => { setMinRating(value); setPage(1) }} options={[{ value: '', label: 'Any rating' }, { value: '4', label: '4+ stars' }, { value: '3', label: '3+ stars' }, { value: '2', label: '2+ stars' }]} /></div></div>
				</div>
				{error ? <p role="alert" className="rounded-xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive">We could not load the harvest right now. Please try again.</p> : <MarketplaceProductGrid products={products} loading={isLoading} />}
				{!isLoading && !error && products.length > 0 && <div className="mt-6 flex items-center justify-between border-t border-border pt-4 sm:mt-10 sm:pt-5"><p className="text-xs text-muted-foreground sm:text-sm">Page {page} of {pageCount}</p><div className="flex gap-2"><button type="button" disabled={!previous || page === 1} onClick={() => setPage((current) => Math.max(1, current - 1))} className="inline-flex min-h-11 items-center gap-1 rounded-full border border-border px-3 py-2 text-xs font-bold text-primary-dark disabled:cursor-not-allowed disabled:opacity-40 sm:px-4 sm:text-sm"><ChevronLeft className="h-4 w-4" />Previous</button><button type="button" disabled={!next} onClick={() => setPage((current) => current + 1)} className="inline-flex min-h-11 items-center gap-1 rounded-full border border-border px-3 py-2 text-xs font-bold text-primary-dark disabled:cursor-not-allowed disabled:opacity-40 sm:px-4 sm:text-sm">Next<ChevronRight className="h-4 w-4" /></button></div></div>}
			</main>
		</div>
	)
}
