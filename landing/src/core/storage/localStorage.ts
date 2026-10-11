interface StorageStore {
	get<T>(key: string): T | null
	set<T>(key: string, value: T): void
	remove(key: string): void
	has(key: string): boolean
	clear(): void
}

function createStorageStore(getStorage: () => Storage | null): StorageStore {
	const safeGetStorage = () => {
		try {
			return getStorage()
		} catch {
			return null
		}
	}

	return {
		get<T>(key: string) {
			const storage = safeGetStorage()
			if (!storage) return null

			try {
				const value = storage.getItem(key)
				if (value === null) return null

				try {
					return JSON.parse(value) as T
				} catch {
					return value as T
				}
			} catch {
				return null
			}
		},

		set<T>(key: string, value: T) {
			const storage = safeGetStorage()
			if (!storage) return

			try {
				storage.setItem(key, JSON.stringify(value))
			} catch {
				return
			}
		},

		remove(key) {
			const storage = safeGetStorage()
			if (!storage) return

			try {
				storage.removeItem(key)
			} catch {
				return
			}
		},

		has(key) {
			const storage = safeGetStorage()
			if (!storage) return false

			try {
				return storage.getItem(key) !== null
			} catch {
				return false
			}
		},

		clear() {
			const storage = safeGetStorage()
			if (!storage) return

			try {
				storage.clear()
			} catch {
				return
			}
		},
	}
}

export const localStorageStore = createStorageStore(() => {
	if (typeof window === 'undefined') return null
	return window.localStorage
})

export const localStore = localStorageStore
