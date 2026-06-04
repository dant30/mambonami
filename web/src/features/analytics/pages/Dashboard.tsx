import React from 'react';

export default function Dashboard() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Dashboard</h1>
      <div className="grid grid-cols-4 gap-4 mt-6">
        <div className="bg-white p-4 rounded shadow">Total Orders: 0</div>
        <div className="bg-white p-4 rounded shadow">Revenue: KES 0</div>
        <div className="bg-white p-4 rounded shadow">Farmers: 0</div>
        <div className="bg-white p-4 rounded shadow">Providers: 0</div>
      </div>
    </div>
  );
}
