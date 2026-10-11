const CACHE_PREFIX = 'mambonami-pwa-'
const CACHE_VERSION = 'v1'
const SHELL_CACHE = `${CACHE_PREFIX}shell-${CACHE_VERSION}`
const ASSET_CACHE = `${CACHE_PREFIX}assets-${CACHE_VERSION}`
const APP_SHELL_URL = '/index.html'
const OFFLINE_URL = '/offline.html'
const PRECACHE_URLS = [APP_SHELL_URL, OFFLINE_URL, '/unauthorized.html', '/manifest.json', '/assets/icons/logo.png', '/assets/icons/favicon.ico']

self.addEventListener('install', (event) => {
	event.waitUntil(
		caches.open(SHELL_CACHE)
			.then((cache) => cache.addAll(PRECACHE_URLS))
			.then(() => self.skipWaiting()),
	)
})

self.addEventListener('activate', (event) => {
	event.waitUntil(
		caches.keys()
			.then((keys) => Promise.all(keys.filter((key) => key.startsWith(CACHE_PREFIX) && ![SHELL_CACHE, ASSET_CACHE].includes(key)).map((key) => caches.delete(key))))
			.then(() => self.clients.claim()),
	)
})

self.addEventListener('fetch', (event) => {
	const request = event.request
	if (request.method !== 'GET') return

	const url = new URL(request.url)
	if (
		url.origin !== self.location.origin ||
		url.pathname === '/api' || url.pathname.startsWith('/api/') ||
		url.pathname === '/admin-api' || url.pathname.startsWith('/admin-api/')
	) return

	if (request.mode === 'navigate') {
		event.respondWith(
			fetch(request).catch(async () => {
				const offlinePage = await caches.match(OFFLINE_URL)
				return offlinePage || Response.error()
			}),
		)
		return
	}

	const isStaticAsset = /\.(?:css|gif|ico|jpeg|jpg|js|png|svg|webp|woff2?)$/i.test(url.pathname)
	if (!isStaticAsset) return

	event.respondWith(
		caches.open(ASSET_CACHE).then(async (cache) => {
			try {
				const response = await fetch(request)
				if (response.ok && response.type === 'basic') await cache.put(request, response.clone())
				return response
			} catch {
				const cached = await cache.match(request)
				return cached || Response.error()
			}
		}),
	)
})
