import { useHomeProducts } from '../../../core/lib'
import { CallToAction, CategoryScroller, DeliverySection, FarmerSpotlight, FeaturedProducts, HeroSection, HowMambonamiWorks, PopularProducts, TrustSection } from '../components'

export function HomePage() {
	const { products, isLoading, error } = useHomeProducts()
	return <div className="min-h-screen overflow-x-hidden bg-background text-foreground"><main id="top"><HeroSection /><CategoryScroller /><FeaturedProducts products={products} loading={isLoading} error={error} /><PopularProducts /><FarmerSpotlight products={products} /><HowMambonamiWorks /><DeliverySection /><TrustSection /><CallToAction /></main></div>
}
