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
		<article className="group overflow-hidden rounded-[1.25rem] border border-border bg-card shadow-sm transition duration-300 hover:-translate-y-1 hover:shadow-soft">
			<div className="relative overflow-hidden">
				<Link to={`/product/${product.uuid}`} aria-label={`View ${product.name}`}>
					<img src={image} alt={product.name} className="aspect-[1.05/1] w-full object-cover transition duration-500 group-hover:scale-105" onError={(event) => { event.currentTarget.src = fallbackImage }} />
				</Link>
				<div className="absolute left-3 top-3 flex flex-wrap gap-2">
					<span className="rounded-full bg-white/90 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.12em] text-primary-dark backdrop-blur-sm">{product.category_detail?.name ?? 'Fresh produce'}</span>
					{product.is_organic && <span className="rounded-full bg-secondary px-3 py-1 text-[10px] font-bold uppercase tracking-[0.12em] text-primary-dark">Organic</span>}
				</div>
				<button type="button" onClick={toggleWishlist} aria-label={inWishlist ? `Remove ${product.name} from wishlist` : `Save ${product.name} to wishlist`} className={`absolute right-3 top-3 flex h-10 w-10 items-center justify-center rounded-full bg-white/95 shadow-sm transition hover:bg-secondary ${inWishlist ? 'text-red-600' : 'text-primary-dark'}`}><Heart className="h-4 w-4" fill={inWishlist ? 'currentColor' : 'none'} /></button>
			</div>
			<div className="p-4 sm:p-5">
				<Link to={`/product/${product.uuid}`} className="block">
					<h3 className="text-lg font-semibold text-primary-dark group-hover:text-primary">{product.name}</h3>
					{product.variety && <p className="mt-1 text-sm text-muted-foreground">{product.variety}</p>}
				</Link>
				<div className="mt-4 flex items-end justify-between gap-3"><p className="text-base font-bold text-primary-dark">{formatPrice(product.price_per_unit)}</p><span className="text-xs text-muted-foreground">per {product.unit}</span></div>
				{product.farmer_name && <p className="mt-3 text-xs text-muted-foreground">From {product.farmer_name}</p>}
				<button type="button" onClick={() => addToCart({ product_uuid: product.uuid, quantity: 1, unit_price: product.price_per_unit, product_detail: product })} className="mt-4 flex w-full items-center justify-center gap-2 rounded-full bg-primary px-4 py-2.5 text-sm font-bold text-primary-foreground transition hover:bg-primary-dark"><ShoppingBasket className="h-4 w-4" />Add to cart</button>
			</div>
		</article>
	)
}
