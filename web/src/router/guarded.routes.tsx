import { RouteObject } from 'react-router-dom';
import MainLayout from '../shared/layout/MainLayout';
import Dashboard from '../features/analytics/pages/Dashboard';
import OrderList from '../features/orders/pages/OrderList';
import ProductList from '../features/products/pages/ProductList';
import ProviderList from '../features/transport/pages/ProviderList';
import DisputeList from '../features/disputes/pages/DisputeList';
import PayoutList from '../features/payouts/pages/PayoutList';
import FarmerApproval from '../features/admin/pages/FarmerApproval';
import AuditLog from '../features/admin/pages/AuditLog';
import Profile from '../features/auth/pages/Profile';

export const guardedRoutes: RouteObject[] = [
  {
    path: '/',
    element: <MainLayout />,
    children: [
      { index: true, element: <Dashboard /> },
      { path: 'orders', element: <OrderList /> },
      { path: 'products', element: <ProductList /> },
      { path: 'transport', element: <ProviderList /> },
      { path: 'disputes', element: <DisputeList /> },
      { path: 'payouts', element: <PayoutList /> },
      { path: 'profile', element: <Profile /> },
      { path: 'admin/farmer-approval', element: <FarmerApproval /> },
      { path: 'admin/audit-log', element: <AuditLog /> },
    ],
  },
];
