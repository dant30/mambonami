import React from 'react';
export default function Header() {
  return (
    <header className="bg-white shadow p-4 flex justify-between items-center">
      <h1 className="text-xl">MAMBONAMI Admin</h1>
      <button onClick={() => { localStorage.removeItem('access_token'); window.location.href = '/login'; }}>Logout</button>
    </header>
  );
}
