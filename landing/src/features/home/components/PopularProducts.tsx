import { ArrowRight, TrendingUp } from 'lucide-react'
import { Link } from 'react-router-dom'

import { useProducts } from '../../../core/lib'
import { MarketplaceProductCard } from './MarketplaceProductCard'

export function PopularProducts() {
	const { products, isLoading } = useProducts({ ordering: '-rating', in_stock: true, page_size: 4 })
	return <section className="bg-muted/40"><div className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8"><div className="flex items-center justify-between gap-4"><div><p className="text-xs font-bold uppercase tracking-[0.16em] text-primary">Top-rated produce</p><h2 className="mt-1 text-2xl font-semibold text-primary-dark">Popular on Mambonami</h2></div><Link to="/products?ordering=-rating" className="inline-flex shrink-0 items-center gap-1 text-sm font-bold text-primary">Explore all <ArrowRight className="h-4 w-4" /></Link></div>{isLoading ? <div className="mt-5 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">{[1, 2, 3, 4].map((item) => <div key={item} className="h-96 animate-pulse rounded-2xl bg-muted" />)}</div> : products.length > 0 ? <div className="mt-5 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">{products.map((product) => <MarketplaceProductCard key={product.uuid} product={product} />)}</div> : <div className="mt-5 rounded-2xl border border-dashed border-border bg-card p-8 text-center"><TrendingUp className="mx-auto h-8 w-8 text-primary" /><p className="mt-3 text-sm text-muted-foreground">Top-rated produce will appear as customers shop.</p></div>}</div></section>
}
