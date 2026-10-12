import { Grid } from '../../../shared/components/ui/Grid'
import type { Product } from '../../../core/lib'
import { MarketplaceProductCard } from './MarketplaceProductCard'

export function ProductGrid({ products, loading }: { products: Product[]; loading?: boolean }) {
	return <Grid items={products} loading={loading} columns={2} smColumns={2} lgColumns={3} xlColumns={4} gap={3} ariaLabel="Available produce" keyExtractor={(product) => product.uuid} renderItem={({ item }) => <MarketplaceProductCard product={item} />} emptyTitle="No produce listed yet" emptyDescription="Our growers are preparing the next harvest. Check back soon." />
}
