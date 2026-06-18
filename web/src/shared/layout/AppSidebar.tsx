// web/src/shared/layout/AppSidebar.tsx
import { Link, useLocation } from 'react-router-dom';
import {
  LayoutDashboard,
  ShoppingCart,
  Package,
  Truck,
  Bell,
  AlertTriangle,
  Wallet,
  User as UserIcon,
  LogOut,
  ShieldCheck,
  FileText,
  Users,
  Settings,
  BarChart3,
  ChevronLeft,
  ChevronRight,
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

interface NavItem {
  title: string;
  url: string;
  icon: React.ComponentType<{ className?: string }>;
  roles?: Role[];
}

const mainNavItems: NavItem[] = [
  { title: 'Dashboard', url: '/', icon: LayoutDashboard, roles: ['admin'] },
  { title: 'Orders', url: '/orders', icon: ShoppingCart, roles: ['admin'] },
  { title: 'Products', url: '/products', icon: Package, roles: ['admin'] },
  { title: 'Transport Providers', url: '/transport', icon: Truck, roles: ['admin'] },
  { title: 'Farmer Approval', url: '/farmers/approval', icon: Users, roles: ['admin'] },
  { title: 'Notifications', url: '/notifications', icon: Bell, roles: ['admin'] },
  { title: 'Disputes', url: '/disputes', icon: AlertTriangle, roles: ['admin'] },
  { title: 'Payouts', url: '/payouts', icon: Wallet, roles: ['admin'] },
];

const adminNavItems: NavItem[] = [
  { title: 'Order Overview', url: '/admin/orders', icon: BarChart3, roles: ['admin'] },
  { title: 'Audit Log', url: '/admin/audit-log', icon: FileText, roles: ['admin'] },
  { title: 'User Management', url: '/admin/users', icon: ShieldCheck, roles: ['admin'] },
  { title: 'Settings', url: '/admin/settings', icon: Settings, roles: ['admin'] },
];

export function AppSidebar() {
  const { pathname } = useLocation();
  const { user, logout, hasRole } = useAuth();
  const { isMobileOpen, setMobileOpen, isCollapsed, toggleCollapsed, isMobile } = useSidebar();

  const isLinkActive = (url: string) => {
    if (url === '/') return pathname === '/';
    return pathname.startsWith(url);
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
        return (
          <Link
            key={item.url}
            to={item.url}
            onClick={() => isMobile && setMobileOpen(false)}
            className={cn(
              "flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors",
              active
                ? "bg-emerald-100 font-medium text-emerald-900 dark:bg-slate-800 dark:text-emerald-100"
                : "text-slate-700 hover:bg-emerald-50 dark:text-slate-300 dark:hover:bg-slate-800",
              !isMobile && isCollapsed && "justify-center px-2"
            )}
            title={(!isMobile && isCollapsed) ? item.title : undefined}
          >
            <Icon className="h-4 w-4 shrink-0" />
            {(!isMobile || !isCollapsed) && <span>{item.title}</span>}
          </Link>
        );
      });

  // ----- DESKTOP SIDEBAR -----
  const DesktopSidebar = () => (
    <div
      className={cn(
        "fixed top-0 left-0 z-40 hidden h-screen flex-col border-r bg-emerald-50/95 transition-all duration-300 dark:bg-slate-950/95 md:flex",
        isCollapsed ? "w-16" : "w-64"
      )}
    >
      {/* Header */}
      <div className={cn(
        "flex items-center justify-between px-3 py-3",
        isCollapsed && "justify-center"
      )}>
        {!isCollapsed && <div className="font-bold tracking-tight">Mambonami</div>}
        <Button
          variant="ghost"
          size="icon"
          onClick={toggleCollapsed}
          className="h-8 w-8"
        >
          {isCollapsed ? <ChevronRight className="h-4 w-4" /> : <ChevronLeft className="h-4 w-4" />}
        </Button>
      </div>

      {/* Navigation */}
      <div className="flex-1 overflow-y-auto px-3 py-4 space-y-6">
        <div>
          {!isCollapsed && <div className="mb-2 px-3 text-xs font-medium text-muted-foreground">Workspace</div>}
          <div className="space-y-1">{renderNavItems(mainNavItems)}</div>
        </div>
        <div>
          {!isCollapsed && <div className="mb-2 px-3 text-xs font-medium text-muted-foreground">Administration</div>}
          <div className="space-y-1">{renderNavItems(adminNavItems)}</div>
        </div>
      </div>

      {/* Footer */}
      <div className="border-t p-2">
        <div className="space-y-1">
          <Link
            to="/profile"
            className={cn(
              "flex items-center gap-3 rounded-md px-3 py-2 text-sm hover:bg-emerald-50 dark:hover:bg-slate-800",
              isCollapsed && "justify-center px-2"
            )}
            title={isCollapsed ? 'Profile' : undefined}
          >
            <UserIcon className="h-4 w-4 shrink-0" />
            {!isCollapsed && <span className="truncate">{user?.first_name ?? user?.username ?? 'Profile'}</span>}
          </Link>
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
      <SheetContent side="left" className="w-64 p-0">
        <SheetHeader className="px-4 py-3 border-b">
          <SheetTitle className="font-bold tracking-tight">Mambonami</SheetTitle>
          <SheetDescription className="sr-only">Navigation menu</SheetDescription>
        </SheetHeader>
        <div className="flex h-full flex-col bg-emerald-50/95 dark:bg-slate-950/95">
          <div className="flex-1 overflow-y-auto px-3 py-4 space-y-6">
            <div>
              <div className="mb-2 px-3 text-xs font-medium text-muted-foreground">Workspace</div>
              <div className="space-y-1">{renderNavItems(mainNavItems)}</div>
            </div>
            <div>
              <div className="mb-2 px-3 text-xs font-medium text-muted-foreground">Administration</div>
              <div className="space-y-1">{renderNavItems(adminNavItems)}</div>
            </div>
          </div>
          <div className="border-t p-2">
            <div className="space-y-1">
              <Link
                to="/profile"
                className="flex items-center gap-3 rounded-md px-3 py-2 text-sm hover:bg-emerald-50 dark:hover:bg-slate-800"
                onClick={() => setMobileOpen(false)}
              >
                <UserIcon className="h-4 w-4" />
                <span className="truncate">{user?.first_name ?? user?.username ?? 'Profile'}</span>
              </Link>
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