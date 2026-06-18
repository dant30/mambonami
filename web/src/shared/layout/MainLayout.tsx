// web/src/shared/layout/MainLayout.tsx
import { Outlet } from 'react-router-dom';
import { AppSidebar } from './AppSidebar';
import Header from './Header';
import Footer from './Footer';
import { useIsMobile } from '@/core/hooks/useIsMobile';
import { useState, useEffect } from 'react';
import { cn } from '@/lib/utils';

export default function MainLayout() {
  const isMobile = useIsMobile();
  const [collapsed, setCollapsed] = useState(() => {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('sidebar-collapsed') === 'true';
    }
    return false;
  });

  useEffect(() => {
    const handler = () => {
      setCollapsed(localStorage.getItem('sidebar-collapsed') === 'true');
    };
    window.addEventListener('storage', handler);
    return () => window.removeEventListener('storage', handler);
  }, []);

  // If desktop and not collapsed, add left margin equal to sidebar width
  const sidebarMargin = !isMobile && !collapsed ? 'ml-64' : !isMobile && collapsed ? 'ml-16' : '';

  return (
    <div className="flex min-h-screen w-full bg-background">
      <AppSidebar />
      <div className={cn("flex flex-1 flex-col transition-all duration-300", sidebarMargin)}>
        <Header />
        <main className="flex-1 p-6 xl:px-8 overflow-y-auto">
          <div className="mx-auto max-w-7xl">
            <Outlet />
          </div>
        </main>
        <Footer />
      </div>
    </div>
  );
}