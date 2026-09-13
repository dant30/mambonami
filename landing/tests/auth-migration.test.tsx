import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { AuthProvider, useAuth } from '../src/core/contexts/AuthContext'
import { guestWishlistStore } from '../src/core/lib/stores/products/guestWishlistStore'
import { orderStore } from '../src/core/lib/stores/orders/orderStore'
import type { Product } from '../src/core/lib/types/products/product'

const products: Product[] = [
	{ id: 1, uuid: 'tomatoes-1', sku: 'TOM-1', name: 'Tomatoes', price_per_unit: 45, available_quantity: 20, unit: 'kg' },
	{ id: 2, uuid: 'onions-1', sku: 'ONI-1', name: 'Onions', price_per_unit: 25, available_quantity: 20, unit: 'kg' },
]

function LoginProbe() {
	const { login, isAuthenticated } = useAuth()
	return <button onClick={() => void login({ phone: '+254700000000', password: 'secret' })}>{isAuthenticated ? 'signed in' : 'sign in'}</button>
}

function jsonResponse(body: unknown, status = 200) {
	return new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } })
}

describe('guest wishlist migration', () => {
	beforeEach(() => {
		guestWishlistStore.clear()
		orderStore.clear()
	})

	it('clears locally stored items after every server migration succeeds', async () => {
		guestWishlistStore.add(products[0])
		orderStore.addCartItem({ product_uuid: products[0].uuid, quantity: 1, unit_price: products[0].price_per_unit, product_detail: products[0] })
		vi.stubGlobal('fetch', vi.fn(async () => jsonResponse({ access: 'token', user: { id: 1, role: 'buyer' } })))
		render(<AuthProvider><LoginProbe /></AuthProvider>)

		fireEvent.click(screen.getByRole('button', { name: 'sign in' }))
		await waitFor(() => expect(screen.getByRole('button', { name: 'signed in' })).toBeInTheDocument())
		expect(guestWishlistStore.getItems()).toEqual([])
		expect(orderStore.getCart()).toHaveLength(1)
	})

	it('retains only failed items when part of the server migration is unavailable', async () => {
		guestWishlistStore.add(products[0])
		guestWishlistStore.add(products[1])
		vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL) => {
			const url = String(input)
			if (url.includes('/api/products/wishlist/tomatoes-1/')) return jsonResponse({ id: 10 })
			if (url.includes('/api/products/wishlist/onions-1/')) return jsonResponse({ detail: 'unavailable' }, 503)
			return jsonResponse({ access: 'token', user: { id: 1, role: 'buyer' } })
		}))
		render(<AuthProvider><LoginProbe /></AuthProvider>)

		fireEvent.click(screen.getByRole('button', { name: 'sign in' }))
		await waitFor(() => expect(screen.getByRole('button', { name: 'signed in' })).toBeInTheDocument())
		expect(guestWishlistStore.getItems().map((product) => product.uuid)).toEqual(['onions-1'])
	})
})
