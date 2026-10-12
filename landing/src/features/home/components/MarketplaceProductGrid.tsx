import type { Product } from '../../../core/lib'
import { EmptyState } from '../../../shared/components/feedback'
import { MarketplaceProductCard } from './MarketplaceProductCard'

export function MarketplaceProductGrid({ products, loading }: { products: Product[]; loading?: boolean }) {
	if (loading) return <div className="grid grid-cols-2 gap-3 sm:gap-5 lg:grid-cols-3 xl:grid-cols-4">{Array.from({ length: 8 }).map((_, index) => <div key={index} className="animate-pulse overflow-hidden rounded-xl border border-border bg-card sm:rounded-[1.25rem]"><div className="aspect-square bg-muted" /><div className="space-y-2 p-3 sm:space-y-3 sm:p-5"><div className="h-4 w-2/3 rounded bg-muted sm:h-5" /><div className="h-3 w-1/3 rounded bg-muted sm:h-4" /><div className="h-11 rounded bg-muted" /></div></div>)}</div>
	if (products.length === 0) return <EmptyState title="No produce found" description="Try a different search or browse the next harvest when it arrives." />
	return <div className="grid grid-cols-2 gap-3 sm:gap-5 lg:grid-cols-3 xl:grid-cols-4">{products.map((product) => <MarketplaceProductCard key={product.uuid} product={product} />)}</div>
}
