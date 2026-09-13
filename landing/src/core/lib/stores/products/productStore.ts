import type { Product, ProductCategory, ProductUnitOption, WishlistItem } from '../../types'

let cachedProducts: Product[] = []
let cachedCategories: ProductCategory[] = []
let cachedUnits: ProductUnitOption[] = []
let cachedWishlist: WishlistItem[] = []
let cachedFarmerProducts: Product[] = []

export const productStore = {
	getProducts(): Product[] {
		return cachedProducts
	},
	setProducts(products: Product[]) {
		cachedProducts = products
	},
	getCategories(): ProductCategory[] {
		return cachedCategories
	},
	setCategories(categories: ProductCategory[]) {
		cachedCategories = categories
	},
	getUnits(): ProductUnitOption[] {
		return cachedUnits
	},
	setUnits(units: ProductUnitOption[]) {
		cachedUnits = units
	},
	getWishlist(): WishlistItem[] {
		return cachedWishlist
	},
	setWishlist(items: WishlistItem[]) {
		cachedWishlist = items
	},
	getFarmerProducts(): Product[] {
		return cachedFarmerProducts
	},
	setFarmerProducts(products: Product[]) {
		cachedFarmerProducts = products
	},
	clear() {
		cachedProducts = []
		cachedCategories = []
		cachedUnits = []
		cachedWishlist = []
		cachedFarmerProducts = []
	},
}
