
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Card from '../../../shared/components/cards/Card';
import BarChart from '../../../shared/components/charts/BarChart';
import LineChart from '../../../shared/components/charts/LineChart';
import PieChart from '../../../shared/components/charts/PieChart';
import { getAdminStats } from '../../admin/services/adminService';
import type { AdminStats } from '../../admin/types';

export default function Dashboard() {
  const navigate = useNavigate();
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadStats = async () => {
      setLoading(true);
      setError(null);
      try {
        const data = await getAdminStats();
        setStats(data as AdminStats);
      } catch (err) {
        setError('Failed to load dashboard stats');
        console.error('Error:', err);
      } finally {
        setLoading(false);
      }
    };

    loadStats();
  }, []);

  const navigationItems = [
    {
      title: 'Farmer Approvals',
      description: 'Review and approve pending farmers',
      count: stats?.pending_farmer_approvals,
      path: '/admin/farmers',
      variant: 'blue' as const,
    },
    {
      title: 'Transport Providers',
      description: 'Approve providers with deposits',
      count: stats?.pending_transport_approvals,
      path: '/admin/transport-providers',
      variant: 'purple' as const,
    },
    {
      title: 'Disputes',
      description: 'Resolve open disputes',
      count: stats?.open_disputes,
      path: '/admin/disputes',
      variant: 'red' as const,
    },
    {
      title: 'Payouts',
      description: 'Manage farmer payouts',
      count: stats?.pending_payouts,
      path: '/admin/payouts',
      variant: 'green' as const,
    },
    {
      title: 'Audit Logs',
      description: 'View admin actions',
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
        <h1 className="text-4xl font-bold text-slate-900">Admin Dashboard</h1>
        <p className="mt-2 text-lg text-slate-600">
          Welcome to the Mambonami admin panel. Manage approvals, disputes, and platform operations.
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
              dataKey="orders"
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

          {/* Info section */}
          <Card className="border-l-4 border-blue-500 bg-blue-50 p-6">
            <h3 className="font-semibold text-blue-900">System Information</h3>
            <ul className="mt-3 space-y-2 text-sm text-blue-800">
              <li>• All actions are logged and auditable</li>
              <li>• Approvals require proper verification before proceeding</li>
              <li>• Dispute resolutions trigger automatic refunds or penalties</li>
              <li>• Check the Audit Log for a complete history of all actions</li>
            </ul>
          </Card>
        </>
      )}
    </div>
  );
}
