import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'

import { localStorageStore } from '../storage'

export type Theme = 'light' | 'dark' | 'system'

interface ThemeContextValue {
	theme: Theme
	resolvedTheme: 'light' | 'dark'
	setTheme(theme: Theme): void
}

const ThemeContext = createContext<ThemeContextValue | undefined>(undefined)

function getSystemTheme(): 'light' | 'dark' {
	return typeof window !== 'undefined' && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
}

export function ThemeProvider({ children }: { children: ReactNode }) {
	const [theme, setTheme] = useState<Theme>(() => localStorageStore.get<Theme>('theme') ?? 'system')
	const [resolvedTheme, setResolvedTheme] = useState<'light' | 'dark'>(() => theme === 'system' ? getSystemTheme() : theme)

	useEffect(() => {
		const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
		const updateTheme = () => setResolvedTheme(theme === 'system' ? (mediaQuery.matches ? 'dark' : 'light') : theme)
		updateTheme()
		if (theme === 'system') mediaQuery.addEventListener('change', updateTheme)
		return () => mediaQuery.removeEventListener('change', updateTheme)
	}, [theme])

	useEffect(() => {
		document.documentElement.classList.toggle('dark', resolvedTheme === 'dark')
		localStorageStore.set('theme', theme)
	}, [resolvedTheme, theme])

	return <ThemeContext.Provider value={{ theme, resolvedTheme, setTheme }}>{children}</ThemeContext.Provider>
}

export function useTheme() {
	const context = useContext(ThemeContext)
	if (!context) throw new Error('useTheme must be used inside ThemeProvider')
	return context
}
