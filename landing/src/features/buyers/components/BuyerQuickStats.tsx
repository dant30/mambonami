import { Heart, Package, Truck } from 'lucide-react'

import { StatCard } from '../../../shared/components/cards'

export function BuyerQuickStats({ openOrders, hasActiveOrder, wishlistCount, isLoading }: { openOrders: number; hasActiveOrder: boolean; wishlistCount: number; isLoading?: boolean }) {
	if (isLoading) return <section className="mt-5 grid grid-cols-3 gap-2 sm:gap-4">{[1, 2, 3].map((item) => <div key={item} className="h-24 animate-pulse rounded-2xl border border-border bg-card" />)}</section>
	return <section className="mt-5 grid grid-cols-3 gap-2 sm:gap-4">
		<StatCard title="Open orders" value={String(openOrders)} subtitle="Still in motion" icon={<Package className="h-5 w-5" />} variant="default" className="min-w-0" />
		<StatCard title="Delivering" value={hasActiveOrder ? '1' : 'None'} subtitle={hasActiveOrder ? 'Track your order' : 'No active order'} icon={<Truck className="h-5 w-5" />} variant="default" className="min-w-0" />
		<StatCard title="Saved items" value={String(wishlistCount)} subtitle="Ready for later" icon={<Heart className="h-5 w-5" />} variant="default" className="min-w-0" />
	</section>
}
