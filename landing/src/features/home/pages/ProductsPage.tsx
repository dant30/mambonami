import { ChevronLeft, ChevronRight, Search, SlidersHorizontal, X } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { useSearchParams } from 'react-router-dom'

import { useDebounce } from '../../../core/hooks'
import { useProductCategories, useProducts } from '../../../core/lib'
import { Button, Input, Select } from '../../../shared/components/ui'
import { MarketplaceProductGrid } from '../components/MarketplaceProductGrid'

const PAGE_SIZE = 24
const sortOptions = [
	{ value: '', label: 'Featured' },
	{ value: 'price_per_unit', label: 'Price: low to high' },
	{ value: '-price_per_unit', label: 'Price: high to low' },
	{ value: '-rating', label: 'Top rated' },
	{ value: '-created_at', label: 'Newest' },
]

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
	const [filtersOpen, setFiltersOpen] = useState(false)
	const { products, count, next, previous, isLoading, error } = useProducts({
		search: activeSearch,
		category: category || undefined,
		is_organic: organic || undefined,
		in_stock: inStock || undefined,
		min_price: minPrice ? Number(minPrice) : undefined,
		max_price: maxPrice ? Number(maxPrice) : undefined,
		min_rating: minRating ? Number(minRating) : undefined,
		ordering: sort || undefined,
		page,
		page_size: PAGE_SIZE,
	})
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
	const filterCount = useMemo(
		() => [organic, inStock, Boolean(minPrice), Boolean(maxPrice), Boolean(minRating)].filter(Boolean).length,
		[organic, inStock, minPrice, maxPrice, minRating],
	)
	const clearFilters = () => {
		setOrganic(false)
		setInStock(false)
		setMinPrice('')
		setMaxPrice('')
		setMinRating('')
		setPage(1)
	}

	const advancedFilters = (
		<div className="grid grid-cols-2 gap-3 md:grid-cols-3">
			<Input aria-label="Minimum price" type="number" min="0" value={minPrice} onChange={(event) => { setMinPrice(event.target.value); setPage(1) }} placeholder="Minimum KSh" />
			<Input aria-label="Maximum price" type="number" min="0" value={maxPrice} onChange={(event) => { setMaxPrice(event.target.value); setPage(1) }} placeholder="Maximum KSh" />
			<div className="col-span-2 md:col-span-1">
				<Select aria-label="Minimum rating" value={minRating} onChange={(value) => { setMinRating(value); setPage(1) }} options={[{ value: '', label: 'Any rating' }, { value: '4', label: '4+ stars' }, { value: '3', label: '3+ stars' }, { value: '2', label: '2+ stars' }]} />
			</div>
		</div>
	)

	return (
		<main className="mx-auto max-w-7xl px-4 py-4 sm:px-6 sm:py-7 lg:px-8">
			<div className="flex items-end justify-between gap-3">
				<div>
					<p className="text-[10px] font-bold uppercase tracking-wider text-primary">Marketplace</p>
					<h1 className="mt-1 text-2xl font-semibold text-primary-dark sm:text-3xl">Fresh produce</h1>
				</div>
				<p className="text-xs font-semibold text-muted-foreground">{isLoading ? 'Loading…' : `${count} items`}</p>
			</div>

			<div className="mobile-scroll-row mt-3 flex gap-2 overflow-x-auto pb-1" aria-label="Browse categories">
				<Button type="button" size="sm" variant={!category ? 'primary' : 'outline'} onClick={() => { setCategory(''); setPage(1) }} className="min-h-10 shrink-0 rounded-full">All</Button>
				{categories.map((item) => <Button key={item.id} type="button" size="sm" variant={category === item.code ? 'primary' : 'outline'} onClick={() => { setCategory(item.code); setPage(1) }} className="min-h-10 shrink-0 rounded-full">{item.name}</Button>)}
				{Boolean(categoryError) && categories.length === 0 && <span role="status" className="self-center text-xs text-muted-foreground">Categories unavailable</span>}
			</div>

			<section aria-label="Search and filters" className="mt-3 rounded-2xl border border-border bg-card p-3 shadow-sm sm:p-4">
				<Input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search produce..." aria-label="Search products" leftIcon={<Search className="h-4 w-4" />} />
				<div className="mt-3 grid grid-cols-[1fr_auto] gap-2">
					<Select aria-label="Sort products" value={sort} onChange={(value) => { setSort(value); setPage(1) }} options={sortOptions} />
					<Button type="button" variant={filtersOpen || filterCount > 0 ? 'primary' : 'outline'} onClick={() => setFiltersOpen((open) => !open)} leftIcon={<SlidersHorizontal className="h-4 w-4" />} className="md:hidden">
						Filters{filterCount > 0 ? ` (${filterCount})` : ''}
					</Button>
				</div>
				<div className="mt-3 flex gap-2 overflow-x-auto pb-1">
					<Button type="button" size="sm" variant={organic ? 'primary' : 'outline'} onClick={() => { setOrganic((value) => !value); setPage(1) }} aria-pressed={organic} className="min-h-10 shrink-0 rounded-full">Organic</Button>
					<Button type="button" size="sm" variant={inStock ? 'primary' : 'outline'} onClick={() => { setInStock((value) => !value); setPage(1) }} aria-pressed={inStock} className="min-h-10 shrink-0 rounded-full">In stock</Button>
					{filterCount > 0 && <Button type="button" size="sm" variant="ghost" onClick={clearFilters} leftIcon={<X className="h-4 w-4" />} className="min-h-10 shrink-0">Clear</Button>}
				</div>
				{filtersOpen && <div className="mt-3 border-t border-border pt-3 md:hidden">{advancedFilters}</div>}
				<div className="mt-3 hidden border-t border-border pt-3 md:block">{advancedFilters}</div>
			</section>

			<section className="mt-5">
				{error ? <p role="alert" className="rounded-xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive">We could not load the harvest right now. Please try again.</p> : <MarketplaceProductGrid products={products} loading={isLoading} />}
			</section>

			{!isLoading && !error && products.length > 0 && (
				<div className="mt-6 flex items-center justify-between border-t border-border pt-4">
					<p className="text-xs text-muted-foreground">Page {page} of {pageCount}</p>
					<div className="flex gap-2">
						<Button type="button" size="sm" variant="outline" disabled={!previous || page === 1} onClick={() => setPage((current) => Math.max(1, current - 1))} leftIcon={<ChevronLeft className="h-4 w-4" />}>Previous</Button>
						<Button type="button" size="sm" variant="outline" disabled={!next} onClick={() => setPage((current) => current + 1)} rightIcon={<ChevronRight className="h-4 w-4" />}>Next</Button>
					</div>
				</div>
			)}
		</main>
	)
}
