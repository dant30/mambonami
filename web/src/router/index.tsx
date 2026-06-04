import { useRoutes } from 'react-router-dom';
import { publicRoutes } from './public.routes';
import { guardedRoutes } from './guarded.routes';
export default function AppRouter() {
  const isAuthenticated = !!localStorage.getItem('access_token');
  const routes = isAuthenticated ? guardedRoutes : publicRoutes;
  return useRoutes(routes);
}
