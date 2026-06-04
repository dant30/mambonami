import { NavLink } from 'react-router-dom';
export default function Sidebar() {
  return (
    <aside className="w-64 bg-gray-800 text-white">
      <nav className="p-4">
        <NavLink to="/" className="block py-2">Dashboard</NavLink>
        <NavLink to="/orders" className="block py-2">Orders</NavLink>
        <NavLink to="/products" className="block py-2">Products</NavLink>
        <NavLink to="/transport" className="block py-2">Transport Providers</NavLink>
        <NavLink to="/disputes" className="block py-2">Disputes</NavLink>
        <NavLink to="/payouts" className="block py-2">Payouts</NavLink>
        <NavLink to="/admin/farmer-approval" className="block py-2">Farmer Approval</NavLink>
        <NavLink to="/admin/audit-log" className="block py-2">Audit Log</NavLink>
      </nav>
    </aside>
  );
}
