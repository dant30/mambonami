import { Heart, ShoppingBasket, Trash2 } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useEffect, useState } from 'react'

import { useAuth } from '../../../core/contexts/AuthContext'
import { addToCart, useWishlist } from '../../../core/lib'
import { guestWishlistStore } from '../../../core/lib'
import type { Product } from '../../../core/lib'
import { MarketplacePageHeader } from '../components/MarketplacePageHeader'

const fallbackImage = '/assets/images/produce.jpg'

export function WishlistPage() {
	const { isAuthenticated } = useAuth()
	const serverWishlist = useWishlist(isAuthenticated)
	const [guestItems, setGuestItems] = useState<Product[]>([])
	useEffect(() => setGuestItems(guestWishlistStore.getItems()), [])
	const removeGuest = (uuid: string) => setGuestItems(guestWishlistStore.remove(uuid))
	const serverItems = isAuthenticated && !serverWishlist.error ? serverWishlist.items : []
	const products = serverItems.map((item) => item.product)
	const items = isAuthenticated ? products : guestItems

	return <div><MarketplacePageHeader eyebrow="Saved for later" title="Keep the good finds close." description="Save produce while you browse. Sign in later to keep your wishlist connected to your account across devices." /><main className="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">{serverWishlist.isLoading && isAuthenticated ? <div className="py-16 text-center text-sm text-muted-foreground">Loading your saved produce...</div> : items.length === 0 ? <div className="rounded-3xl border border-dashed border-border bg-card px-6 py-16 text-center"><Heart className="mx-auto h-10 w-10 text-primary" /><h2 className="mt-5 text-2xl font-semibold text-primary-dark">Nothing saved yet</h2><p className="mx-auto mt-2 max-w-md text-sm leading-6 text-muted-foreground">Tap the heart on any product to build a shortlist for your next order.</p><Link to="/products" className="mt-7 inline-flex rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground">Explore produce</Link></div> : <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">{items.map((product) => <WishlistCard key={product.uuid} product={product} onRemove={isAuthenticated ? undefined : removeGuest} />)}</div>}</main></div>
}

function WishlistCard({ product, onRemove }: { product: Product; onRemove?: (uuid: string) => void }) {
	const price = Number(product.price_per_unit)
	return <article className="overflow-hidden rounded-2xl border border-border bg-card"><img src={product.image_url || product.image || fallbackImage} alt={product.name} className="aspect-[1.1/1] w-full object-cover" onError={(event) => { event.currentTarget.src = fallbackImage }} /><div className="p-5"><Link to={`/product/${product.uuid}`} className="text-lg font-semibold text-primary-dark hover:text-primary">{product.name}</Link><p className="mt-2 text-sm font-bold text-primary-dark">KSh {price.toLocaleString()} <span className="font-normal text-muted-foreground">/ {product.unit}</span></p><div className="mt-5 flex gap-2"><button type="button" onClick={() => addToCart({ product_uuid: product.uuid, quantity: 1, unit_price: product.price_per_unit, product_detail: product })} className="flex flex-1 items-center justify-center gap-2 rounded-full bg-primary px-3 py-2.5 text-xs font-bold text-primary-foreground"><ShoppingBasket className="h-4 w-4" />Add to cart</button>{onRemove && <button type="button" onClick={() => onRemove(product.uuid)} aria-label={`Remove ${product.name}`} className="rounded-full border border-border p-2.5 text-muted-foreground hover:text-destructive"><Trash2 className="h-4 w-4" /></button>}</div></div></article>
}
