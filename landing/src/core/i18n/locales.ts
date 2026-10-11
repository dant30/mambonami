import en from '../locale/en.json'
import sw from '../locale/sw.json'

export const locales = { en, sw } as const

export type Locale = keyof typeof locales
export type TranslationTree = { [key: string]: string | TranslationTree }

type StringKey<T> = {
	[K in keyof T & string]: T[K] extends string ? K : T[K] extends Record<string, unknown> ? `${K}.${StringKey<T[K]>}` : never
}[keyof T & string]

export type TranslationKey = StringKey<typeof en>

export const localeOptions: ReadonlyArray<{ code: Locale; label: string; nativeLabel: string }> = [
	{ code: 'en', label: 'English', nativeLabel: 'English' },
	{ code: 'sw', label: 'Swahili', nativeLabel: 'Kiswahili' },
]

export function isLocale(value: unknown): value is Locale {
	return typeof value === 'string' && Object.hasOwn(locales, value)
}
