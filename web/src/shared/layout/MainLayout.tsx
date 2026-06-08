import { Outlet } from 'react-router-dom';
import { SidebarProvider, SidebarInset } from '@/shared/components/ui/Sidebar';
import { AppSidebar } from './AppSidebar';
import Header from './Header';

export default function MainLayout() {
  return (
    <SidebarProvider defaultOpen>
      <div className="flex h-screen w-full">
        <AppSidebar />
        <SidebarInset className="flex flex-1 flex-col overflow-auto">
          <Header />
          <main className="flex-1 p-6 xl:px-8">
            <div className="mx-auto w-full max-w-7xl">
              <Outlet />
            </div>
          </main>
        </SidebarInset>
      </div>
    </SidebarProvider>
  );
}