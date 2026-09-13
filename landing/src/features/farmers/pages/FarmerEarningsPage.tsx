import { ArrowUpRight, TrendingUp, Wallet } from 'lucide-react'

import { useFarmerEarnings } from '../../../core/lib'
import { EmptyState } from '../../../shared/components/feedback'
import { Card, StatCard } from '../../../shared/components/cards'
import { Skeleton } from '../../../shared/components/ui'

export function FarmerEarningsPage() {
	const { summary, payouts, isLoading: earningsLoading } = useFarmerEarnings()

	const metrics = [
		['Total earned', summary?.total_payout_amount],
		['Completed', summary?.completed_payout_amount],
		['Pending', summary?.pending_payout_amount],
		['Today', summary?.today_payout_amount],
	] as const

	return (
		<main className="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
			<div className="border-b border-border pb-8">
				<p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Your money</p>
				<h1 className="mt-2 text-3xl font-semibold text-primary-dark sm:text-4xl">Earnings & payouts</h1>
				<p className="mt-3 text-sm text-muted-foreground">Follow what your harvest has earned and what is still processing.</p>
			</div>

			{earningsLoading ? (
				<div className="mt-8 grid grid-cols-2 gap-4 sm:grid-cols-2 lg:grid-cols-4">
					{Array.from({ length: 4 }).map((_, index) => (
						<div key={index} className="rounded-2xl border border-border bg-card p-5">
							<Skeleton className="h-4 w-20 rounded-md" />
							<Skeleton className="mt-4 h-8 w-24 rounded-md" />
						</div>
					))}
				</div>
			) : (
				<div className="mt-8 grid grid-cols-2 gap-4 sm:grid-cols-2 lg:grid-cols-4">
					{metrics.map(([label, value]) => (
						<StatCard
							key={label}
							title={label}
							value={`KSh ${Number(value ?? 0).toLocaleString()}`}
							icon={<TrendingUp className="h-5 w-5" />}
							variant="default"
							className="min-w-0"
						/>
					))}
				</div>
			)}

			<Card className="mt-8 overflow-hidden" padding="none">
				<div className="flex items-center justify-between border-b border-border p-5">
					<div className="flex items-center gap-3">
						<Wallet className="h-5 w-5 text-primary" />
						<h2 className="font-semibold text-primary-dark">Payout history</h2>
					</div>
					<span className="text-sm text-muted-foreground">{payouts.length} records</span>
				</div>

				{earningsLoading ? (
					<div className="p-8">
						<Skeleton className="h-6 w-48 rounded-md" />
					</div>
				) : payouts.length === 0 ? (
					<div className="p-6">
						<EmptyState
							title="No payouts yet"
							description="Your payout history will appear here after your first completed order."
							size="sm"
						/>
					</div>
				) : (
					payouts.map((payout) => (
						<div key={payout.uuid} className="flex items-center justify-between gap-4 border-b border-border p-5 last:border-b-0">
							<div>
								<p className="font-semibold text-primary-dark">Order payout</p>
								<p className="mt-1 text-xs capitalize text-muted-foreground">{payout.status} · {payout.created_at ? new Date(payout.created_at).toLocaleDateString() : 'Date pending'}</p>
							</div>
							<p className="flex items-center gap-1 font-bold text-primary-dark">
								KSh {Number(payout.amount ?? 0).toLocaleString()}
								<ArrowUpRight className="h-4 w-4 text-primary" />
							</p>
						</div>
					))
				)}
			</Card>
		</main>
	)
}
