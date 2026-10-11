import { ArrowLeft, Check, Heart, MapPin, ShoppingBasket, Star, Truck } from 'lucide-react'
import { Link, useParams } from 'react-router-dom'
import { useEffect, useState } from 'react'

import { useAuth } from '../../../core/contexts/AuthContext'
import { useSeo } from '../../../core/hooks'
import { addToCart, addToWishlist, createProductReview, guestWishlistStore, listProductReviews, useProduct, useProducts } from '../../../core/lib'
import type { ProductReview } from '../../../core/lib'
import { buildBreadcrumbJsonLd, buildProductJsonLd } from '../../../core/utils/seo'
import { Select } from '../../../shared/components/ui'
import { MarketplaceProductGrid } from '../components/MarketplaceProductGrid'

const fallbackImage = '/assets/images/produce.jpg'

export function ProductDetailPage() {
	const { id = '' } = useParams()
	const { product, isLoading, error } = useProduct(id)
	const { isAuthenticated } = useAuth()
	const { products: relatedProducts } = useProducts({ page_size: 4, category: product?.category_detail?.code })
	const productImage = product?.image_url || product?.image || fallbackImage
	const productDescription = product?.description || `Buy ${product?.name ?? 'fresh produce'} direct from a Kenyan farmer on MAMBONAMI. Transparent pricing, secure M-Pesa payments and reliable delivery.`
	const productJsonLd = product ? [
		buildProductJsonLd({
			name: product.name,
			description: product.description,
			image: productImage,
			sku: product.sku,
			path: `/product/${product.uuid}`,
			price: product.price_per_unit,
			inStock: Number(product.available_quantity) > 0,
			category: product.category_detail?.name,
			sellerName: product.farmer_name,
			rating: product.rating,
			reviewCount: product.review_count,
		}),
		buildBreadcrumbJsonLd([{ name: 'Home', path: '/home' }, { name: 'Produce', path: '/products' }, { name: product.name, path: `/product/${product.uuid}` }]),
	] : undefined
	useSeo({ title: product?.name ?? 'Fresh Produce', description: productDescription, path: `/product/${id}`, image: productImage, type: 'product', noIndex: Boolean(isLoading || error || !product), jsonLd: productJsonLd })
	const [saved, setSaved] = useState(() => Boolean(id && guestWishlistStore.has(id)))
	const [reviews, setReviews] = useState<ProductReview[]>([])
	const [reviewError, setReviewError] = useState('')
	const [reviewMessage, setReviewMessage] = useState('')
	const [orderItem, setOrderItem] = useState('')
	const [rating, setRating] = useState('5')
	const [comment, setComment] = useState('')
	const [isSubmittingReview, setIsSubmittingReview] = useState(false)

	useEffect(() => {
		if (!id) return
		listProductReviews(id).then(setReviews).catch(() => setReviewError('Reviews are temporarily unavailable.'))
	}, [id])

	if (isLoading) return <main className="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8"><div className="grid animate-pulse gap-10 lg:grid-cols-2"><div className="aspect-square rounded-3xl bg-muted" /><div className="space-y-5"><div className="h-8 w-2/3 rounded bg-muted" /><div className="h-5 w-1/3 rounded bg-muted" /><div className="h-32 rounded bg-muted" /></div></div></main>
	if (error || !product) return <main className="mx-auto max-w-2xl px-4 py-24 text-center"><p className="text-xs font-bold uppercase tracking-[0.2em] text-primary">Product unavailable</p><h1 className="mt-3 text-4xl font-semibold text-primary-dark">We could not find that harvest.</h1><Link to="/products" className="mt-8 inline-flex rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground">Browse all produce</Link></main>

	const price = Number(product.price_per_unit)
	const toggleWishlist = async () => {
		if (saved) { guestWishlistStore.remove(product.uuid); setSaved(false); return }
		if (isAuthenticated) { try { await addToWishlist(product.uuid); setSaved(true); return } catch { setReviewError('Wishlist is temporarily unavailable.') } }
		guestWishlistStore.add(product)
		setSaved(true)
	}
	const submitReview = async (event: React.FormEvent) => {
		event.preventDefault()
		setReviewError('')
		setReviewMessage('')
		setIsSubmittingReview(true)
		try {
			const created = await createProductReview(product.uuid, { order_item: Number(orderItem), rating: Number(rating), comment })
			setReviews((current) => [created, ...current])
			setOrderItem('')
			setComment('')
			setReviewMessage('Thanks. Your review has been published.')
		} catch { setReviewError('We could not submit that review. Use a delivered order item ID for this product.') } finally { setIsSubmittingReview(false) }
	}

	return <div><main className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8"><Link to="/products" className="inline-flex items-center gap-2 text-sm font-bold text-primary"><ArrowLeft className="h-4 w-4" />Back to produce</Link><div className="mt-8 grid gap-10 lg:grid-cols-2 lg:gap-16"><div className="overflow-hidden rounded-3xl bg-muted"><img src={product.image_url || product.image || fallbackImage} alt={product.name} className="aspect-square w-full object-cover" onError={(event) => { event.currentTarget.src = fallbackImage }} /></div><div className="flex flex-col justify-center"><div className="flex flex-wrap gap-2"><span className="rounded-full bg-secondary px-3 py-1 text-xs font-bold text-primary-dark">{product.category_detail?.name ?? 'Fresh produce'}</span>{product.is_organic && <span className="rounded-full bg-primary/10 px-3 py-1 text-xs font-bold text-primary">Organic</span>}</div><h1 className="mt-5 text-4xl font-semibold text-primary-dark sm:text-5xl">{product.name}</h1>{product.variety && <p className="mt-2 text-lg text-muted-foreground">{product.variety}</p>}<div className="mt-6 flex flex-wrap items-center gap-4"><p className="text-3xl font-bold text-primary-dark">KSh {Number.isFinite(price) ? price.toLocaleString() : product.price_per_unit}</p><span className="text-sm text-muted-foreground">per {product.unit}</span>{product.rating !== null && product.rating !== undefined && <span className="flex items-center gap-1 text-sm font-semibold"><Star className="h-4 w-4 fill-secondary text-secondary" />{Number(product.rating).toFixed(1)} ({product.review_count ?? 0})</span>}</div><p className="mt-6 leading-7 text-muted-foreground">{product.description || 'Freshly sourced produce from a trusted local grower, prepared for reliable delivery from farm gate to doorstep.'}</p><div className="mt-8 grid gap-3 text-sm text-primary-dark sm:grid-cols-2"><span className="flex items-center gap-2"><Check className="h-4 w-4 text-primary" />{Number(product.available_quantity) > 0 ? `${product.available_quantity} ${product.unit} available` : 'Currently unavailable'}</span><span className="flex items-center gap-2"><Truck className="h-4 w-4 text-primary" />Local delivery available</span>{product.farmer_name && <span className="flex items-center gap-2"><MapPin className="h-4 w-4 text-primary" />From {product.farmer_name}</span>}</div><div className="mt-9 flex flex-wrap gap-3"><button type="button" onClick={() => addToCart({ product_uuid: product.uuid, quantity: 1, unit_price: product.price_per_unit, product_detail: product })} disabled={Number(product.available_quantity) <= 0} className="inline-flex items-center gap-2 rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground disabled:opacity-50"><ShoppingBasket className="h-4 w-4" />Add to cart</button><button type="button" onClick={() => void toggleWishlist()} aria-label={saved ? 'Remove from wishlist' : 'Save to wishlist'} className={`inline-flex items-center gap-2 rounded-full border border-border px-5 py-3 text-sm font-bold ${saved ? 'text-red-600' : 'text-primary-dark'}`}><Heart className="h-4 w-4" fill={saved ? 'currentColor' : 'none'} />{saved ? 'Saved' : 'Save'}</button></div></div></div></main><section className="mx-auto max-w-7xl px-4 pb-10 sm:px-6 lg:px-8"><div className="grid gap-6 lg:grid-cols-[1.2fr_0.8fr]"><section className="rounded-2xl border border-border bg-card p-6"><div className="flex items-center justify-between gap-4"><h2 className="text-2xl font-semibold text-primary-dark">Customer reviews</h2><span className="text-sm text-muted-foreground">{reviews.length} shown</span></div>{reviewError && <p role="alert" className="mt-4 text-sm text-destructive">{reviewError}</p>}{reviews.length === 0 ? <p className="mt-6 text-sm text-muted-foreground">No reviews yet. Be the first verified buyer to share your experience.</p> : <div className="mt-6 divide-y divide-border">{reviews.map((review) => <article key={review.uuid} className="py-5 first:pt-0 last:pb-0"><div className="flex items-center justify-between gap-3"><p className="font-semibold text-primary-dark">{review.buyer_name || 'Verified buyer'}</p><span className="flex items-center gap-1 text-sm font-semibold"><Star className="h-4 w-4 fill-secondary text-secondary" />{review.rating}/5</span></div><p className="mt-2 text-sm leading-6 text-muted-foreground">{review.comment || 'No written comment.'}</p></article>)}</div>}</section><section className="rounded-2xl border border-border bg-card p-6"><h2 className="text-xl font-semibold text-primary-dark">Share your experience</h2>{!isAuthenticated ? <p className="mt-3 text-sm leading-6 text-muted-foreground">Sign in after your delivery to review this product.</p> : <form onSubmit={submitReview} className="mt-5 space-y-4"><label className="block text-sm font-semibold text-primary-dark">Delivered order item ID<input required type="number" min="1" value={orderItem} onChange={(event) => setOrderItem(event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-3 py-2.5 font-normal" /></label><label className="block text-sm font-semibold text-primary-dark">Rating</label><Select aria-label="Review rating" value={rating} onChange={setRating} className="mt-2" options={[{ value: '5', label: '5 - Excellent' }, { value: '4', label: '4 - Good' }, { value: '3', label: '3 - Average' }, { value: '2', label: '2 - Fair' }, { value: '1', label: '1 - Poor' }]} /><label className="block text-sm font-semibold text-primary-dark">Comment<textarea value={comment} onChange={(event) => setComment(event.target.value)} rows={4} maxLength={1000} className="mt-2 w-full rounded-xl border border-border bg-background px-3 py-2.5 font-normal" /></label>{reviewMessage && <p role="status" className="text-sm text-primary">{reviewMessage}</p>}<button type="submit" disabled={isSubmittingReview} className="rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground disabled:opacity-60">{isSubmittingReview ? 'Publishing...' : 'Publish review'}</button></form>}</section></div></section>{relatedProducts.length > 0 && <section className="mx-auto max-w-7xl px-4 pb-16 sm:px-6 lg:px-8"><h2 className="text-2xl font-semibold text-primary-dark">More from this harvest</h2><div className="mt-6"><MarketplaceProductGrid products={relatedProducts.filter((item) => item.uuid !== product.uuid)} /></div></section>}</div>
}
