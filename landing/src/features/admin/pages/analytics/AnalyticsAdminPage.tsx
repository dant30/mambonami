import { useMemo } from 'react'

import { BarChart, LineChart } from '../../../../shared/components/charts'
import { StatCard } from '../../../../shared/components/cards/StatCard'
import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { getAdminAnalyticsSummary, listAdminDailyMetrics, recomputeAdminMetrics, useAdminResource } from '../../../../core/lib'
import type { AdminAnalyticsSummary, AdminDailyMetric } from '../../../../core/lib/types/admin'
import { MetricsRecomputeButton } from './components/MetricsRecomputeButton'

interface AnalyticsData {
	metrics: AdminDailyMetric[]
	summary: AdminAnalyticsSummary
}

async function loadAnalytics(): Promise<AnalyticsData> {
	const [metrics, summary] = await Promise.all([listAdminDailyMetrics(), getAdminAnalyticsSummary()])
	return { metrics, summary }
}

export function AnalyticsAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(loadAnalytics)
	const today = useMemo(() => new Date().toISOString().slice(0, 10), [])
	const summary = data?.summary ?? {}
	const columns = [
		{ header: 'Date', render: (metric: AdminDailyMetric) => metric.date },
		{ header: 'Orders', render: (metric: AdminDailyMetric) => `${metric.total_orders} total · ${metric.completed_orders} completed` },
		{ header: 'Sales', render: (metric: AdminDailyMetric) => `KES ${metric.total_sales}` },
		{ header: 'Commission', render: (metric: AdminDailyMetric) => `KES ${metric.platform_commission}` },
		{ header: 'Collections', render: (metric: AdminDailyMetric) => `${metric.collections_count} · KES ${metric.total_collections_amount}` },
		{ header: 'Payouts', render: (metric: AdminDailyMetric) => `${metric.payouts_count} · KES ${metric.total_payouts_amount}` },
	]
	return <AdminPageLayout section="analytics" title="Analytics" loading={loading} error={error} notice={notice} onRefresh={refresh}>
		<div className="mb-5 flex justify-end"><MetricsRecomputeButton busy={busy === 'metrics'} onRecompute={() => void runAction('metrics', () => recomputeAdminMetrics(today, today), 'Metrics recomputation started.')} /></div>
		<div className="grid grid-cols-2 gap-3 sm:gap-4 xl:grid-cols-4">
			<StatCard title="Orders · 30 days" value={summary.total_orders ?? 0} subtitle={`${summary.completed_orders ?? 0} completed`} variant="flat" />
			<StatCard title="Sales · 30 days" value={`KES ${summary.total_sales ?? 0}`} subtitle="Recorded marketplace sales" variant="flat" />
			<StatCard title="Platform commission" value={`KES ${summary.platform_commission ?? 0}`} subtitle="Recorded commission" variant="flat" />
			<StatCard title="Farmer payouts" value={`KES ${summary.total_paid_to_farmers ?? 0}`} subtitle={`Transport: KES ${summary.total_paid_to_transport ?? 0}`} variant="flat" />
		</div>
		<div className="mt-8 grid gap-5 xl:grid-cols-2">
			<LineChart title="Orders by day" subtitle="Total orders and completed orders" data={[...(data?.metrics ?? [])].slice(0, 30).reverse().map((metric) => ({ label: metric.date.slice(5), value: metric.total_orders, secondaryValue: metric.completed_orders }))} lineColor="#0A6B50" secondaryLineColor="#E67E22" />
			<BarChart title="Sales by day" subtitle="Recorded sales in KES" data={[...(data?.metrics ?? [])].slice(0, 14).reverse().map((metric) => ({ label: metric.date.slice(5), value: Number(metric.total_sales), formattedValue: `KES ${Number(metric.total_sales).toLocaleString()}` }))} accentColor="#E67E22" />
		</div>
		<div className="mt-8"><h2 className="mb-3 text-lg font-semibold text-primary-dark">Daily metrics</h2><DataTable data={data?.metrics ?? []} columns={columns} keyExtractor={(metric) => metric.uuid || metric.date} emptyMessage="No daily metrics have been generated yet." /></div>
	</AdminPageLayout>
}