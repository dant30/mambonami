import { ArrowUpRight } from 'lucide-react'

import type { Product } from '../../../core/lib'

const fallbackImage = '/assets/images/produce.jpg'

export function ProductCard({ product }: { product: Product }) {
	const price = Number(product.price_per_unit)
	const image = product.image_url || product.image || fallbackImage

	return <article className="group h-full overflow-hidden rounded-xl border border-border bg-card shadow-sm transition-all duration-300 hover:-translate-y-1 hover:shadow-soft sm:rounded-2xl"><div className="relative overflow-hidden"><img src={image} alt={product.name} className="aspect-square w-full object-cover transition-transform duration-500 group-hover:scale-105" onError={(event) => { event.currentTarget.src = fallbackImage }} /><span className="absolute left-2 top-2 max-w-[calc(100%-1rem)] truncate rounded-full bg-white/90 px-2 py-1 text-[9px] font-bold uppercase text-primary-dark backdrop-blur-sm sm:left-3 sm:top-3 sm:px-3 sm:py-1.5 sm:text-[10px] sm:tracking-[0.12em]">{product.category_detail?.name ?? 'Fresh produce'}</span><button type="button" aria-label={`View ${product.name}`} className="absolute bottom-2 right-2 flex h-9 w-9 items-center justify-center rounded-full bg-primary text-primary-foreground opacity-0 shadow-soft transition-opacity group-hover:opacity-100"><ArrowUpRight className="h-4 w-4" /></button></div><div className="p-3 sm:p-5"><h3 className="line-clamp-1 text-sm font-semibold text-primary-dark sm:text-xl">{product.name}</h3>{product.variety && <p className="mt-0.5 line-clamp-1 text-xs text-muted-foreground sm:mt-1 sm:text-sm">{product.variety}</p>}<div className="mt-2 flex items-end justify-between gap-2 sm:mt-4 sm:gap-3"><p className="truncate text-sm font-bold text-primary-dark">{Number.isFinite(price) ? `KSh ${price.toLocaleString()}` : product.price_per_unit}</p><span className="shrink-0 text-[10px] text-muted-foreground sm:text-xs">/ {product.unit}</span></div>{product.farmer_name && <p className="mt-1 line-clamp-1 text-[10px] text-muted-foreground sm:mt-3 sm:text-xs">From {product.farmer_name}</p>}</div></article>
}
