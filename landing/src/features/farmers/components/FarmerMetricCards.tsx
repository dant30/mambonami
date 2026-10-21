import { BarChart3, ClipboardList, Package, Wallet } from 'lucide-react'

import type { FarmerDashboardSummary, Product } from '../../../core/lib'
import { StatCard } from '../../../shared/components/cards'
import { Skeleton } from '../../../shared/components/ui'

export function FarmerMetricCards({ summary, products, isLoading }: { summary: FarmerDashboardSummary | null; products: Product[]; isLoading?: boolean }) {
	if (isLoading) return <section aria-label="Farm performance" className="grid grid-cols-2 gap-3 lg:grid-cols-4">{[1, 2, 3, 4].map((item) => <div key={item} className="rounded-2xl border border-border bg-card p-4"><Skeleton className="h-4 w-24" /><Skeleton className="mt-4 h-8 w-20" /><Skeleton className="mt-3 h-3 w-28" /></div>)}</section>
	const lowStockCount = products.filter((product) => product.is_active !== false && Number(product.available_quantity) <= 10).length
	const needsAttentionCount = products.filter((product) => product.is_active === false).length
	return <section aria-label="Farm performance" className="grid grid-cols-2 gap-3 lg:grid-cols-4"><StatCard title="Active products" value={String(summary?.activeProductCount ?? 0)} subtitle={`Visible to buyers · ${lowStockCount} low stock`} icon={<Package className="h-5 w-5" />} variant="default" className="min-w-0" /><StatCard title="Orders to fulfil" value={String(summary?.pendingOrderCount ?? 0)} subtitle={`${summary?.pendingOrderCount ?? 0} pending · ${needsAttentionCount} listings need attention`} icon={<ClipboardList className="h-5 w-5" />} variant="default" className="min-w-0" /><StatCard title="Sales" value={`KSh ${Number(summary?.completedSales ?? 0).toLocaleString()}`} subtitle="Completed sales" icon={<BarChart3 className="h-5 w-5" />} variant="default" className="min-w-0" /><StatCard title="Pending payout" value={`KSh ${Number(summary?.pendingPayout ?? 0).toLocaleString()}`} subtitle="Awaiting settlement" icon={<Wallet className="h-5 w-5" />} variant="default" className="min-w-0" /></section>
}