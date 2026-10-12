import { Link } from 'react-router-dom'

import { BarChart, LineChart } from '../../../../shared/components/charts'
import { EmptyState } from '../../../../shared/components/feedback/EmptyState'
import { AdminPageLayout, AdminRecord } from '../../components'
import {
	adminResourceCaches,
	listAdminAuditLogs,
	listAdminDisputes,
	listAdminDailyMetrics,
	listAdminFarmers,
	listAdminOrders,
	listAdminPayouts,
	listAdminTransportProviders,
	listAdminUsers,
useAdminResource,
	type AdminDashboardData,
	type Order,
} from '../../../../core/lib'
import { DashboardMetric } from './components/DashboardMetric'

const loadDashboard = async (): Promise<AdminDashboardData> => {
	const [orders, users, farmers, transportProviders, disputes, payouts, auditLogs, metrics] = await Promise.all([
		listAdminOrders(), listAdminUsers(), listAdminFarmers(), listAdminTransportProviders(),
		listAdminDisputes(), listAdminPayouts(), listAdminAuditLogs(), listAdminDailyMetrics(),
	])
	return { orders, users, farmers, transportProviders, disputes, payouts, auditLogs, metrics }
}

export function AdminDashboardPage() {
	const { data, loading, error, notice, refresh } = useAdminResource(loadDashboard, adminResourceCaches.dashboard)
	const overview = data ?? { orders: [], users: [], farmers: [], transportProviders: [], disputes: [], payouts: [], auditLogs: [], metrics: [] }
	const metrics = overview.metrics ?? []
	const pendingApprovals = overview.farmers.filter((farmer) => !farmer.coop_verified).length + overview.transportProviders.filter((provider) => !provider.is_approved).length
	const openDisputes = overview.disputes.filter((dispute) => ['open', 'under_review'].includes(dispute.status))

	return <AdminPageLayout section="overview" title="Overview" loading={loading} error={error} notice={notice} onRefresh={refresh}>
		<div className="grid grid-cols-2 gap-3 sm:gap-4 xl:grid-cols-4">
			<DashboardMetric title="Marketplace orders" value={overview.orders.length} subtitle="All recorded orders" to="/app/admin/orders" />
			<DashboardMetric title="User accounts" value={overview.users.length} subtitle="Across all account roles" to="/app/admin/users" />
			<DashboardMetric title="Pending approvals" value={pendingApprovals} subtitle="Farmers and transport providers" to="/app/admin/farmers" />
			<DashboardMetric title="Open disputes" value={openDisputes.length} subtitle="Cases requiring review" to="/app/admin/disputes" />
		</div>
		<div className="mt-8 grid gap-5 xl:grid-cols-2">
			<LineChart title="Daily orders" subtitle="Recent total and completed orders" data={[...metrics].slice(0, 14).reverse().map((metric) => ({ label: metric.date.slice(5), value: metric.total_orders, secondaryValue: metric.completed_orders }))} lineColor="#0A6B50" secondaryLineColor="#E67E22" />
			<BarChart title="Daily sales" subtitle="Recorded marketplace sales" data={[...metrics].slice(0, 10).reverse().map((metric) => ({ label: metric.date.slice(5), value: Number(metric.total_sales), formattedValue: `KES ${Number(metric.total_sales).toLocaleString()}` }))} accentColor="#E67E22" />
		</div>
		<div className="mt-8 grid gap-x-12 md:grid-cols-2">
			<div>
				<h2 className="text-lg font-semibold text-primary-dark">Needs attention</h2>
				<AdminRecord title={`${overview.farmers.filter((farmer) => !farmer.coop_verified).length} farmer approvals`} detail="Review cooperative verification and approve eligible farmer profiles." action={<Link className="text-sm font-bold text-primary underline" to="/app/admin/farmers">Review farmers</Link>} />
				<AdminRecord title={`${overview.transportProviders.filter((provider) => !provider.is_approved).length} transport approvals`} detail="Review provider profiles before assigning work." action={<Link className="text-sm font-bold text-primary underline" to="/app/admin/transport">Review transport</Link>} />
				<AdminRecord title={`${openDisputes.length} active disputes`} detail="Resolve open cases and record the decision." action={<Link className="text-sm font-bold text-primary underline" to="/app/admin/disputes">Open disputes</Link>} />
			</div>
			<div>
				<h2 className="text-lg font-semibold text-primary-dark">Recent orders</h2>
				{overview.orders.slice(0, 5).map((order: Order) => <AdminRecord key={order.uuid} title={`${order.buyer_name || order.buyer_phone || `Order ${order.uuid.slice(0, 8)}`} · ${order.status}`} detail={`${order.total_amount} · ${new Date(order.created_at).toLocaleString()}`} />)}
				{overview.orders.length === 0 && <EmptyState size="sm" title="No orders yet" description="Orders will appear here as buyers check out." />}
			</div>
		</div>
	</AdminPageLayout>
}