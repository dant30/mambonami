import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../core/hooks/useAuth';

export default function Header() {
  const navigate = useNavigate();
  const { user, logout } = useAuth();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <header className="bg-white shadow p-4 flex justify-between items-center">
      <div>
        <h1 className="text-xl font-semibold">MAMBONAMI Admin</h1>
        {user ? <p className="text-sm text-slate-500">{user.username || user.phone}</p> : null}
      </div>
      <button className="text-sm text-red-600 hover:text-red-800" type="button" onClick={handleLogout}>
        Logout
      </button>
    </header>
  );
}
