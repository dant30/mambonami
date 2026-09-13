import type { RouteObject } from 'react-router-dom'

import { AboutUs, CartPage, CheckoutPage, HomePage, HowItWorks, ProductDetailPage, ProductsPage, Support, WishlistPage } from '../features/home'
import { ForgotPasswordPage, LoginPage, OnboardingPage, OtpPage, ProgressiveRegisterPage, ResetPasswordPage, RoleSelectPage, SessionExpiredPage, SplashPage, SuccessPage, WelcomePage } from '../features/auth'
import { PublicLayout } from './route-pages'

export const publicRoutes: RouteObject[] = [
	{ path: '/', element: <SplashPage /> },
	{ path: '/splash', element: <SplashPage /> },
	{ element: <PublicLayout />, children: [
		{ path: '/home', element: <HomePage /> },
		{ path: '/products', element: <ProductsPage /> },
		{ path: '/product/:id', element: <ProductDetailPage /> },
		{ path: '/cart', element: <CartPage /> },
		{ path: '/wishlist', element: <WishlistPage /> },
		{ path: '/checkout', element: <CheckoutPage /> },
		{ path: '/how-it-works', element: <HowItWorks /> },
		{ path: '/about', element: <AboutUs /> },
		{ path: '/support', element: <Support /> },
		{ path: '/welcome', element: <WelcomePage /> },
		{ path: '/role-select', element: <RoleSelectPage /> },
		{ path: '/login', element: <LoginPage /> },
		{ path: '/forgot-password', element: <ForgotPasswordPage /> },
		{ path: '/reset-password', element: <ResetPasswordPage /> },
		{ path: '/otp', element: <OtpPage /> },
		{ path: '/success', element: <SuccessPage /> },
		{ path: '/session-expired', element: <SessionExpiredPage /> },
		{ path: '/onboarding', element: <OnboardingPage /> },
		{ path: '/register/buyer', element: <ProgressiveRegisterPage role="buyer" /> },
		{ path: '/register/farmer', element: <ProgressiveRegisterPage role="farmer" /> },
		{ path: '/register/retailer', element: <ProgressiveRegisterPage role="retailer" /> },
		{ path: '/register/transport_provider', element: <ProgressiveRegisterPage role="transport_provider" /> },
	] },
]
