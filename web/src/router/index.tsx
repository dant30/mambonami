// src/router/index.tsx
import { useRoutes } from 'react-router-dom';
import { publicRoutes } from './public.routes';
import { guardedRoutes } from './guarded.routes';
import { useAuth } from '../features/auth/hooks/useAuth';

export default function AppRouter() {
  const { loading, user } = useAuth();
  const routes = user ? guardedRoutes : publicRoutes;
  const element = useRoutes(routes);

  // Show loading state
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center text-sm text-slate-600">
        Loading authentication...
      </div>
    );
  }

  // If user is logged in, use guarded routes (which now check admin role)
  return element;
}