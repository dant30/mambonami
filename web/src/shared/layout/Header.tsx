import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../core/hooks/useAuth';
import { useTheme } from '../../core/context/ThemeContext';

export default function Header() {
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const { theme, toggleTheme } = useTheme();
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const userInitials = user?.username
    ? user.username.split(' ').map((n) => n[0]).join('').toUpperCase()
    : user?.phone?.slice(-2).toUpperCase() || '?';

  return (
    <header className="sticky top-0 z-50 border-b border-emerald-200 bg-emerald-50/95 px-6 py-4 shadow-sm shadow-emerald-200/30 backdrop-blur-sm transition-colors duration-200 dark:border-slate-700 dark:bg-slate-950/95 dark:shadow-slate-950/40">
      <div className="flex items-center justify-between gap-6">
        <div className="flex-1">
          <input
            type="text"
            placeholder="Search orders, products, transports..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full max-w-2xl px-4 py-3 rounded-lg border border-emerald-300 bg-emerald-50 text-sm text-slate-900 placeholder:text-emerald-600 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100 dark:placeholder:text-slate-500"
          />
        </div>

        <div className="flex items-center gap-3">
          <button
            type="button"
            className="inline-flex h-10 w-10 items-center justify-center rounded-full bg-emerald-100 text-emerald-700 transition hover:bg-emerald-200 dark:bg-slate-800 dark:text-slate-100 dark:hover:bg-slate-700"
            title="Notifications"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
              <path d="M18 8a6 6 0 1 0-12 0c0 7-3 8-3 8h18s-3-1-3-8" />
              <path d="M13.73 21a2 2 0 0 1-3.46 0" />
            </svg>
          </button>

          <button
            type="button"
            onClick={toggleTheme}
            className="inline-flex h-10 w-10 items-center justify-center rounded-full bg-emerald-100 text-emerald-700 transition hover:bg-emerald-200 dark:bg-slate-800 dark:text-slate-100 dark:hover:bg-slate-700"
            title={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
          >
            {theme === 'light' ? (
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
                <circle cx="12" cy="12" r="5" />
                <path d="M12 1v2" />
                <path d="M12 21v2" />
                <path d="M4.22 4.22l1.42 1.42" />
                <path d="M18.36 18.36l1.42 1.42" />
                <path d="M1 12h2" />
                <path d="M21 12h2" />
                <path d="M4.22 19.78l1.42-1.42" />
                <path d="M18.36 5.64l1.42-1.42" />
              </svg>
            ) : (
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
                <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
              </svg>
            )}
          </button>

          <div className="relative">
            <button
              onClick={() => setIsDropdownOpen(!isDropdownOpen)}
              className="flex items-center justify-center w-10 h-10 rounded-full bg-emerald-100 text-emerald-700 font-semibold text-sm hover:bg-emerald-200 transition dark:bg-slate-800 dark:text-slate-100 dark:hover:bg-slate-700"
              title={user?.username || user?.phone}
            >
              {userInitials}
            </button>

            {isDropdownOpen && (
              <div className="absolute right-0 mt-2 w-48 bg-white border border-emerald-200 rounded-lg shadow-lg py-2 z-50 dark:bg-slate-900 dark:border-slate-700">
                <div className="px-4 py-2 border-b border-emerald-200 dark:border-slate-700">
                  <p className="text-sm font-semibold text-slate-900 dark:text-slate-100">{user?.username || user?.phone}</p>
                  <p className="text-xs text-slate-500 dark:text-slate-400">{user?.phone}</p>
                </div>
                <Link
                  to="/profile"
                  className="block px-4 py-2 text-sm text-slate-700 hover:bg-emerald-50 transition dark:text-slate-200 dark:hover:bg-slate-800"
                  onClick={() => setIsDropdownOpen(false)}
                >
                  Profile
                </Link>
                <button
                  onClick={handleLogout}
                  className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition"
                >
                  Logout
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}
