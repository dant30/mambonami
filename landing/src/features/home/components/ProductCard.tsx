import { ArrowUpRight } from 'lucide-react'

import type { Product } from '../../../core/lib'

const fallbackImage = '/assets/images/produce.jpg'

export function ProductCard({ product }: { product: Product }) {
	const price = Number(product.price_per_unit)
	const image = product.image_url || product.image || fallbackImage

	return <article className="group overflow-hidden rounded-2xl border border-border bg-card shadow-sm transition-all duration-300 hover:-translate-y-1 hover:shadow-soft"><div className="relative overflow-hidden"><img src={image} alt={product.name} className="aspect-[1.1/1] w-full object-cover transition-transform duration-500 group-hover:scale-105" onError={(event) => { event.currentTarget.src = fallbackImage }} /><span className="absolute left-3 top-3 rounded-full bg-white/90 px-3 py-1.5 text-[10px] font-bold uppercase tracking-[0.12em] text-primary-dark backdrop-blur-sm">{product.category_detail?.name ?? 'Fresh produce'}</span><button type="button" aria-label={`View ${product.name}`} className="absolute bottom-3 right-3 flex h-9 w-9 items-center justify-center rounded-full bg-primary text-primary-foreground opacity-0 shadow-soft transition-opacity group-hover:opacity-100"><ArrowUpRight className="h-4 w-4" /></button></div><div className="p-4 sm:p-5"><h3 className="text-lg font-semibold text-primary-dark sm:text-xl">{product.name}</h3>{product.variety && <p className="mt-1 text-sm text-muted-foreground">{product.variety}</p>}<div className="mt-4 flex items-end justify-between gap-3"><p className="text-sm font-bold text-primary-dark">{Number.isFinite(price) ? `KSh ${price.toLocaleString()}` : product.price_per_unit}</p><span className="text-xs text-muted-foreground">per {product.unit}</span></div>{product.farmer_name && <p className="mt-3 text-xs text-muted-foreground">From {product.farmer_name}</p>}</div></article>
}
