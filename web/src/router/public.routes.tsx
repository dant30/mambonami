// src/router/public.routes.tsx
import { RouteObject } from 'react-router-dom';
import Login from '../features/auth/pages/Login';
import ForgotPassword from '../features/auth/pages/ForgotPassword';

export const publicRoutes: RouteObject[] = [
  { path: '/login', element: <Login /> },
  { path: '/forgot-password', element: <ForgotPassword /> },
  { path: '*', element: <Login /> },
];
