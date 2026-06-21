// src/router/GuardedRoute.tsx
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../features/auth/hooks/useAuth';

export const GuardedRoute = () => {
  const { user, loading } = useAuth();
  if (loading) {
    return <div className="min-h-screen flex items-center justify-center">Checking authentication...</div>;
  }
  return user ? <Outlet /> : <Navigate to="/login" replace />;
};
