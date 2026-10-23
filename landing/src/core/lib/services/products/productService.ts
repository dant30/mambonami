import { apiClient, type QueryValue } from '../../../api'
import { PRODUCT_ENDPOINTS } from '../../../api/endpoints'
import { localStorageStore } from '../../../storage'
import type {
	Product,
	ProductCreateInput,
	ProductListParams,
	ProductListResponse,
	ProductUnitOption,
	WishlistItem,
	ProductReview,
} from '../../types'

function normalizeProductList(response: ProductListResponse | Product[]): Product[] {
	return Array.isArray(response) ? response : response.results ?? []
}

function normalizePagedResponse<T>(response: { results?: T[] } | T[]): T[] {
	return Array.isArray(response) ? response : response.results ?? []
}

function buildProductFormData(input: ProductCreateInput): FormData {
	const formData = new FormData()

	Object.entries(input).forEach(([key, value]) => {
		if (value === undefined || value === null || value === '') return

		if (value instanceof File || value instanceof Blob) {
			formData.append(key, value)
			return
		}
		if (Array.isArray(value)) {
			formData.append(key, JSON.stringify(value))
			return
		}

		if (typeof value === 'boolean' || typeof value === 'number' || typeof value === 'string') {
			formData.append(key, String(value))
		}
	})

	return formData
}

export async function listProducts(params: ProductListParams = {}): Promise<ProductListResponse> {
	const queryParams: Record<string, QueryValue> = {}
	const storedLocation = localStorageStore.get<{ latitude: number; longitude: number }>('buyer_delivery_location')
	const buyerLat = params.buyer_lat ?? params.lat ?? storedLocation?.latitude
	const buyerLng = params.buyer_lng ?? params.lng ?? storedLocation?.longitude
	if (params.category !== undefined) queryParams.category = params.category
	if (params.is_organic !== undefined) queryParams.is_organic = params.is_organic
	if (params.min_price !== undefined) queryParams.min_price = params.min_price
	if (params.max_price !== undefined) queryParams.max_price = params.max_price
	if (params.min_rating !== undefined) queryParams.min_rating = params.min_rating
	if (params.in_stock !== undefined) queryParams.in_stock = params.in_stock
	if (params.search !== undefined) queryParams.search = params.search
	if (params.page !== undefined) queryParams.page = params.page
	if (params.page_size !== undefined) queryParams.page_size = params.page_size
	if (buyerLat !== undefined) queryParams.buyer_lat = buyerLat
	if (buyerLng !== undefined) queryParams.buyer_lng = buyerLng
	if (params.ordering !== undefined) queryParams.ordering = params.ordering
	if (params.farmer_phone !== undefined) queryParams.farmer_phone = params.farmer_phone

	const response = await apiClient.get<ProductListResponse | Product[]>(PRODUCT_ENDPOINTS.list, {
		params: queryParams,
	})

	return Array.isArray(response) ? { count: response.length, results: response } : response
}

export async function getProduct(uuid: string): Promise<Product> {
	return apiClient.get<Product>(PRODUCT_ENDPOINTS.detail(uuid))
}

export async function listProductReviews(uuid: string): Promise<ProductReview[]> {
	const response = await apiClient.get<ProductReview[] | { results?: ProductReview[] }>(PRODUCT_ENDPOINTS.reviews(uuid))
	return normalizePagedResponse(response)
}

export function createProductReview(uuid: string, input: { order_item: number; rating: number; comment: string }): Promise<ProductReview> {
	return apiClient.post<ProductReview>(PRODUCT_ENDPOINTS.reviews(uuid), input)
}

export async function listProductCategories() {
	const response = await apiClient.get<Array<{ id: number; code: string; name: string }> | { results?: Array<{ id: number; code: string; name: string }>; categories?: Array<{ id: number; code: string; name: string }> }>(PRODUCT_ENDPOINTS.categories)
	if (Array.isArray(response)) return response
	return response.results ?? response.categories ?? []
}

export async function listProductUnits(): Promise<ProductUnitOption[]> {
	return apiClient.get<ProductUnitOption[]>(PRODUCT_ENDPOINTS.units)
}

export async function listWishlist(): Promise<WishlistItem[]> {
	const response = await apiClient.get<WishlistItem[] | { results?: WishlistItem[] }>(PRODUCT_ENDPOINTS.wishlist)
	return normalizePagedResponse<WishlistItem>(response)
}

export async function addToWishlist(uuid: string): Promise<WishlistItem> {
	return apiClient.post<WishlistItem>(PRODUCT_ENDPOINTS.wishlistItem(uuid))
}

export async function removeFromWishlist(uuid: string): Promise<void> {
	await apiClient.delete<void>(PRODUCT_ENDPOINTS.wishlistItem(uuid))
}

export async function listFarmerProducts(): Promise<Product[]> {
	const response = await apiClient.get<Product[] | { results?: Product[] }>(PRODUCT_ENDPOINTS.farmerProducts)
	return normalizePagedResponse<Product>(response)
}

export async function createFarmerProduct(input: ProductCreateInput): Promise<Product> {
	const hasFile = typeof input.image === 'object' && input.image !== null
	const body = hasFile ? buildProductFormData(input) : input
	return apiClient.post<Product>(PRODUCT_ENDPOINTS.farmerProducts, body)
}

export async function updateFarmerProduct(uuid: string, input: ProductCreateInput): Promise<Product> {
	const hasFile = typeof input.image === 'object' && input.image !== null
	const body = hasFile ? buildProductFormData(input) : input
	return apiClient.put<Product>(PRODUCT_ENDPOINTS.farmerProduct(uuid), body)
}

export async function deleteFarmerProduct(uuid: string): Promise<void> {
	await apiClient.delete<void>(PRODUCT_ENDPOINTS.farmerProduct(uuid))
}
