import { RouteObject } from 'react-router-dom';
import MainLayout from '../shared/layout/MainLayout';
import Dashboard from '../features/analytics/pages/Dashboard';
import OrderList from '../features/orders/pages/OrderList';
import CreateOrder from '../features/orders/pages/CreateOrder';
import OrderDetail from '../features/orders/pages/OrderDetail';
import ProductList from '../features/products/pages/ProductList';
import ProductCreate from '../features/products/pages/ProductCreate';
import ProductDetail from '../features/products/pages/ProductDetail';
import ProductEdit from '../features/products/pages/ProductEdit';
import ProviderList from '../features/transport/pages/ProviderList';
import DisputeList from '../features/disputes/pages/DisputeList';
import PayoutList from '../features/payouts/pages/PayoutList';
import Profile from '../features/auth/pages/Profile';

// Admin pages
import AdminDashboard from '../features/admin/pages/Dashboard';
import FarmerApproval from '../features/admin/pages/FarmerApproval';
import TransportProviderApproval from '../features/admin/pages/TransportProviderApproval';
import DisputeResolution from '../features/admin/pages/DisputeResolution';
import AuditLog from '../features/admin/pages/AuditLog';
import PayoutsManager from '../features/admin/pages/PayoutsManager';
import UserManagement from '../features/admin/pages/UserManagement';
import AdminOrderOverview from '../features/admin/pages/AdminOrderOverview';
import Settings from '../features/admin/pages/Settings';

export const guardedRoutes: RouteObject[] = [
  {
    path: '/',
    element: <MainLayout />,
    children: [
      { index: true, element: <Dashboard /> },
      { path: 'orders', element: <OrderList /> },
      { path: 'orders/create', element: <CreateOrder /> },
      { path: 'orders/:uuid', element: <OrderDetail /> },
      { path: 'products', element: <ProductList /> },
      { path: 'products/create', element: <ProductCreate /> },
      { path: 'products/:uuid', element: <ProductDetail /> },
      { path: 'products/:uuid/edit', element: <ProductEdit /> },
      { path: 'transport', element: <ProviderList /> },
      { path: 'disputes', element: <DisputeList /> },
      { path: 'payouts', element: <PayoutList /> },
      { path: 'profile', element: <Profile /> },

      // Admin routes
      { path: 'admin', element: <AdminDashboard /> },
      { path: 'admin/dashboard', element: <AdminDashboard /> },
      { path: 'admin/farmers', element: <FarmerApproval /> },
      { path: 'admin/farmer-approval', element: <FarmerApproval /> },
      { path: 'admin/transport-providers', element: <TransportProviderApproval /> },
      { path: 'admin/disputes', element: <DisputeResolution /> },
      { path: 'admin/payouts', element: <PayoutsManager /> },
      { path: 'admin/audit', element: <AuditLog /> },
      { path: 'admin/audit-log', element: <AuditLog /> },
      { path: 'admin/users', element: <UserManagement /> },
      { path: 'admin/orders', element: <AdminOrderOverview /> },
      { path: 'admin/settings', element: <Settings /> },
    ],
  },
];
