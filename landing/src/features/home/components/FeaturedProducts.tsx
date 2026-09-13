import { ArrowRight } from 'lucide-react'
import { Link } from 'react-router-dom'

import type { Product } from '../../../core/lib'
import { MarketplaceProductCard } from './MarketplaceProductCard'

export function FeaturedProducts({ products, loading, error }: { products: Product[]; loading?: boolean; error?: unknown }) { return <section id="featured" className="mx-auto max-w-7xl px-4 pb-6 pt-2 sm:px-6 lg:px-8"><div className="flex items-center justify-between gap-4"><div><h2 className="text-2xl font-semibold text-primary-dark">Featured produce</h2><p className="mt-1 text-sm text-muted-foreground">Fresh picks available now.</p></div><Link to="/products" className="inline-flex shrink-0 items-center gap-1 text-sm font-bold text-primary">View all <ArrowRight className="h-4 w-4" /></Link></div>{error ? <p role="alert" className="mt-4 rounded-xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive">The latest harvest is temporarily unavailable.</p> : <div className="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">{loading ? [1, 2, 3, 4].map((item) => <div key={item} className="h-96 animate-pulse rounded-2xl bg-muted" />) : products.slice(0, 4).map((product) => <MarketplaceProductCard key={product.uuid} product={product} />)}</div>}</section> }
