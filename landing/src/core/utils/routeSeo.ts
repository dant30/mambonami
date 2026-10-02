import { defaultDescription, defaultTitle, marketplaceJsonLd, organizationJsonLd, websiteJsonLd } from './seo'

export interface RouteSeoConfig {
	title: string
	description?: string
	noIndex?: boolean
	jsonLd?: object | object[]
}

/** Routes whose page component calls useSeo itself (dynamic data); the layout must not override them. */
const SELF_MANAGED_PREFIXES = ['/product/', '/app/buyer/product/']

const PUBLIC_PAGES: Record<string, RouteSeoConfig> = {
	'/': { title: defaultTitle, description: defaultDescription, jsonLd: [organizationJsonLd, websiteJsonLd, marketplaceJsonLd] },
	'/home': { title: defaultTitle, description: defaultDescription, jsonLd: [organizationJsonLd, websiteJsonLd, marketplaceJsonLd] },
	'/products': { title: 'Fresh Produce from Kenyan Farms', description: 'Browse fresh vegetables, fruits and farm produce direct from verified Kenyan farmers. Fair prices, M-Pesa escrow and reliable delivery.' },
	'/how-it-works': { title: 'How MAMBONAMI Works', description: 'See how MAMBONAMI connects farmers and buyers: order fresh produce, pay securely with M-Pesa escrow, and receive it with OTP-verified delivery.' },
	'/about': { title: 'About MAMBONAMI', description: 'MAMBONAMI is a Kenyan marketplace that gives farmers fair prices and buyers traceable, farm-fresh produce with transparent delivery.' },
	'/support': { title: 'Help and Support', description: 'Get help with orders, payments, deliveries and your MAMBONAMI account. Contact our Nairobi support team.' },
	'/terms': { title: 'Terms and Conditions', description: 'The terms that govern use of the MAMBONAMI produce marketplace for farmers, buyers, retailers and transporters.' },
	'/privacy': { title: 'Privacy Policy', description: 'How MAMBONAMI collects, uses and protects your personal data.' },
	'/login': { title: 'Log In', description: 'Log in to your MAMBONAMI account to buy, sell or deliver fresh farm produce in Kenya.', noIndex: true },
	'/register/buyer': { title: 'Create a Buyer Account', description: 'Join MAMBONAMI as a buyer and order fresh produce directly from Kenyan farmers.', noIndex: true },
	'/register/farmer': { title: 'Sell Your Harvest as a Farmer', description: 'Register as a farmer on MAMBONAMI to reach buyers across Kenya, set your own prices and get paid via M-Pesa.', noIndex: true },
	'/register/retailer': { title: 'Register as a Retailer', description: 'Source fresh produce in bulk from verified farmers. Register your retail or restaurant business on MAMBONAMI.', noIndex: true },
	'/register/transport_provider': { title: 'Become a Delivery Partner', description: 'Earn by delivering farm produce across Kenya. Register as a MAMBONAMI transport provider.', noIndex: true },
}

// Transactional or one-time screens that should not appear in search results.
const NO_INDEX_PAGES: Record<string, string> = {
	'/cart': 'Your Cart',
	'/wishlist': 'Your Wishlist',
	'/checkout': 'Checkout',
	'/welcome': 'Welcome',
	'/role-select': 'Choose Your Role',
	'/forgot-password': 'Forgot Password',
	'/reset-password': 'Reset Password',
	'/otp': 'Verify Your Code',
	'/success': 'Success',
	'/session-expired': 'Session Expired',
	'/onboarding': 'Get Started',
}

// Most specific first; first match wins.
const WORKSPACE_PAGES: Array<[RegExp, string]> = [
	[/^\/app\/farmer\/products\/new$/, 'Add a Product'],
	[/^\/app\/farmer\/products\/[^/]+\/edit$/, 'Edit Product'],
	[/^\/app\/farmer\/products/, 'My Products'],
	[/^\/app\/farmer\/orders/, 'Farm Orders'],
	[/^\/app\/farmer\/(sales|earnings)/, 'Earnings'],
	[/^\/app\/farmer/, 'Farmer Dashboard'],
	[/^\/app\/buyer\/cart/, 'Your Cart'],
	[/^\/app\/buyer\/checkout/, 'Checkout'],
	[/^\/app\/buyer\/wishlist/, 'Your Wishlist'],
	[/^\/app\/buyer\/(active-)?orders/, 'Your Orders'],
	[/^\/app\/buyer\/products/, 'Browse Produce'],
	[/^\/app\/buyer\/profile/, 'Your Profile'],
	[/^\/app\/buyer\/settings/, 'Settings'],
	[/^\/app\/buyer/, 'Buyer Dashboard'],
	[/^\/app\/retailer\/products/, 'Retailer Products'],
	[/^\/app\/retailer\/orders/, 'Retailer Orders'],
	[/^\/app\/retailer\/suppliers/, 'Suppliers'],
	[/^\/app\/retailer\/invoices/, 'Invoices'],
	[/^\/app\/retailer/, 'Retailer Dashboard'],
	[/^\/app\/transport\/jobs\/[^/]+$/, 'Trip Details'],
	[/^\/app\/transport\/jobs/, 'Delivery Jobs'],
	[/^\/app\/transport\/(active|completed)-jobs/, 'My Trips'],
	[/^\/app\/transport\/earnings/, 'Earnings'],
	[/^\/app\/transport\/vehicles/, 'Vehicles'],
	[/^\/app\/transport/, 'Transporter Dashboard'],
	[/^\/(app\/)?admin/, 'Admin Console'],
]

/** Returns SEO settings for a pathname, or null when the page manages its own metadata. */
export function resolveRouteSeo(pathname: string): RouteSeoConfig | null {
	const path = pathname.length > 1 ? pathname.replace(/\/$/, '') : pathname
	if (SELF_MANAGED_PREFIXES.some((prefix) => path.startsWith(prefix))) return null

	const publicPage = PUBLIC_PAGES[path]
	if (publicPage) return publicPage

	if (path in NO_INDEX_PAGES) return { title: NO_INDEX_PAGES[path], noIndex: true }

	const workspace = WORKSPACE_PAGES.find(([pattern]) => pattern.test(path))
	if (workspace) return { title: workspace[1], noIndex: true }

	return { title: defaultTitle, description: defaultDescription, noIndex: path.startsWith('/app') }
}
