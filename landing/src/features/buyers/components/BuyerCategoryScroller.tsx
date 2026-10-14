import { Leaf } from 'lucide-react'
import { Link } from 'react-router-dom'

import type { ProductCategory } from '../../../core/lib'
import { Skeleton } from '../../../shared/components/ui'

const fallbackCategories: ProductCategory[] = [
	{ id: 0, code: 'MA', name: 'Matunda' },
	{ id: 1, code: 'MBO', name: 'Mboga' },
	{ id: 2, code: 'NA', name: 'Nafaka' },
	{ id: 3, code: 'MI', name: 'Mizizi' },
]

const categoryNames: Record<string, string> = {
	MA: 'Matunda',
	MBO: 'Mboga',
	NA: 'Nafaka',
	MI: 'Mizizi',
}

export function BuyerCategoryScroller({ categories, isLoading }: { categories: ProductCategory[]; isLoading?: boolean }) {
	const visible = categories.length > 0 ? categories.slice(0, 8) : fallbackCategories

	return (
		<section className="mt-5 sm:mt-7" aria-labelledby="buyer-categories">
			<div className="flex items-center justify-between gap-3">
				<h2 id="buyer-categories" className="text-base font-semibold text-primary-dark sm:text-lg">Categories</h2>
				<Link to="/app/buyer/products" className="shrink-0 text-xs font-bold text-primary sm:text-sm">View all</Link>
			</div>
			<div className="mobile-scroll-row mt-2 flex gap-2 overflow-x-auto pb-1">
				{isLoading
					? [1, 2, 3, 4].map((item) => <Skeleton key={item} className="h-11 w-28 shrink-0 rounded-full" />)
					: visible.map((category) => {
							const code = category.code.toUpperCase()
							return (
								<Link
									key={category.code}
									to={`/app/buyer/products?category=${encodeURIComponent(category.code)}`}
									className="inline-flex min-h-11 shrink-0 items-center gap-2 rounded-full border border-border bg-card px-3 py-2 text-xs font-bold text-primary-dark transition hover:border-primary/30 hover:bg-primary/5"
								>
									<span className="flex h-7 w-7 items-center justify-center rounded-full bg-primary/10 text-primary"><Leaf className="h-4 w-4" /></span>
									{categoryNames[code] || category.name}
								</Link>
							)
						})}
			</div>
		</section>
	)
}
