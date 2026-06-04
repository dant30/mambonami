import { Navigate, Outlet } from 'react-router-dom';
export const PublicRoute = () => {
  const token = localStorage.getItem('access_token');
  return token ? <Navigate to="/" replace /> : <Outlet />;
};
