import create from 'zustand';
import type { Product } from '../types/product';

interface ProductStoreState {
  products: Product[];
  loading: boolean;
  error: string | null;
  setProducts: (products: Product[]) => void;
  setLoading: (value: boolean) => void;
  setError: (value: string | null) => void;
  reset: () => void;
}

export const useProductStore = create<ProductStoreState>((set) => ({
  products: [],
  loading: false,
  error: null,
  setProducts: (products) => set({ products }),
  setLoading: (value) => set({ loading: value }),
  setError: (value) => set({ error: value }),
  reset: () => set({ products: [], loading: false, error: null }),
}));
