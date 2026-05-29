import Hero from '../components/ui/Hero'
import FeatureCard from '../components/ui/FeatureCard'
import Card from '../components/ui/Card'
import Button from '../components/ui/Button'

export default function Home() {
  return (
    <div>
      <Hero
        title="Fresh from Farm to Table"
        subtitle="Connect directly with farmers, get the freshest produce delivered to your doorstep"
        ctaText="Get Started"
        ctaLink="/contact"
      />
      <section className="py-16 container-custom">
        <h2 className="text-3xl font-bold text-center mb-12">Why MAMBONAMI?</h2>
        <div className="grid md:grid-cols-3 gap-8">
          <FeatureCard icon="ðŸŒ±" title="For Farmers" description="Fair prices, direct access to markets, no middlemen." />
          <FeatureCard icon="ðŸ›’" title="For Buyers" description="Fresh produce, transparent pricing, doorstep delivery." />
          <FeatureCard icon="ðŸšš" title="For Transporters" description="Earn by delivering farm fresh goods." />
        </div>
      </section>
      <section className="bg-gray-100 py-16">
        <div className="container-custom text-center">
          <Card title="Ready to experience fresh produce?" className="max-w-2xl mx-auto">
            <p className="mb-6">Join MAMBONAMI today and enjoy farm-fresh goodness delivered to your home.</p>
            <Button variant="primary" size="lg">Download App</Button>
          </Card>
        </div>
      </section>
    </div>
  )
}