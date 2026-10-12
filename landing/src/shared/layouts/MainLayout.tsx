import type { ReactNode } from 'react'
import { useLocation } from 'react-router-dom'

import { BackToTop } from '../components/ui/BackToTop'
import { ToastContainer } from '../components/feedback'
import { useAuth } from '../../core/contexts/AuthContext'
import { useMediaQuery, useSeo } from '../../core/hooks'
import { resolveRouteSeo } from '../../core/utils/routeSeo'
import { FloatingButton } from './FloatingButton'
import { Footer } from './Footer'
import { Header } from './Header'
import { MobileBottomNav } from './MobileBottomNav'
import { Sidebar } from './Sidebar'
import { useState } from 'react'

export function MainLayout({ children, admin = false }: { children: ReactNode; admin?: boolean }) {
	const location = useLocation()
	const { isAuthenticated, user } = useAuth()
	const isDesktop = useMediaQuery('(min-width: 768px)')
	const isAdmin = admin || Boolean(user?.is_staff || user?.is_superuser)
	const [mobileSidebarOpen, setMobileSidebarOpen] = useState(false)
	const routeSeo = resolveRouteSeo(location.pathname)

	return (
		<div className="min-h-screen bg-background text-foreground">
			{routeSeo && <RouteSeoHead pathname={location.pathname} config={routeSeo} />}
			<Header onMenuToggle={() => setMobileSidebarOpen((open) => !open)} />
			{!isDesktop && mobileSidebarOpen && <div className="fixed inset-0 z-[60] bg-primary-dark/40 backdrop-blur-[2px]" onClick={() => setMobileSidebarOpen(false)} aria-hidden="true"><div className="h-[100dvh] w-[min(86vw,20rem)] animate-slide-in-left" onClick={(event) => event.stopPropagation()}><Sidebar admin={isAdmin} mobileDrawer onItemClick={() => setMobileSidebarOpen(false)} onClose={() => setMobileSidebarOpen(false)} /></div></div>}
				<div className="flex min-h-[calc(100dvh-3.5rem)] items-start sm:min-h-[calc(100vh-4rem)]">
				{isAuthenticated && isDesktop && <Sidebar admin={isAdmin} />}
				<div className="flex min-w-0 flex-1 flex-col">
					<main className="min-w-0 flex-1 pb-[calc(4.5rem+env(safe-area-inset-bottom))] md:pb-0">{children}</main>
					<Footer />
				</div>
			</div>
			<FloatingButton />
			<BackToTop />
			<ToastContainer />
			{!isDesktop && <MobileBottomNav />}
		</div>
	)
}

function RouteSeoHead({ pathname, config }: { pathname: string; config: NonNullable<ReturnType<typeof resolveRouteSeo>> }) {
	useSeo({ ...config, path: pathname })
	return null
}
