import { useSyncExternalStore } from 'react'

import { localStorageStore } from '../storage'
import { isLocale, locales } from './locales'
import type { Locale, TranslationKey } from './locales'

const LOCALE_STORAGE_KEY = 'mambonami_locale'
const DEFAULT_LOCALE: Locale = 'en'
type InterpolationValues = Record<string, string | number>
type Listener = () => void

const listeners = new Set<Listener>()
const storedLocale = localStorageStore.get<unknown>(LOCALE_STORAGE_KEY)
let activeLocale: Locale = isLocale(storedLocale) ? storedLocale : DEFAULT_LOCALE

if (typeof document !== 'undefined') document.documentElement.lang = activeLocale

function subscribe(listener: Listener) {
	listeners.add(listener)
	return () => listeners.delete(listener)
}

function getLocaleSnapshot(): Locale {
	return activeLocale
}

function readMessage(locale: Locale, key: string): string | undefined {
	let value: unknown = locales[locale]
	for (const segment of key.split('.')) {
		if (!value || typeof value !== 'object' || !(segment in value)) return undefined
		value = (value as Record<string, unknown>)[segment]
	}
	return typeof value === 'string' ? value : undefined
}

export function setLocale(locale: Locale): void {
	if (!isLocale(locale) || locale === activeLocale) return
	activeLocale = locale
	localStorageStore.set(LOCALE_STORAGE_KEY, locale)
	if (typeof document !== 'undefined') document.documentElement.lang = locale
	listeners.forEach((listener) => listener())
}

export function getLocale(): Locale {
	return activeLocale
}

export function translate(key: TranslationKey, values: InterpolationValues = {}): string {
	const message = readMessage(activeLocale, key) ?? readMessage(DEFAULT_LOCALE, key) ?? key
	return message.replace(/{{\s*([\w.-]+)\s*}}/g, (placeholder, name: string) => {
		return Object.hasOwn(values, name) ? String(values[name]) : placeholder
	})
}

export function useTranslation() {
	const locale = useSyncExternalStore(subscribe, getLocaleSnapshot, () => DEFAULT_LOCALE)
	return { locale, t: translate, setLocale }
}
