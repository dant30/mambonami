import { localStorageStore } from '../../../storage'
import type { Product } from '../../types'

const GUEST_WISHLIST_KEY = 'mambonami_guest_wishlist'

let cachedProducts = localStorageStore.get<Product[]>(GUEST_WISHLIST_KEY) ?? []

function persist(products: Product[]) {
	cachedProducts = products
	localStorageStore.set(GUEST_WISHLIST_KEY, products)
}

export const guestWishlistStore = {
	getItems: () => cachedProducts,
	has: (uuid: string) => cachedProducts.some((product) => product.uuid === uuid),
	add: (product: Product) => {
		if (!cachedProducts.some((item) => item.uuid === product.uuid)) persist([...cachedProducts, product])
		return cachedProducts
	},
	remove: (uuid: string) => {
		persist(cachedProducts.filter((product) => product.uuid !== uuid))
		return cachedProducts
	},
	clear: () => {
		persist([])
		return cachedProducts
	},
}
