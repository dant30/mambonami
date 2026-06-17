// web/src/shared/layout/MainLayout.tsx
import { Outlet } from 'react-router-dom';
import { SidebarProvider, SidebarInset } from '@/shared/components/ui/Sidebar';
import { AppSidebar } from './AppSidebar';
import Header from './Header';
import Footer from './Footer';

export default function MainLayout() {
  return (
    <SidebarProvider defaultOpen>
      <div className="flex min-h-svh w-full overflow-hidden bg-background">
        <AppSidebar />
        <SidebarInset className="flex flex-1 flex-col overflow-hidden pt-0">
          <Header />
          <div className="flex flex-1 flex-col overflow-auto">
            <main className="flex-1 p-6 xl:px-8">
              <div className="mx-auto w-full max-w-7xl">
                <Outlet />
              </div>
            </main>
            <Footer />
          </div>
        </SidebarInset>
      </div>
    </SidebarProvider>
  );
}