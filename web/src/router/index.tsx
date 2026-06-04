import { useRoutes } from 'react-router-dom';
import { publicRoutes } from './public.routes';
import { guardedRoutes } from './guarded.routes';
import { useAuth } from '../core/hooks/useAuth';
export default function AppRouter() {
  const { loading, user } = useAuth();
  const routes = user ? guardedRoutes : publicRoutes;
  const element = useRoutes(routes);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center text-sm text-slate-600">
        Loading authentication...
      </div>
    );
  }

  return element;
}
