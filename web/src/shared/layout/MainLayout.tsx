// web/src/shared/layout/MainLayout.tsx
import { Outlet } from 'react-router-dom';
import { SidebarProvider } from '@/core/context';
import { AppSidebar } from './AppSidebar';
import Header from './Header';
import Footer from './Footer';
import { useSidebar } from '@/core/context';
import { cn } from '@/lib/utils';

function LayoutContent() {
  const { isCollapsed, isMobile } = useSidebar();
  
  // Desktop: apply margin based on collapsed state
  const sidebarMargin = !isMobile
    ? isCollapsed ? 'ml-16' : 'ml-64'
    : '';

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

export default function MainLayout() {
  return (
    <SidebarProvider>
      <LayoutContent />
    </SidebarProvider>
  );
}