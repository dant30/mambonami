import { RouteObject } from 'react-router-dom';
import Login from '../features/auth/pages/Login';
import Register from '../features/auth/pages/Register';
import ForgotPassword from '../features/auth/pages/ForgotPassword';

export const publicRoutes: RouteObject[] = [
  { path: '/login', element: <Login /> },
  { path: '/register', element: <Register /> },
  { path: '/forgot-password', element: <ForgotPassword /> },
  { path: '*', element: <Login /> },
];
