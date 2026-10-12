import { Heart, ShoppingBasket } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useState } from 'react'

import { addToWishlist, addToCart } from '../../../core/lib'
import { useAuth } from '../../../core/contexts/AuthContext'
import { guestWishlistStore } from '../../../core/lib'
import type { Product } from '../../../core/lib'

const fallbackImage = '/assets/images/produce.jpg'

function formatPrice(value: string | number | undefined) {
	const price = Number(value)
	return Number.isFinite(price) ? `KSh ${price.toLocaleString()}` : 'Price on request'
}

export function MarketplaceProductCard({ product }: { product: Product }) {
	const { isAuthenticated } = useAuth()
	const image = product.image_url || product.image || fallbackImage
	const [inWishlist, setInWishlist] = useState(() => guestWishlistStore.has(product.uuid))

	const toggleWishlist = async () => {
		if (inWishlist) {
			guestWishlistStore.remove(product.uuid)
			setInWishlist(false)
			return
		}
		if (isAuthenticated) {
			try {
				await addToWishlist(product.uuid)
				setInWishlist(true)
				return
			} catch {
				// Keep the item locally if the account request is unavailable.
			}
		}
		guestWishlistStore.add(product)
		setInWishlist(true)
	}

	return (
		<article className="group flex h-full flex-col overflow-hidden rounded-xl border border-border bg-card shadow-sm transition duration-300 hover:-translate-y-1 hover:shadow-soft sm:rounded-[1.25rem]">
			<div className="relative overflow-hidden">
				<Link to={`/product/${product.uuid}`} aria-label={`View ${product.name}`}>
					<img src={image} alt={product.name} className="aspect-square w-full object-cover transition duration-500 group-hover:scale-105" onError={(event) => { event.currentTarget.src = fallbackImage }} />
				</Link>
				<div className="absolute left-2 top-2 flex max-w-[calc(100%-3rem)] flex-wrap gap-1 sm:left-3 sm:top-3 sm:gap-2">
					<span className="max-w-full truncate rounded-full bg-white/90 px-2 py-1 text-[9px] font-bold uppercase text-primary-dark backdrop-blur-sm sm:px-3 sm:text-[10px] sm:tracking-[0.12em]">{product.category_detail?.name ?? 'Fresh produce'}</span>
					{product.is_organic && <span className="rounded-full bg-secondary px-2 py-1 text-[9px] font-bold uppercase text-primary-dark sm:px-3 sm:text-[10px] sm:tracking-[0.12em]">Organic</span>}
				</div>
				<button type="button" onClick={toggleWishlist} aria-label={inWishlist ? `Remove ${product.name} from wishlist` : `Save ${product.name} to wishlist`} className={`absolute right-2 top-2 flex h-10 w-10 items-center justify-center rounded-full bg-white/95 shadow-sm transition hover:bg-secondary sm:right-3 sm:top-3 ${inWishlist ? 'text-red-600' : 'text-primary-dark'}`}><Heart className="h-4 w-4" fill={inWishlist ? 'currentColor' : 'none'} /></button>
			</div>
			<div className="flex flex-1 flex-col p-3 sm:p-5">
				<Link to={`/product/${product.uuid}`} className="block">
					<h3 className="line-clamp-1 text-sm font-semibold text-primary-dark group-hover:text-primary sm:text-lg">{product.name}</h3>
					{product.variety && <p className="mt-0.5 line-clamp-1 text-xs text-muted-foreground sm:mt-1 sm:text-sm">{product.variety}</p>}
				</Link>
				<div className="mt-2 flex items-end justify-between gap-2 sm:mt-4 sm:gap-3"><p className="truncate text-sm font-bold text-primary-dark sm:text-base">{formatPrice(product.price_per_unit)}</p><span className="shrink-0 text-[10px] text-muted-foreground sm:text-xs">/ {product.unit}</span></div>
				{product.farmer_name && <p className="mt-1 line-clamp-1 text-[10px] text-muted-foreground sm:mt-3 sm:text-xs">From {product.farmer_name}</p>}
				<button type="button" onClick={() => addToCart({ product_uuid: product.uuid, quantity: 1, unit_price: product.price_per_unit, product_detail: product })} className="mt-auto flex min-h-11 w-full items-center justify-center gap-1 rounded-full bg-primary px-2 py-2 text-xs font-bold text-primary-foreground transition hover:bg-primary-dark sm:mt-4 sm:gap-2 sm:px-4 sm:py-2.5 sm:text-sm"><ShoppingBasket className="h-4 w-4" /><span className="sm:hidden">Add</span><span className="hidden sm:inline">Add to cart</span></button>
			</div>
		</article>
	)
}
