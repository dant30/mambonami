import { expect, test } from '@playwright/test'

test.beforeEach(async ({ page }) => {
	await page.route('**/api/**', async (route) => {
		const url = route.request().url()
		if (url.includes('/api/products/')) {
			if (url.includes('/categories/')) return route.fulfill({ json: [] })
			return route.fulfill({ json: { count: 0, results: [] } })
		}
		return route.fulfill({ status: 401, json: { detail: 'Unauthenticated' } })
	})
})

test('public product discovery is usable on desktop', async ({ page }) => {
	await page.goto('/products')
	await expect(page.getByRole('heading', { name: 'Find food worth bringing home.' })).toBeVisible()
	await expect(page.getByRole('textbox', { name: 'Search products' })).toBeVisible()
	await expect(page.getByRole('button', { name: 'All produce' })).toBeVisible()
	await expect(page.locator('body')).toHaveCSS('overflow-x', 'visible')
})

test('public marketplace remains readable and unclipped on mobile', async ({ page }) => {
	await page.goto('/products')
	await expect(page.getByRole('heading', { name: 'Find food worth bringing home.' })).toBeVisible()
	await expect(page.getByRole('textbox', { name: 'Search products' })).toBeVisible()
	const dimensions = await page.evaluate(() => ({ documentWidth: document.documentElement.scrollWidth, viewportWidth: window.innerWidth }))
	expect(dimensions.documentWidth).toBeLessThanOrEqual(dimensions.viewportWidth + 1)
})

test('checkout preserves the authentication handoff', async ({ page }) => {
	await page.goto('/checkout')
	await expect(page).toHaveURL(/\/login$/)
	await expect(page.getByRole('textbox', { name: 'Phone number' })).toBeVisible()
	await expect(page.getByLabel('Phone number')).toHaveAttribute('id')
	await expect(page.getByLabel('Password')).toHaveAttribute('id')
})

test('empty cart and wishlist remain usable on a narrow viewport', async ({ page }) => {
	await page.goto('/cart')
	await expect(page.getByRole('heading', { name: 'Good food, gathered in one place.' })).toBeVisible()
	await expect(page.getByRole('link', { name: /Browse produce/ })).toBeVisible()
	await page.goto('/wishlist')
	await expect(page.getByRole('heading', { name: 'Keep the good finds close.' })).toBeVisible()
	const dimensions = await page.evaluate(() => ({ documentWidth: document.documentElement.scrollWidth, viewportWidth: window.innerWidth }))
	expect(dimensions.documentWidth).toBeLessThanOrEqual(dimensions.viewportWidth + 1)
})

for (const scenario of [
	{ role: 'buyer', path: '/app/buyer' },
	{ role: 'farmer', path: '/app/farmer' },
	{ role: 'retailer', path: '/app/retailer' },
	{ role: 'transport_provider', path: '/app/transport' },
	{ role: 'admin', path: '/app/admin', is_staff: true },
]) {
	test(`${scenario.role} login reaches the correct workspace`, async ({ page }) => {
		await page.route('**/api/users/login/', async (route) => route.fulfill({ json: { access: 'access-token', user: { id: 1, role: scenario.role, is_staff: scenario.is_staff ?? false } } }))
		await page.goto('/login')
		await page.getByRole('textbox', { name: 'Phone number' }).fill('+254700000000')
		await page.getByLabel('Password').fill('password')
		await page.getByRole('button', { name: 'Log in' }).click()
		await expect(page).toHaveURL(new RegExp(`${scenario.path}$`))
	})
}
