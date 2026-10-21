import { Package } from 'lucide-react'
import { Link } from 'react-router-dom'
import type { Product } from '../../../core/lib'
import { Card, CardHeader } from '../../../shared/components/cards'

export function FarmerProductPreview({ products }: { products: Product[] }) {
	const fallbackImage = '/assets/images/produce.jpg'
	return (
		<Card padding="none" className="overflow-hidden">
			<CardHeader
				title="My products"
				description="Your current storefront supply."
				icon={<Package className="h-5 w-5" />}
				action={<Link to="/app/farmer/products" className="text-sm font-bold text-primary transition-colors hover:text-primary-dark">View all</Link>}
			/>
			{products.length === 0 ? (
				<div className="border-t border-border bg-muted/20 p-8 text-center">
					<div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-primary">
						<Package className="h-6 w-6" />
					</div>
					<p className="mt-3 text-sm text-muted-foreground">Add your first product to start selling.</p>
					<Link to="/app/farmer/products/new" className="mt-4 inline-flex rounded-xl bg-primary px-4 py-2 text-xs font-bold text-primary-foreground transition-colors hover:bg-primary-dark">
						Add product
					</Link>
				</div>
			) : (
				<div>
					{products.slice(0, 5).map((product) => (
						<div key={product.uuid} className="flex items-center gap-3 border-t border-border p-4 first:border-t-0 sm:gap-4">
							<img src={product.image_url || product.image || fallbackImage} alt="" className="h-14 w-14 shrink-0 rounded-lg object-cover" onError={(event) => { event.currentTarget.src = fallbackImage }} />
							<div className="min-w-0 flex-1">
								<p className="font-semibold text-foreground">{product.name}</p>
								<p className="mt-1 text-xs text-muted-foreground">
									KSh {Number(product.price_per_unit).toLocaleString()} / {product.unit} · {product.available_quantity} {product.unit} available
								</p>
							</div>
							<div className="flex shrink-0 items-center gap-2">
								<span
								className={`rounded-full px-2.5 py-1 text-[10px] font-bold uppercase ${
									Number(product.available_quantity) > 0
										? 'bg-primary/10 text-primary'
										: 'bg-secondary/20 text-secondary-foreground'
								}`}
								>{Number(product.available_quantity) > 0 ? 'Active' : 'Low stock'}</span>
								<Link to={`/app/farmer/products/${product.uuid}/edit`} className="text-xs font-bold text-primary hover:text-primary-dark">Manage</Link>
							</div>
						</div>
					))}
				</div>
			)}
		</Card>
	)
}
