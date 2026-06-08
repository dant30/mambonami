// web/src/shared/layout/MainLayout.tsx
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Header from './Header';

export default function MainLayout() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-emerald-100 to-green-50 text-slate-900 dark:from-slate-950 dark:via-slate-900 dark:to-slate-950 dark:text-slate-100">

      <div className="flex min-h-screen">

        {/* Sidebar (already fixed inside component) */}
        <Sidebar />

        {/* Main content area */}
        <div className="flex flex-1 flex-col ml-72">

          {/* Header */}
          <Header />

          {/* Page content */}
          <main className="flex-1 overflow-y-auto p-6 xl:px-8">
            <div className="mx-auto w-full max-w-7xl">
              <Outlet />
            </div>
          </main>

        </div>
      </div>
    </div>
  );
}