import type { ReactNode } from 'react'

import { BackToTop } from '../components/ui/BackToTop'
import { ToastContainer } from '../components/feedback'
import { useAuth } from '../../core/contexts/AuthContext'
import { useMediaQuery } from '../../core/hooks'
import { FloatingButton } from './FloatingButton'
import { Footer } from './Footer'
import { Header } from './Header'
import { MobileBottomNav } from './MobileBottomNav'
import { Sidebar } from './Sidebar'

export function MainLayout({ children, admin = false }: { children: ReactNode; admin?: boolean }) {
	const { isAuthenticated, user } = useAuth()
	const isDesktop = useMediaQuery('(min-width: 768px)')
	const isAdmin = admin || Boolean(user?.is_staff || user?.is_superuser)

	return (
		<div className="min-h-screen bg-background text-foreground">
			<Header />
			<div className="flex min-h-[calc(100vh-4rem)] items-start">
				{isAuthenticated && isDesktop && <Sidebar admin={isAdmin} />}
				<div className="flex min-w-0 flex-1 flex-col">
					<main className="min-w-0 flex-1 pb-[calc(5rem+env(safe-area-inset-bottom))] md:pb-0">{children}</main>
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
