// web/src/shared/layout/Header.tsx
import { useState, useEffect, useRef } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { Menu, Plus, Bell, Sun, Moon, Search } from 'lucide-react';
import { useAuth } from '@/features/auth/hooks/useAuth';
import { useTheme } from '@/core/context/ThemeContext';
import { useSidebar } from '@/core/context';
import { Button } from '@/shared/components/ui';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/shared/components/ui';
import { cn } from '@/lib/utils';

// Simple breadcrumb helper
function getBreadcrumbs(pathname: string) {
  const segments = pathname.split('/').filter(Boolean);
  const crumbs = segments.map((segment, index) => {
    const url = '/' + segments.slice(0, index + 1).join('/');
    const label = segment
      .replace(/-/g, ' ')
      .replace(/(^\w|\s\w)/g, (m) => m.toUpperCase());
    return { label, url };
  });
  return crumbs;
}

export default function Header() {
  const navigate = useNavigate();
  const location = useLocation();
  const { user, logout } = useAuth();
  const { theme, toggleTheme } = useTheme();
  const { isMobile, toggleMobile, toggleCollapsed } = useSidebar();
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [showSearch, setShowSearch] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);
  const searchInputRef = useRef<HTMLInputElement>(null);

  const env = import.meta.env.VITE_ENVIRONMENT || 'development';
  const envBadgeColor = env === 'production' ? 'bg-green-600' : env === 'staging' ? 'bg-yellow-600' : 'bg-blue-600';

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const handleSidebarToggle = () => {
    if (isMobile) {
      toggleMobile();
    } else {
      toggleCollapsed();
    }
  };

  // Breadcrumbs
  const breadcrumbs = getBreadcrumbs(location.pathname);

  // Keyboard shortcuts and outside click handlers
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsDropdownOpen(false);
      }
    };
    const handleEsc = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setIsDropdownOpen(false);
        setShowSearch(false);
      }
      if (event.key === '/' && !showSearch) {
        event.preventDefault();
        setShowSearch(true);
        setTimeout(() => searchInputRef.current?.focus(), 100);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    document.addEventListener('keydown', handleEsc);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      document.removeEventListener('keydown', handleEsc);
    };
  }, [showSearch]);

  const userInitials = user?.first_name
    ? user.first_name.split(' ').map((n) => n[0]).join('').toUpperCase()
    : user?.username?.slice(0, 2).toUpperCase() || '?';

  const quickActions = [
    { label: 'Approve Farmer', path: '/admin/farmer-approval' },
    { label: 'Create Admin', path: '/admin/users' },
    { label: 'Send Notification', path: '/notifications' },
    { label: 'Generate Report', path: '/analytics/sales' },
  ];

  return (
    <header className="sticky top-0 z-50 border-b border-sidebar-border bg-emerald-50/95 px-4 py-2 shadow-sm backdrop-blur-sm transition-colors duration-200 sm:px-6 dark:border-slate-700 dark:bg-slate-950/95 dark:shadow-slate-950/40">
      <div className="flex items-center justify-between gap-2">
        {/* Left: Hamburger + Breadcrumbs */}
        <div className="flex items-center gap-2 min-w-0">
          <Button
            variant="ghost"
            size="icon"
            onClick={handleSidebarToggle}
            className="h-9 w-9 rounded-full hover:bg-emerald-200 dark:hover:bg-slate-700 shrink-0"
            aria-label="Toggle sidebar"
          >
            <Menu className="h-5 w-5" />
          </Button>

          {/* Breadcrumbs */}
          <nav className="hidden md:flex items-center gap-1 text-sm text-muted-foreground truncate">
            {breadcrumbs.map((crumb, index) => (
              <span key={crumb.url} className="flex items-center gap-1">
                {index > 0 && <span className="text-muted-foreground/40">/</span>}
                {index === breadcrumbs.length - 1 ? (
                  <span className="font-medium text-foreground truncate">{crumb.label}</span>
                ) : (
                  <Link to={crumb.url} className="hover:text-foreground transition-colors">
                    {crumb.label}
                  </Link>
                )}
              </span>
            ))}
          </nav>

          {/* Mobile: show current page name */}
          <span className="md:hidden text-sm font-medium truncate">
            {breadcrumbs.length > 0 ? breadcrumbs[breadcrumbs.length - 1].label : 'Dashboard'}
          </span>
        </div>

        {/* Center: Global Search (desktop) */}
        <div className="hidden md:flex flex-1 max-w-xl mx-4 relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <input
            ref={searchInputRef}
            type="text"
            placeholder="Search orders, farmers, transporters..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full rounded-lg border border-emerald-300 bg-emerald-50/80 px-9 py-2 text-sm text-slate-900 placeholder:text-muted-foreground transition focus:border-transparent focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:border-slate-700 dark:bg-slate-900/80 dark:text-slate-100"
            onKeyDown={(e) => {
              if (e.key === 'Enter' && searchQuery.trim()) {
                navigate(`/search?q=${encodeURIComponent(searchQuery)}`);
              }
            }}
          />
          <kbd className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground bg-slate-100 dark:bg-slate-800 px-1.5 py-0.5 rounded border border-slate-200 dark:border-slate-700">
            ⌘K
          </kbd>
        </div>

        {/* Right: Actions */}
        <div className="flex items-center gap-1">
          {/* Environment badge */}
          <div className={cn(
            "hidden sm:block text-xs font-medium text-white px-2 py-0.5 rounded-full",
            envBadgeColor
          )}>
            {env.toUpperCase()}
          </div>

          {/* Quick actions dropdown */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="h-9 w-9 rounded-full hover:bg-emerald-200 dark:hover:bg-slate-700"
                aria-label="Quick actions"
              >
                <Plus className="h-5 w-5" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-48">
              {quickActions.map((action) => (
                <DropdownMenuItem key={action.path} asChild>
                  <Link to={action.path} className="cursor-pointer">
                    {action.label}
                  </Link>
                </DropdownMenuItem>
              ))}
            </DropdownMenuContent>
          </DropdownMenu>

          {/* Notifications */}
          <Link
            to="/notifications"
            aria-label="Notifications"
            className="relative inline-flex h-9 w-9 items-center justify-center rounded-full bg-emerald-100 text-emerald-700 transition hover:bg-emerald-200 dark:bg-slate-800 dark:text-slate-100 dark:hover:bg-slate-700"
          >
            <Bell className="h-4 w-4" />
            <span className="absolute -top-0.5 -right-0.5 flex h-4 w-4 items-center justify-center rounded-full bg-red-500 text-[10px] font-bold text-white">
              8
            </span>
          </Link>

          {/* Theme toggle */}
          <button
            type="button"
            onClick={toggleTheme}
            className="inline-flex h-9 w-9 items-center justify-center rounded-full bg-emerald-100 text-emerald-700 transition hover:bg-emerald-200 dark:bg-slate-800 dark:text-slate-100 dark:hover:bg-slate-700"
            title={theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode'}
          >
            {theme === 'dark' ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
          </button>

          {/* User dropdown */}
          <div className="relative" ref={dropdownRef}>
            <button
              onClick={() => setIsDropdownOpen(!isDropdownOpen)}
              className="flex items-center justify-center h-9 w-9 rounded-full bg-emerald-100 text-emerald-700 font-semibold text-sm hover:bg-emerald-200 transition dark:bg-slate-800 dark:text-slate-100 dark:hover:bg-slate-700"
            >
              {userInitials}
            </button>

            {isDropdownOpen && (
              <div className="absolute right-0 mt-2 w-56 bg-white border border-emerald-200 rounded-lg shadow-lg py-2 z-50 dark:bg-slate-900 dark:border-slate-700">
                <div className="px-4 py-2 border-b border-emerald-200 dark:border-slate-700">
                  <p className="text-sm font-semibold text-slate-900 dark:text-slate-100">
                    {user?.first_name || user?.username || user?.phone}
                  </p>
                  <p className="text-xs text-slate-500 dark:text-slate-400">{user?.email || user?.phone}</p>
                  <p className="text-xs text-emerald-600 dark:text-emerald-400 font-medium mt-1">Admin</p>
                </div>
                <Link
                  to="/profile"
                  className="block px-4 py-2 text-sm text-slate-700 hover:bg-emerald-50 transition dark:text-slate-200 dark:hover:bg-slate-800"
                  onClick={() => setIsDropdownOpen(false)}
                >
                  Profile Settings
                </Link>
                <button
                  onClick={handleLogout}
                  className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition"
                >
                  Sign out
                </button>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Mobile search bar (toggled) */}
      {showSearch && (
        <div className="md:hidden mt-2 relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <input
            autoFocus
            type="text"
            placeholder="Search..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full rounded-lg border border-emerald-300 bg-emerald-50/80 px-9 py-2 text-sm text-slate-900 placeholder:text-muted-foreground transition focus:border-transparent focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:border-slate-700 dark:bg-slate-900/80 dark:text-slate-100"
            onKeyDown={(e) => {
              if (e.key === 'Enter' && searchQuery.trim()) {
                navigate(`/search?q=${encodeURIComponent(searchQuery)}`);
              }
            }}
          />
          <button
            onClick={() => setShowSearch(false)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground hover:text-foreground"
          >
            ✕
          </button>
        </div>
      )}
    </header>
  );
}