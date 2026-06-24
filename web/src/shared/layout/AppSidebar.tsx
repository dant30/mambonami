// web/src/shared/layout/AppSidebar.tsx
import { Link, useLocation } from 'react-router-dom';
import {
  LayoutDashboard,
  ShoppingBag,
  Truck,
  Users,
  Package,
  DollarSign,
  Wallet,
  Shield,
  AlertTriangle,
  BarChart3,
  Settings,
  UserCog,
  Bell,
  LogOut,
  ChevronLeft,
  ChevronRight,
  FileText,
  TrendingUp,
  Activity,
  CreditCard,
  FileCheck,
  Zap,
} from 'lucide-react';
import { useAuth } from '@/core/context/AuthContext';
import { useSidebar } from '@/core/context/SidebarContext';
import type { Role } from '@/lib/types';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/shared/components/ui/AlertDialog';
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
} from '@/shared/components/ui/Sheet';
import { Button } from '@/shared/components/ui';
import { cn } from '@/lib/utils';
import { useTheme } from '@/core/context/ThemeContext';

interface NavItem {
  title: string;
  url: string;
  icon: React.ComponentType<{ className?: string }>;
  roles?: Role[];
  badge?: string | number;
  badgeColor?: 'default' | 'red' | 'green' | 'yellow';
}

interface NavGroup {
  label: string;
  items: NavItem[];
}

const navGroups: NavGroup[] = [
  {
    label: 'Operations',
    items: [
      { title: 'Dashboard', url: '/', icon: LayoutDashboard, roles: ['admin'] },
      {
        title: 'Orders',
        url: '/orders',
        icon: ShoppingBag,
        roles: ['admin'],
        badge: '24',
        badgeColor: 'red',
      },
      { title: 'Logistics', url: '/logistics', icon: Truck, roles: ['admin'] },
      { title: 'Farmer Management', url: '/farmers', icon: Users, roles: ['admin'] },
      { title: 'Product Catalog', url: '/products', icon: Package, roles: ['admin'] },
    ],
  },
  {
    label: 'Finance',
    items: [
      { title: 'Transactions', url: '/transactions', icon: DollarSign, roles: ['admin'] },
      { title: 'Escrow Wallet', url: '/escrow', icon: Wallet, roles: ['admin'] },
      { title: 'Payouts', url: '/payouts', icon: CreditCard, roles: ['admin'] },
      { title: 'Revenue Reports', url: '/revenue', icon: TrendingUp, roles: ['admin'] },
    ],
  },
  {
    label: 'Risk & Compliance',
    items: [
      {
        title: 'Disputes',
        url: '/disputes',
        icon: AlertTriangle,
        roles: ['admin'],
        badge: '7',
        badgeColor: 'red',
      },
      { title: 'Verification Queue', url: '/verification', icon: FileCheck, roles: ['admin'] },
      { title: 'Audit Logs', url: '/audit', icon: FileText, roles: ['admin'] },
      { title: 'Fraud Detection', url: '/fraud', icon: Shield, roles: ['admin'] },
    ],
  },
  {
    label: 'Analytics',
    items: [
      { title: 'Sales Reports', url: '/analytics/sales', icon: BarChart3, roles: ['admin'] },
      { title: 'Performance', url: '/analytics/performance', icon: Activity, roles: ['admin'] },
      { title: 'Trends', url: '/analytics/trends', icon: Zap, roles: ['admin'] },
    ],
  },
  {
    label: 'System',
    items: [
      { title: 'Staff Management', url: '/admin/users', icon: UserCog, roles: ['admin'] },
      { title: 'Notifications', url: '/notifications', icon: Bell, roles: ['admin'] },
      { title: 'Settings', url: '/admin/settings', icon: Settings, roles: ['admin'] },
    ],
  },
];

