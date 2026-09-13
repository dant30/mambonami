import { Grid } from '../../../shared/components/ui/Grid'
import type { Product } from '../../../core/lib'
import { MarketplaceProductCard } from './MarketplaceProductCard'

export function ProductGrid({ products, loading }: { products: Product[]; loading?: boolean }) {
	return <Grid items={products} loading={loading} columns="auto" gap={5} ariaLabel="Available produce" keyExtractor={(product) => product.uuid} renderItem={({ item }) => <MarketplaceProductCard product={item} />} emptyTitle="No produce listed yet" emptyDescription="Our growers are preparing the next harvest. Check back soon." />
}
