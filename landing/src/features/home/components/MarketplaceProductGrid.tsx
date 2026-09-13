import type { Product } from '../../../core/lib'
import { EmptyState } from '../../../shared/components/feedback'
import { MarketplaceProductCard } from './MarketplaceProductCard'

export function MarketplaceProductGrid({ products, loading }: { products: Product[]; loading?: boolean }) {
	if (loading) return <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">{Array.from({ length: 8 }).map((_, index) => <div key={index} className="animate-pulse overflow-hidden rounded-[1.25rem] border border-border bg-card"><div className="aspect-[1.05/1] bg-muted" /><div className="space-y-3 p-5"><div className="h-5 w-2/3 rounded bg-muted" /><div className="h-4 w-1/3 rounded bg-muted" /><div className="h-10 rounded bg-muted" /></div></div>)}</div>
	if (products.length === 0) return <EmptyState title="No produce found" description="Try a different search or browse the next harvest when it arrives." />
	return <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">{products.map((product) => <MarketplaceProductCard key={product.uuid} product={product} />)}</div>
}
