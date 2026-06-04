import { NavLink } from 'react-router-dom';

const navItems = [
  {
    path: '/',
    label: 'Dashboard',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
        <path d="M4 4h7v7H4z" />
        <path d="M13 4h7v7h-7z" />
        <path d="M4 13h7v7H4z" />
        <path d="M13 13h7v7h-7z" />
      </svg>
    ),
  },
  {
    path: '/orders',
    label: 'Orders',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
        <path d="M9 6h11" />
        <path d="M9 12h11" />
        <path d="M9 18h11" />
        <path d="M5 6h.01" />
        <path d="M5 12h.01" />
        <path d="M5 18h.01" />
      </svg>
    ),
  },
  {
    path: '/products',
    label: 'Products',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
        <path d="M4 7.5l8-4 8 4v9l-8 4-8-4v-9z" />
        <path d="M12 3.5v13" />
        <path d="M4 7.5l8 4 8-4" />
      </svg>
    ),
  },
  {
    path: '/transport',
    label: 'Transport Providers',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
        <path d="M3 12h13" />
        <path d="M16 12l-2-4H3v8h11" />
        <path d="M16 12h5v4h-3" />
        <circle cx="7.5" cy="17.5" r="2.5" />
        <circle cx="18.5" cy="17.5" r="2.5" />
      </svg>
    ),
  },
  {
    path: '/disputes',
    label: 'Disputes',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
        <path d="M12 3l7 4.5v5.5c0 4.5-3.4 8.5-7 9-3.6-.5-7-4.5-7-9V7.5L12 3z" />
        <path d="M12 9v4" />
        <path d="M12 17h.01" />
      </svg>
    ),
  },
  {
    path: '/payouts',
    label: 'Payouts',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
        <path d="M4 7h16v10H4z" />
        <path d="M8 11h8" />
        <path d="M12 7v2" />
        <path d="M12 15v2" />
      </svg>
    ),
  },
  {
    path: '/profile',
    label: 'Profile',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
        <path d="M12 12a4 4 0 1 0-4-4 4 4 0 0 0 4 4z" />
        <path d="M6 20a6 6 0 0 1 12 0" />
      </svg>
    ),
  },
];

const adminItems = [
  {
    path: '/admin/farmer-approval',
    label: 'Farmer Approval',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
        <path d="M12 3l7 4.5v5.5c0 4.5-3.4 8.5-7 9-3.6-.5-7-4.5-7-9V7.5L12 3z" />
        <path d="M9 12l2 2 4-4" />
      </svg>
    ),
  },
  {
    path: '/admin/audit-log',
    label: 'Audit Log',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
        <circle cx="12" cy="12" r="8" />
        <path d="M12 8v4l3 2" />
      </svg>
    ),
  },
];

export default function Sidebar() {
  return (
    <aside className="sticky top-0 h-screen w-72 shrink-0 overflow-y-auto border-r border-emerald-200 bg-gradient-to-b from-emerald-50 to-green-50 text-slate-900 transition-colors duration-200 dark:border-slate-700 dark:from-slate-950 dark:to-slate-900 dark:text-slate-100">
      <div className="sticky top-0 z-10 border-b border-emerald-200 bg-gradient-to-b from-emerald-50 to-green-50 px-6 py-5 dark:border-slate-700 dark:from-slate-950 dark:to-slate-900">
        <h2 className="text-2xl font-semibold text-emerald-900 dark:text-emerald-300">MAMBONAMI</h2>
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
                  isActive
                    ? 'bg-emerald-100 text-emerald-900 font-semibold dark:bg-slate-800 dark:text-emerald-100'
                    : 'text-slate-700 hover:bg-emerald-50 hover:text-emerald-900 dark:text-slate-300 dark:hover:bg-slate-800 dark:hover:text-slate-100'
                }`
              }
            >
              <div className="flex items-center gap-3">
                <span className="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-100 text-emerald-700 dark:bg-slate-800 dark:text-emerald-200">
                  {item.icon}
                </span>
                <span>{item.label}</span>
              </div>
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
                    isActive
                      ? 'bg-emerald-100 text-emerald-900 font-semibold dark:bg-slate-800 dark:text-emerald-100'
                      : 'text-slate-700 hover:bg-emerald-50 hover:text-emerald-900 dark:text-slate-300 dark:hover:bg-slate-800 dark:hover:text-slate-100'
                  }`
                }
              >
                <div className="flex items-center gap-3">
                  <span className="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-100 text-emerald-700 dark:bg-slate-800 dark:text-emerald-200">
                    {item.icon}
                  </span>
                  <span>{item.label}</span>
                </div>
              </NavLink>
            ))}
          </div>
        </div>
      </nav>
    </aside>
  );
}
