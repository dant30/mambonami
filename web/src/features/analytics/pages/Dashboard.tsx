
import { useNavigate } from 'react-router-dom';
import Card from '../../../shared/components/cards/Card';
import BarChart from '../../../shared/components/charts/BarChart';
import LineChart from '../../../shared/components/charts/LineChart';
import PieChart from '../../../shared/components/charts/PieChart';
import { useAnalytics } from '../hooks/useAnalytics';

export default function Dashboard() {
  const navigate = useNavigate();
  const { stats, loading, error } = useAnalytics();

  const navigationItems = [
    {
      title: 'Top Farmers',
      description: 'Highest selling farmers over the selected window',
      count: stats?.topFarmers.length,
      path: '/admin/farmers',
      variant: 'blue' as const,
    },
    {
      title: 'Transport Signals',
      description: 'Transport performance and delivery activity',
      count: stats?.topTransportProviders.length,
      path: '/admin/transport-providers',
      variant: 'purple' as const,
    },
    {
      title: 'Disputes',
      description: 'Tracked dispute activity from daily metrics',
      count: stats?.disputeStatusBreakdown.reduce((sum, item) => sum + item.value, 0),
      path: '/admin/disputes',
      variant: 'red' as const,
    },
    {
      title: 'Payments',
      description: 'Collections and payout throughput',
      count: stats?.payments?.collections.count,
      path: '/admin/payouts',
      variant: 'green' as const,
    },
    {
      title: 'Analytics Summary',
      description: 'Daily metric rollups from the backend',
      count: stats?.summary?.total_orders,
      path: '/admin/audit',
      variant: 'gray' as const,
    },
  ];

  const getColorClasses = (variant: string) => {
    switch (variant) {
      case 'blue':
        return 'bg-blue-50 border-blue-200';
      case 'purple':
        return 'bg-purple-50 border-purple-200';
      case 'red':
        return 'bg-red-50 border-red-200';
      case 'green':
        return 'bg-green-50 border-green-200';
      default:
        return 'bg-slate-50 border-slate-200';
    }
  };

  const getCountColor = (variant: string) => {
    switch (variant) {
      case 'blue':
        return 'text-blue-600';
      case 'purple':
        return 'text-purple-600';
      case 'red':
        return 'text-red-600';
      case 'green':
        return 'text-green-600';
      default:
        return 'text-slate-600';
    }
  };

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-bold text-slate-900">Analytics Dashboard</h1>
        <p className="mt-2 text-lg text-slate-600">
          Read-only analytics for the admin web app. Operational actions stay in the admin feature.
        </p>
      </div>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{error}</div>}

      {loading ? (
        <div className="text-center py-12">
          <p className="text-slate-600">Loading dashboard statistics...</p>
        </div>
      ) : (
        <>
          {/* Key metrics */}
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
            {navigationItems.map((item) => (
              <Card
                key={item.path}
                className={`border-2 p-4 text-center cursor-pointer transition hover:shadow-lg ${getColorClasses(item.variant)}`}
                onClick={() => navigate(item.path)}
              >
                {item.count !== undefined && (
                  <p className={`text-3xl font-bold ${getCountColor(item.variant)}`}>
                    {item.count}
                  </p>
                )}
                <p className="mt-1 font-semibold text-slate-900">{item.title}</p>
                <p className="text-xs text-slate-600">{item.description}</p>
              </Card>
            ))}
          </div>

          {/* Trend charts */}
          <div className="grid gap-6 lg:grid-cols-3">
            <LineChart
              title="Order volume trend"
              data={stats?.orderTrend || []}
              dataKey="value"
              labelKey="label"
              color="#0f766e"
            />
            <PieChart title="Farmer approvals" data={stats?.farmerApprovalBreakdown || []} />
            <PieChart title="Provider approvals" data={stats?.providerApprovalBreakdown || []} />
          </div>

          <div className="grid gap-6 lg:grid-cols-2">
            <BarChart
              title="Dispute status breakdown"
              data={stats?.disputeStatusBreakdown || []}
              dataKey="value"
              labelKey="name"
              color="#ca8a04"
            />
            <BarChart
              title="Payout status breakdown"
              data={stats?.payoutStatusBreakdown || []}
              dataKey="value"
              labelKey="name"
              color="#0f766e"
            />
          </div>

          <div className="grid gap-6 lg:grid-cols-2">
            <Card className="p-6">
              <h3 className="text-lg font-semibold text-slate-900">Summary</h3>
              <div className="mt-4 grid gap-4 sm:grid-cols-2">
                <div>
                  <p className="text-sm text-slate-600">Date range</p>
                  <p className="mt-1 font-medium text-slate-900">
                    {stats?.summary?.start_date || '—'} to {stats?.summary?.end_date || '—'}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-slate-600">Total sales</p>
                  <p className="mt-1 font-medium text-slate-900">KES {String(stats?.summary?.total_sales ?? 0)}</p>
                </div>
                <div>
                  <p className="text-sm text-slate-600">Collections</p>
                  <p className="mt-1 font-medium text-slate-900">{String(stats?.payments?.collections.total_amount ?? 0)}</p>
                </div>
                <div>
                  <p className="text-sm text-slate-600">Payouts</p>
                  <p className="mt-1 font-medium text-slate-900">{String(stats?.payments?.payouts.total_amount ?? 0)}</p>
                </div>
              </div>
            </Card>

            <Card className="p-6">
              <h3 className="text-lg font-semibold text-slate-900">Top Performers</h3>
              <div className="mt-4 space-y-3">
                {stats?.topFarmers.slice(0, 5).map((farmer) => (
                  <div key={farmer.id} className="flex items-center justify-between rounded-lg bg-slate-50 px-3 py-2">
                    <span className="text-sm text-slate-700">{farmer.user_phone}</span>
                    <span className="text-sm font-medium text-slate-900">KES {String(farmer.total_sales)}</span>
                  </div>
                ))}
              </div>
            </Card>
          </div>

          {/* Info section */}
          <Card className="border-l-4 border-blue-500 bg-blue-50 p-6">
            <h3 className="font-semibold text-blue-900">System Information</h3>
            <ul className="mt-3 space-y-2 text-sm text-blue-800">
              <li>• Dashboard data is sourced from the backend analytics module</li>
              <li>• Approval and suspension actions remain in the admin feature set</li>
              <li>• Daily metrics can be recomputed from backend analytics endpoints</li>
              <li>• The web app is admin-facing; field users should use the mobile app</li>
            </ul>
          </Card>
        </>
      )}
    </div>
  );
}
