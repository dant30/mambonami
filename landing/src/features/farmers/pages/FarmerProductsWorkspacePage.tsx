import { Edit3, LoaderCircle, PackagePlus, Trash2 } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useState } from 'react'

import { deleteFarmerWorkspaceProduct, useFarmerProductsWorkspace } from '../../../core/lib'
import { getErrorMessage } from '../../../core/utils'
import { EmptyState } from '../../../shared/components/feedback'

const fallbackImage = '/assets/images/produce.jpg'

export function FarmerProductsWorkspacePage() {
	const { products, isLoading, error, refresh } = useFarmerProductsWorkspace()
	const [deleting, setDeleting] = useState<string | null>(null)
	const [deleteError, setDeleteError] = useState('')

	const remove = async (uuid: string) => {
		if (!window.confirm('Remove this product from your listings?')) return
		setDeleting(uuid)
		setDeleteError('')
		try {
			await deleteFarmerWorkspaceProduct(uuid)
			refresh()
		} catch (requestError) {
			setDeleteError(getErrorMessage(requestError, 'We could not remove that product. Please try again.'))
		} finally {
			setDeleting(null)
		}
	}

	return (
		<main className="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
			<header className="flex flex-col gap-5 border-b border-border pb-8 sm:flex-row sm:items-end sm:justify-between">
				<div>
					<p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Your storefront</p>
					<h1 className="mt-2 text-3xl font-semibold text-primary-dark sm:text-4xl">My products</h1>
					<p className="mt-3 text-sm text-muted-foreground">Keep availability, pricing and harvest details current.</p>
				</div>
				<Link to="/app/farmer/products/new" className="inline-flex items-center justify-center gap-2 rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground"><PackagePlus className="h-4 w-4" />Add product</Link>
			</header>

			{deleteError && <p role="alert" className="mt-6 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">{deleteError}</p>}
			{Boolean(error) && <p role="alert" className="mt-6 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">Unable to load your products.</p>}

			{isLoading ? (
				<div className="mt-8 grid gap-5 sm:grid-cols-2 lg:grid-cols-3" aria-label="Loading products">{[1, 2, 3].map((item) => <div key={item} className="h-80 animate-pulse rounded-2xl bg-muted" />)}</div>
			) : products.length === 0 ? (
				<div className="mt-8"><EmptyState title="Your storefront is empty" description="Add your first harvest so buyers can discover it." action={<Link to="/app/farmer/products/new" className="inline-flex rounded-full bg-primary px-4 py-2.5 text-sm font-bold text-primary-foreground">Add product</Link>} /></div>
			) : (
				<div className="mt-8 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
					{products.map((product) => {
						const quantity = Number(product.available_quantity)
						const isListed = product.is_active !== false
						const status = !isListed ? 'Unlisted' : quantity > 0 ? 'In stock' : 'Out of stock'
						const statusClass = !isListed ? 'bg-muted text-muted-foreground' : quantity > 0 ? 'bg-emerald-100 text-emerald-700' : 'bg-amber-100 text-amber-700'
						const isDeleting = deleting === product.uuid
						return (
							<article key={product.uuid} className="overflow-hidden rounded-2xl border border-border bg-card shadow-sm">
								<img src={product.image_url || product.image || fallbackImage} alt={product.name} className="aspect-[1.3/1] w-full object-cover" onError={(event) => { event.currentTarget.src = fallbackImage }} />
								<div className="p-5">
									<div className="flex items-start justify-between gap-3">
										<div><h2 className="font-semibold text-primary-dark">{product.name}</h2><p className="mt-1 text-sm text-muted-foreground">KSh {Number(product.price_per_unit).toLocaleString()} / {product.unit}</p></div>
										<span className={`rounded-full px-2.5 py-1 text-[10px] font-bold uppercase ${statusClass}`}>{status}</span>
									</div>
									<div className="mt-4 flex justify-between text-xs text-muted-foreground"><span>{product.available_quantity} {product.unit} available</span><span>{product.is_organic ? 'Organic' : 'Standard'}</span></div>
									<div className="mt-5 flex gap-2">
										<Link to={`/app/farmer/products/${product.uuid}/edit`} className="inline-flex flex-1 items-center justify-center gap-2 rounded-full border border-border px-3 py-2 text-xs font-bold text-primary-dark hover:bg-muted"><Edit3 className="h-3.5 w-3.5" />Edit</Link>
										<button type="button" disabled={isDeleting} onClick={() => void remove(product.uuid)} className="inline-flex items-center justify-center rounded-full border border-destructive/25 px-3 py-2 text-destructive hover:bg-destructive/10 disabled:opacity-50" aria-label={`Delete ${product.name}`} aria-busy={isDeleting}>{isDeleting ? <LoaderCircle className="h-4 w-4 animate-spin" /> : <Trash2 className="h-3.5 w-3.5" />}</button>
									</div>
								</div>
							</article>
						)
					})}
				</div>
			)}
		</main>
	)
}
