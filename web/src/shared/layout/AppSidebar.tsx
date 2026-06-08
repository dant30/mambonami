// web/src/shared/layout/AppSidebar.tsx
import { Link, useLocation } from 'react-router-dom';
import {
  LayoutDashboard,
  ShoppingCart,
  Package,
  Truck,
  AlertTriangle,
  Wallet,
  User as UserIcon,
  LogOut,
  ShieldCheck,
  FileText,
  Users,
  Settings,
} from 'lucide-react';

import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarHeader,
  SidebarFooter,
  useSidebar,
} from '@/shared/components/ui/Sidebar';
import { useAuth } from '@/core/context/AuthContext';
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
  { title: 'Disputes', url: '/disputes', icon: AlertTriangle, roles: ['admin'] },
  { title: 'Payouts', url: '/payouts', icon: Wallet, roles: ['admin'] },
];

const adminNavItems: NavItem[] = [
  { title: 'Farmer Approval', url: '/admin/farmer-approval', icon: Users, roles: ['admin'] },
  { title: 'Audit Log', url: '/admin/audit-log', icon: FileText, roles: ['admin'] },
  { title: 'User Management', url: '/admin/users', icon: ShieldCheck, roles: ['admin'] },
  { title: 'Settings', url: '/admin/settings', icon: Settings, roles: ['admin'] },
];

export function AppSidebar() {
  const { pathname } = useLocation();
  const { user, logout, hasRole } = useAuth();
  const { state } = useSidebar(); // 'expanded' or 'collapsed'
  const isCollapsed = state === 'collapsed';

  // Helper: check if a link is active (exact match or starts with for nested routes)
  const isLinkActive = (url: string) => {
    if (url === '/') return pathname === '/';
    return pathname.startsWith(url);
  };

  if (!hasRole('admin')) {
    return (
      <Sidebar collapsible="icon">
        <SidebarHeader className="px-4 py-3">
          <div className="font-bold tracking-tight">Mambonami</div>
        </SidebarHeader>
        <SidebarContent>
          <div className="p-4 text-center text-sm text-muted-foreground">
            Web dashboard is only for administrators.<br />
            Please use the mobile app.
          </div>
        </SidebarContent>
      </Sidebar>
    );
  }

  const renderNavItems = (items: NavItem[]) =>
    items
      .filter((item) => !item.roles || item.roles.some(hasRole))
      .map((item) => {
        const Icon = item.icon;
        const active = isLinkActive(item.url);
        return (
          <SidebarMenuItem key={item.url}>
            <SidebarMenuButton asChild isActive={active} tooltip={isCollapsed ? item.title : undefined}>
              <Link to={item.url}>
                <Icon className="h-4 w-4" />
                <span>{item.title}</span>
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
        );
      });

  return (
    <Sidebar collapsible="icon">
      <SidebarHeader className="px-4 py-3">
        <div className="font-bold tracking-tight">Mambonami</div>
      </SidebarHeader>

      <SidebarContent>
        {/* Main section */}
        <SidebarGroup>
          <SidebarGroupLabel>Workspace</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>{renderNavItems(mainNavItems)}</SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        {/* Admin section */}
        <SidebarGroup>
          <SidebarGroupLabel>Administration</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>{renderNavItems(adminNavItems)}</SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>

      <SidebarFooter className="border-t p-2">
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton asChild tooltip={isCollapsed ? 'Profile' : undefined}>
              <Link to="/profile">
                <UserIcon className="h-4 w-4" />
                <span className="truncate">{user?.first_name ?? user?.username ?? 'Profile'}</span>
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
          <SidebarMenuItem>
            <AlertDialog>
              <AlertDialogTrigger asChild>
                <SidebarMenuButton asChild>
                  <button className="w-full">
                    <LogOut className="h-4 w-4" />
                    <span>Sign out</span>
                  </button>
                </SidebarMenuButton>
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
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarFooter>
    </Sidebar>
  );
}