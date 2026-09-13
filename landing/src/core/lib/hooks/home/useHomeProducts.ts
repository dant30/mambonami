import { useProducts } from '../products'

export function useHomeProducts() {
	return useProducts({ page_size: 6 })
}
