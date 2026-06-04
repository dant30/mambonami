import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../core/hooks/useAuth';

export default function Header() {
  const navigate = useNavigate();
  const { user, logout } = useAuth();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <header className="bg-white border-b border-slate-200 px-6 py-4 shadow-sm flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
      <div className="flex items-center gap-4">
        <Link to="/" className="text-xl font-semibold text-slate-900 hover:text-slate-800">
          MAMBONAMI Admin
        </Link>
        <nav className="hidden items-center gap-3 text-sm text-slate-600 md:flex">
          <Link to="/" className="hover:text-slate-900">
            Dashboard
          </Link>
          <Link to="/profile" className="hover:text-slate-900">
            Profile
          </Link>
        </nav>
      </div>

      <div className="flex flex-col items-start gap-3 sm:flex-row sm:items-center">
        {user ? (
          <div className="rounded-full bg-slate-100 px-3 py-1 text-sm font-medium text-slate-700">
            {user.username || user.phone}
          </div>
        ) : null}
        <button
          className="rounded-md bg-red-600 px-4 py-2 text-sm font-semibold text-white transition hover:bg-red-700"
          type="button"
          onClick={handleLogout}
        >
          Logout
        </button>
      </div>
    </header>
  );
}
