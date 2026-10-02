import { useEffect } from 'react'
import { seoLinks, seoMeta } from '../utils/seo'

type UseSeoOptions = {
	title?: string
	description?: string
	path?: string
	image?: string
	type?: 'website' | 'article' | 'product'
	noIndex?: boolean
	jsonLd?: object | object[]
}

const MANAGED_ATTR = 'data-seo-managed'

function upsertMetaTag(selector: string, create: () => HTMLMetaElement) {
	const existing = document.head.querySelector<HTMLMetaElement>(selector)
	const el = existing ?? create()
	el.setAttribute(MANAGED_ATTR, 'true')
	if (!existing) document.head.appendChild(el)
	return el
}

/** Applies SEO meta/link/JSON-LD tags to document.head for this SPA route; cleans up on unmount. */
export function useSeo(options: UseSeoOptions = {}) {
	const { path, jsonLd } = options
	const jsonLdContent = jsonLd ? JSON.stringify(jsonLd) : null

	useEffect(() => {
		const previousTitle = document.title
		const tags = seoMeta(options)
		const links = seoLinks(path)

		tags.forEach((tag) => {
			if ('title' in tag) {
				document.title = tag.title
				return
			}
			const key = 'name' in tag ? 'name' : 'property'
			const value = 'name' in tag ? tag.name : tag.property
			upsertMetaTag(`meta[${key}="${value}"]`, () => {
				const el = document.createElement('meta')
				el.setAttribute(key, value)
				return el
			}).setAttribute('content', tag.content)
		})

		links.forEach((link) => {
			const el = document.head.querySelector<HTMLLinkElement>(`link[rel="${link.rel}"][${MANAGED_ATTR}]`)
				?? document.createElement('link')
			el.setAttribute('rel', link.rel)
			el.setAttribute('href', link.href)
			el.setAttribute(MANAGED_ATTR, 'true')
			if (!el.parentNode) document.head.appendChild(el)
		})

		let jsonLdScript: HTMLScriptElement | null = null
		if (jsonLdContent) {
			jsonLdScript = document.createElement('script')
			jsonLdScript.type = 'application/ld+json'
			jsonLdScript.setAttribute(MANAGED_ATTR, 'true')
			jsonLdScript.textContent = jsonLdContent
			document.head.appendChild(jsonLdScript)
		}

		return () => {
			document.title = previousTitle
			jsonLdScript?.remove()
		}
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [options.title, options.description, path, options.image, options.type, options.noIndex, jsonLdContent])
}
