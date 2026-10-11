import { useEffect, useState } from 'react'
import type { AdminResourceCache } from '../../types/admin'

export function useAdminResource<T>(
	loadResource: () => Promise<T>,
	cache?: AdminResourceCache<T>,
	enabled = true,
) {
	const [data, setData] = useState<T | null>(() => cache?.get() ?? null)
	const [isLoading, setIsLoading] = useState(enabled)
	const [error, setError] = useState<string | null>(null)
	const [notice, setNotice] = useState('')
	const [busy, setBusy] = useState<string | null>(null)
	const [reloadKey, setReloadKey] = useState(0)

	useEffect(() => {
		if (!enabled) {
			setIsLoading(false)
			return
		}

		let active = true
		setIsLoading(true)
		setError(null)
		loadResource().then((next) => {
			if (!active) return
			cache?.set(next)
			setData(next)
		}).catch((requestError: unknown) => {
			if (active) setError(requestError instanceof Error ? requestError.message : 'Unable to load admin data.')
		}).finally(() => {
			if (active) setIsLoading(false)
		})
		return () => { active = false }
	}, [cache, enabled, loadResource, reloadKey])

	const refresh = () => setReloadKey((key) => key + 1)
	const runAction = async (key: string, action: () => Promise<unknown>, successMessage: string) => {
		setBusy(key)
		setError(null)
		setNotice('')
		try {
			await action()
			setNotice(successMessage)
			refresh()
		} catch (actionError) {
			setError(actionError instanceof Error ? actionError.message : 'The operation could not be completed.')
		} finally {
			setBusy(null)
		}
	}

	return {
		data,
		isLoading,
		loading: isLoading,
		error,
		hasError: error !== null,
		notice,
		busy,
		refresh,
		runAction,
	}
}
