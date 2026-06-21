// src/router/guarded.routes.tsx
import { RouteObject } from 'react-router-dom';
import { AdminRoute } from './AdminRoute';
import MainLayout from '../shared/layout/MainLayout';

// Admin pages
import Dashboard from '../features/analytics/pages/Dashboard';
import AdminOrderOverview from '../features/admin/pages/AdminOrderOverview';
import FarmerApproval from '../features/farmers/pages/FarmerApproval';
import TransportProviderApproval from '../features/admin/pages/TransportProviderApproval';
import DisputeResolution from '../features/disputes/pages/DisputeResolution';
import PayoutsManager from '../features/admin/pages/PayoutsManager';
import AuditLog from '../features/admin/pages/AuditLog';
import UserManagement from '../features/admin/pages/UserManagement';
import Settings from '../features/admin/pages/Settings';
import NotificationsInbox from '../features/notifications/pages/NotificationsInbox';
import Profile from '../features/auth/pages/Profile';

// Keep these for admin read-only views
import OrderList from '../features/orders/pages/OrderList';
import OrderDetail from '../features/orders/pages/OrderDetail';
import ProductList from '../features/products/pages/ProductList';
import ProductDetail from '../features/products/pages/ProductDetail';
import ProviderList from '../features/transport/pages/ProviderList';
import DisputeList from '../features/disputes/pages/DisputeList';
import DisputeDetail from '../features/disputes/pages/DisputeDetail';
import PayoutList from '../features/payouts/pages/PayoutList';
import PayoutDetail from '../features/payouts/pages/PayoutDetail';

export const guardedRoutes: RouteObject[] = [
  {
    path: '/',
    element: <AdminRoute />, // 👈 Ensures only admins can access
    children: [
      {
        element: <MainLayout />,
        children: [
          { index: true, element: <Dashboard /> },

          // Core admin features
          { path: 'admin', element: <Dashboard /> },
          { path: 'admin/dashboard', element: <Dashboard /> },
          { path: 'admin/orders', element: <AdminOrderOverview /> },
          { path: 'admin/farmers', element: <FarmerApproval /> },
          { path: 'admin/farmer-approval', element: <FarmerApproval /> },
          { path: 'admin/transport-providers', element: <TransportProviderApproval /> },
          { path: 'admin/disputes', element: <DisputeResolution /> },
          { path: 'admin/payouts', element: <PayoutsManager /> },
          { path: 'admin/audit', element: <AuditLog /> },
          { path: 'admin/audit-log', element: <AuditLog /> },
          { path: 'admin/users', element: <UserManagement /> },
          { path: 'admin/settings', element: <Settings /> },

          // Read‑only views (admins can browse)
          { path: 'orders', element: <OrderList /> },
          { path: 'orders/:uuid', element: <OrderDetail /> },
          { path: 'products', element: <ProductList /> },
          { path: 'products/:uuid', element: <ProductDetail /> },
          { path: 'transport/providers', element: <ProviderList /> },
          { path: 'disputes', element: <DisputeList /> },
          { path: 'disputes/:uuid', element: <DisputeDetail /> },
          { path: 'payouts', element: <PayoutList /> },
          { path: 'payouts/:uuid', element: <PayoutDetail /> },

          // User profile & notifications (admin can access)
          { path: 'profile', element: <Profile /> },
          { path: 'notifications', element: <NotificationsInbox /> },
        ],
      },
    ],
  },
];