export function AppSidebar() {
  const { pathname } = useLocation();
  const { user, logout, hasRole } = useAuth();
  const { isMobileOpen, setMobileOpen, isCollapsed, toggleCollapsed, isMobile } = useSidebar();
  const { theme } = useTheme();
  const isDark = theme === 'dark';

  const isLinkActive = (url: string) => {
    if (url === '/') return pathname === '/';
    return pathname.startsWith(url);
  };

  const badgeStyles = {
    default: 'bg-slate-200 text-slate-700 dark:bg-slate-700 dark:text-slate-300',
    red: 'bg-red-500 text-white',
    green: 'bg-green-500 text-white',
    yellow: 'bg-yellow-500 text-white',
  };

  if (!hasRole('admin')) {
    return (
      <div className="fixed top-0 left-0 z-40 h-screen w-64 border-r bg-emerald-50/95 p-4 dark:bg-slate-950/95">
        <div className="font-bold tracking-tight">Mambonami</div>
        <div className="mt-8 text-sm text-muted-foreground">
          Web dashboard is only for administrators.<br />
          Please use the mobile app.
        </div>
      </div>
    );
  }

  const renderNavItems = (items: NavItem[]) =>
    items
      .filter((item) => !item.roles || item.roles.some(hasRole))
      .map((item) => {
        const Icon = item.icon;
        const active = isLinkActive(item.url);
        const badge = item.badge;
        const badgeColor = item.badgeColor || 'default';
        return (
          <Link
            key={item.url}
            to={item.url}
            onClick={() => isMobile && setMobileOpen(false)}
            className={cn(
              "flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors relative",
              active
                ? "bg-emerald-100 font-medium text-emerald-900 dark:bg-slate-800 dark:text-emerald-100"
                : "text-slate-700 hover:bg-emerald-50 dark:text-slate-300 dark:hover:bg-slate-800",
              !isMobile && isCollapsed && "justify-center px-2"
            )}
            title={(!isMobile && isCollapsed) ? item.title : undefined}
          >
            <Icon className="h-4 w-4 shrink-0" />
            {(!isMobile || !isCollapsed) && (
              <>
                <span className="flex-1">{item.title}</span>
                {badge && (
                  <span
                    className={cn(
                      "text-xs px-2 py-0.5 rounded-full font-medium",
                      badgeStyles[badgeColor]
                    )}
                  >
                    {badge}
                  </span>
                )}
              </>
            )}
          </Link>
        );
      });

  // Environment badge
  const env = import.meta.env.VITE_ENVIRONMENT || 'development';
  const envColors = {
    production: 'bg-green-600',
    staging: 'bg-yellow-600',
    development: 'bg-blue-600',
  };

  // ----- DESKTOP SIDEBAR -----
  const DesktopSidebar = () => (
    <div
      className={cn(
        "fixed top-0 left-0 z-40 hidden h-screen flex-col border-r bg-emerald-50/95 transition-all duration-300 dark:bg-slate-950/95 md:flex",
        isCollapsed ? "w-16" : "w-64"
      )}
    >
      {/* Header with logo */}
      <div
        className={cn(
          "flex items-center justify-between px-3 py-3 border-b border-sidebar-border",
          isCollapsed && "justify-center"
        )}
      >
        <div className="flex items-center gap-2 overflow-hidden">
          {!isCollapsed && (
            <>
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-700 text-white font-bold text-sm">
                M
              </div>
              <div className="font-bold tracking-tight">Mambonami</div>
            </>
          )}
        </div>
        {!isCollapsed && (
          <Button
            variant="ghost"
            size="icon"
            onClick={toggleCollapsed}
            className="h-8 w-8 shrink-0"
          >
            <ChevronLeft className="h-4 w-4" />
          </Button>
        )}
      </div>

      {/* Environment badge */}
      {!isCollapsed && (
        <div className="px-3 py-2">
          <div
            className={cn(
              "text-center text-xs font-medium text-white px-2 py-1 rounded-full",
              envColors[env as keyof typeof envColors] || envColors.development
            )}
          >
            {env.toUpperCase()}
          </div>
        </div>
      )}

      {/* Navigation */}
      <div className="flex-1 overflow-y-auto px-3 py-2 space-y-4">
        {navGroups.map((group) => (
          <div key={group.label}>
            {!isCollapsed && (
              <div className="mb-1 px-3 text-xs font-medium uppercase tracking-wider text-muted-foreground">
                {group.label}
              </div>
            )}
            <div className="space-y-0.5">{renderNavItems(group.items)}</div>
          </div>
        ))}
      </div>

      {/* Footer */}
      <div className="border-t p-2">
        <div className="space-y-0.5">
          <AlertDialog>
            <AlertDialogTrigger asChild>
              <button
                className={cn(
                  "flex w-full items-center gap-3 rounded-md px-3 py-2 text-sm text-red-600 hover:bg-red-50 dark:hover:bg-red-950",
                  isCollapsed && "justify-center px-2"
                )}
                title={isCollapsed ? 'Sign out' : undefined}
              >
                <LogOut className="h-4 w-4 shrink-0" />
                {!isCollapsed && <span>Sign out</span>}
              </button>
            </AlertDialogTrigger>
            <AlertDialogContent>
              <AlertDialogHeader>
                <AlertDialogTitle>Are you sure?</AlertDialogTitle>
                <AlertDialogDescription>
                  You will be logged out and will need to sign in again.
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel>Cancel</AlertDialogCancel>
                <AlertDialogAction onClick={logout}>Sign out</AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialog>
        </div>
      </div>
    </div>
  );

  // ----- MOBILE SIDEBAR (Sheet) -----
  const MobileSidebar = () => (
    <Sheet open={isMobileOpen} onOpenChange={setMobileOpen}>
      <SheetContent side="left" className="w-72 p-0">
        <SheetHeader className="px-4 py-3 border-b">
          <div className="flex items-center gap-2">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-700 text-white font-bold text-sm">
              M
            </div>
            <SheetTitle className="font-bold tracking-tight">Mambonami</SheetTitle>
          </div>
          <SheetDescription className="sr-only">Navigation menu</SheetDescription>
        </SheetHeader>
        <div className="flex h-full flex-col bg-emerald-50/95 dark:bg-slate-950/95">
          <div className="px-3 py-2">
            <div
              className={cn(
                "text-center text-xs font-medium text-white px-2 py-1 rounded-full",
                envColors[env as keyof typeof envColors] || envColors.development
              )}
            >
              {env.toUpperCase()}
            </div>
          </div>
          <div className="flex-1 overflow-y-auto px-3 py-2 space-y-4">
            {navGroups.map((group) => (
              <div key={group.label}>
                <div className="mb-1 px-3 text-xs font-medium uppercase tracking-wider text-muted-foreground">
                  {group.label}
                </div>
                <div className="space-y-0.5">{renderNavItems(group.items)}</div>
              </div>
            ))}
          </div>
          <div className="border-t p-2">
            <AlertDialog>
              <AlertDialogTrigger asChild>
                <button className="flex w-full items-center gap-3 rounded-md px-3 py-2 text-sm text-red-600 hover:bg-red-50 dark:hover:bg-red-950">
                  <LogOut className="h-4 w-4" />
                  <span>Sign out</span>
                </button>
              </AlertDialogTrigger>
              <AlertDialogContent>
                <AlertDialogHeader>
                  <AlertDialogTitle>Are you sure?</AlertDialogTitle>
                  <AlertDialogDescription>
                    You will be logged out and will need to sign in again.
                  </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                  <AlertDialogCancel>Cancel</AlertDialogCancel>
                  <AlertDialogAction onClick={logout}>Sign out</AlertDialogAction>
                </AlertDialogFooter>
              </AlertDialogContent>
            </AlertDialog>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  );

  return (
    <>
      <DesktopSidebar />
      <MobileSidebar />
    </>
  );
}