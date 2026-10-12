import { ArrowRight, TrendingUp } from 'lucide-react'
import { Link } from 'react-router-dom'

import { useProducts } from '../../../core/lib'
import { MarketplaceProductCard } from './MarketplaceProductCard'

export function PopularProducts() {
	const { products, isLoading } = useProducts({ ordering: '-rating', in_stock: true, page_size: 4 })
	return <section className="bg-muted/40"><div className="mx-auto max-w-7xl px-4 py-5 sm:px-6 sm:py-6 lg:px-8"><div className="flex items-center justify-between gap-3"><div><p className="text-[10px] font-bold uppercase tracking-[0.16em] text-primary sm:text-xs">Top-rated produce</p><h2 className="mt-1 text-xl font-semibold text-primary-dark sm:text-2xl">Popular on Mambonami</h2></div><Link to="/products?ordering=-rating" className="inline-flex min-h-10 shrink-0 items-center gap-1 text-xs font-bold text-primary sm:text-sm">Explore all <ArrowRight className="h-4 w-4" /></Link></div>{isLoading ? <div className="mt-3 grid grid-cols-2 gap-3 sm:mt-5 sm:grid-cols-2 sm:gap-4 lg:grid-cols-4">{[1, 2, 3, 4].map((item) => <div key={item} className="aspect-[0.72/1] animate-pulse rounded-xl bg-muted sm:aspect-auto sm:h-96 sm:rounded-2xl" />)}</div> : products.length > 0 ? <div className="mt-3 grid grid-cols-2 gap-3 sm:mt-5 sm:grid-cols-2 sm:gap-4 lg:grid-cols-4">{products.map((product) => <MarketplaceProductCard key={product.uuid} product={product} />)}</div> : <div className="mt-3 rounded-xl border border-dashed border-border bg-card p-5 text-center sm:mt-5 sm:rounded-2xl sm:p-8"><TrendingUp className="mx-auto h-8 w-8 text-primary" /><p className="mt-3 text-sm text-muted-foreground">Top-rated produce will appear as customers shop.</p></div>}</div></section>
}
