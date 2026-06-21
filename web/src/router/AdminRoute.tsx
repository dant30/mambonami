// web/src/router/AdminRoute.tsx
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../features/auth/hooks/useAuth';

export const AdminRoute = () => {
  const { user, loading, hasRole } = useAuth();

  if (loading) {
    return <div className="min-h-screen flex items-center justify-center">Checking authentication...</div>;
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (!hasRole('admin')) {
    // Redirect to a "not authorized" page or show message
    return <div className="min-h-screen flex items-center justify-center text-center p-4">
      <div>
        <h1 className="text-2xl font-bold text-red-600">Access Denied</h1>
        <p className="mt-2 text-slate-600 dark:text-slate-400">
          This dashboard is for administrators only. Please use the mobile app.
        </p>
      </div>
    </div>;
  }

  return <Outlet />;
};