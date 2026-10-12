import { ArrowLeft, ArrowRight, Minus, Plus, ShoppingBasket, Trash2 } from 'lucide-react'
import { Link, useNavigate } from 'react-router-dom'
import { useEffect, useState } from 'react'

import { useBuyerCart, useBuyerCartActions } from '../../../core/lib'
import type { CartItem } from '../../../core/lib'

const fallbackImage = '/assets/images/produce.jpg'

export function BuyerCartPage() {
	const navigate = useNavigate()
	const { cart: hydratedCart, isLoading } = useBuyerCart()
	const { update, remove, isBusy, error } = useBuyerCartActions()
	const [items, setItems] = useState<CartItem[]>(hydratedCart)

	useEffect(() => setItems(hydratedCart), [hydratedCart])

	const applyCartChange = async (action: () => CartItem[] | Promise<CartItem[]>) => {
		setItems(await action())
	}

	const changeQuantity = (uuid: string, quantity: number) => {
		if (quantity < 1) return void applyCartChange(() => remove(uuid))
		void applyCartChange(() => update(uuid, quantity))
	}

	const itemCount = items.reduce((total, item) => total + Number(item.quantity), 0)
	const subtotal = items.reduce((total, item) => total + Number(item.unit_price ?? 0) * Number(item.quantity), 0)

	return (
		<main className="min-h-full bg-background">
			<div className="mx-auto max-w-7xl px-4 py-4 pb-[calc(5.5rem+env(safe-area-inset-bottom))] sm:px-6 sm:py-8 sm:pb-8 lg:px-8">
				<div className="border-b border-border pb-4 sm:pb-6">
					<p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Buyer workspace</p>
					<h1 className="mt-2 text-2xl font-semibold text-primary-dark sm:text-4xl">Your shopping cart</h1>
					<p className="mt-2 text-sm leading-5 text-muted-foreground sm:mt-3 sm:leading-normal">Review your produce, adjust quantities, and get ready for checkout.</p>
				</div>

				{Boolean(error) && <p role="alert" className="mt-6 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">Your cart could not be updated. Please try again.</p>}

				{isLoading ? <div className="mt-8 space-y-3">{[1, 2, 3].map((item) => <div key={item} className="h-32 animate-pulse rounded-2xl bg-muted" />)}</div> : items.length === 0 ? (
					<div className="mt-5 rounded-2xl border border-dashed border-border bg-card px-5 py-8 text-center sm:mt-8 sm:rounded-3xl sm:px-6 sm:py-16">
						<ShoppingBasket className="mx-auto h-10 w-10 text-primary" />
						<h2 className="mt-5 text-2xl font-semibold text-primary-dark">Your cart is empty</h2>
						<p className="mx-auto mt-2 max-w-md text-sm leading-6 text-muted-foreground">Browse fresh produce and add your next order to the cart.</p>
						<Link to="/app/buyer/products" className="mt-7 inline-flex items-center gap-2 rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground">Browse produce <ArrowRight className="h-4 w-4" /></Link>
					</div>
				) : (
					<div className="mt-5 grid gap-4 sm:mt-8 sm:gap-8 lg:grid-cols-[1fr_22rem]">
						<section className="space-y-3">
							{items.map((item) => {
								const product = item.product_detail
								const price = Number(item.unit_price ?? 0)
								const quantity = Number(item.quantity)
								return <article key={item.product_uuid} className="flex gap-3 rounded-xl border border-border bg-card p-3 sm:gap-4 sm:rounded-2xl sm:p-5">
													<img src={product?.image_url || product?.image || fallbackImage} alt={product?.name || 'Cart item'} className="h-20 w-20 shrink-0 rounded-lg object-cover sm:h-32 sm:w-32 sm:rounded-xl" loading="lazy" />
									<div className="min-w-0 flex-1">
										<div className="flex items-start justify-between gap-1"><div className="min-w-0"><Link to={`/product/${item.product_uuid}`} className="line-clamp-2 text-sm font-semibold text-primary-dark hover:text-primary sm:text-base">{product?.name || 'Fresh produce'}</Link><p className="mt-1 text-xs text-muted-foreground sm:text-sm">KSh {price.toLocaleString()} / {product?.unit || 'unit'}</p></div><button type="button" disabled={isBusy} onClick={() => void applyCartChange(() => remove(item.product_uuid))} className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full text-muted-foreground hover:bg-destructive/10 hover:text-destructive disabled:opacity-50" aria-label={`Remove ${product?.name || 'item'}`}><Trash2 className="h-4 w-4" /></button></div>
										<div className="mt-3 flex flex-wrap items-center justify-between gap-2 sm:mt-5 sm:gap-3"><div className="flex h-10 items-center rounded-full border border-border"><button type="button" disabled={isBusy} onClick={() => changeQuantity(item.product_uuid, quantity - 1)} className="flex h-10 w-10 items-center justify-center text-primary disabled:opacity-50" aria-label="Decrease quantity"><Minus className="h-4 w-4" /></button><span className="min-w-8 text-center text-sm font-bold">{quantity}</span><button type="button" disabled={isBusy} onClick={() => changeQuantity(item.product_uuid, quantity + 1)} className="flex h-10 w-10 items-center justify-center text-primary disabled:opacity-50" aria-label="Increase quantity"><Plus className="h-4 w-4" /></button></div><p className="text-sm font-bold text-primary-dark sm:text-base">KSh {(price * quantity).toLocaleString()}</p></div>
									</div>
								</article>
							})}
						</section>

						<aside className="hidden h-fit rounded-2xl border border-border bg-primary-dark p-6 text-primary-foreground md:sticky md:top-24 md:block">
							<p className="text-xs font-bold uppercase tracking-[0.18em] text-secondary">Order summary</p>
							<div className="mt-6 space-y-3 text-sm"><div className="flex justify-between text-primary-foreground/75"><span>{itemCount} items</span><span>KSh {subtotal.toLocaleString()}</span></div><div className="flex justify-between text-primary-foreground/75"><span>Delivery</span><span>Calculated at checkout</span></div><div className="flex justify-between border-t border-primary-foreground/20 pt-4 text-lg font-bold"><span>Subtotal</span><span>KSh {subtotal.toLocaleString()}</span></div></div>
							<button type="button" onClick={() => navigate('/app/buyer/checkout')} className="mt-7 flex w-full items-center justify-center gap-2 rounded-full bg-secondary px-5 py-3.5 text-sm font-bold text-primary-dark">Checkout <ArrowRight className="h-4 w-4" /></button>
							<Link to="/app/buyer/products" className="mt-4 inline-flex items-center gap-2 text-sm font-semibold text-primary-foreground/75 hover:text-secondary"><ArrowLeft className="h-4 w-4" />Continue shopping</Link>
						</aside>
					</div>
				)}
				{!isLoading && items.length > 0 && <div className="fixed inset-x-0 bottom-[calc(3.75rem+env(safe-area-inset-bottom))] z-30 grid grid-cols-[1fr_auto] items-center gap-3 border-t border-border bg-background/95 px-4 py-3 shadow-[0_-8px_24px_-18px_rgba(41,74,54,0.55)] backdrop-blur-xl md:hidden"><div className="min-w-0"><p className="text-[10px] font-semibold text-muted-foreground">{itemCount} items</p><p className="truncate text-base font-bold text-primary-dark">KSh {subtotal.toLocaleString()}</p></div><button type="button" onClick={() => navigate('/app/buyer/checkout')} className="inline-flex min-h-11 items-center justify-center gap-2 rounded-full bg-primary px-5 py-2.5 text-sm font-bold text-primary-foreground">Checkout <ArrowRight className="h-4 w-4" /></button></div>}
			</div>
		</main>
	)
}
