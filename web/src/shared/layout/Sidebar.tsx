import { NavLink } from 'react-router-dom';
import { useAuth } from '../../core/hooks/useAuth';

const navItems = [
  { path: '/', label: 'Dashboard' },
  { path: '/orders', label: 'Orders' },
  { path: '/products', label: 'Products' },
  { path: '/transport', label: 'Transport Providers' },
  { path: '/disputes', label: 'Disputes' },
  { path: '/payouts', label: 'Payouts' },
  { path: '/profile', label: 'Profile' },
];

const adminItems = [
  { path: '/admin/farmer-approval', label: 'Farmer Approval' },
  { path: '/admin/audit-log', label: 'Audit Log' },
];

export default function Sidebar() {
  const { user } = useAuth();

  return (
    <aside className="w-72 shrink-0 border-r border-emerald-200 bg-gradient-to-b from-emerald-50 to-green-50 text-slate-900">
      <div className="px-6 py-5 border-b border-emerald-200">
        <p className="text-xs font-semibold uppercase tracking-[0.24em] text-emerald-600">Workspace</p>
        <h2 className="mt-3 text-xl font-semibold text-emerald-900">MAMBONAMI</h2>
        {user ? <p className="mt-2 text-sm text-emerald-700">{user.username || user.phone}</p> : null}
      </div>

      <nav className="px-3 py-4">
        <div className="space-y-1">
          {navItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              end={item.path === '/'}
              className={({ isActive }) =>
                `block rounded-xl px-4 py-3 text-sm font-medium transition ${
                  isActive ? 'bg-emerald-100 text-emerald-900 font-semibold' : 'text-slate-700 hover:bg-emerald-50 hover:text-emerald-900'
                }`
              }
            >
              {item.label}
            </NavLink>
          ))}
        </div>

        <div className="mt-6 border-t border-emerald-200 pt-4">
          <p className="px-4 text-xs uppercase tracking-[0.24em] text-emerald-600">Admin</p>
          <div className="mt-2 space-y-1">
            {adminItems.map((item) => (
              <NavLink
                key={item.path}
                to={item.path}
                className={({ isActive }) =>
                  `block rounded-xl px-4 py-3 text-sm font-medium transition ${
                    isActive ? 'bg-emerald-100 text-emerald-900 font-semibold' : 'text-slate-700 hover:bg-emerald-50 hover:text-emerald-900'
                  }`
                }
              >
                {item.label}
              </NavLink>
            ))}
          </div>
        </div>
      </nav>
    </aside>
  );
}
