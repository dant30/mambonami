const CACHE_NAME = 'mambonami-cache-v2'; // bump version on changes
const OFFLINE_PAGE = '/offline.html';

// Static assets to cache on install (pre-cache)
const STATIC_ASSETS = [
  OFFLINE_PAGE,
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/logo192.png',
  '/icons/logo512.png',
];

// Install event – pre-cache static assets
self.addEventListener('install', (event) => {
  console.log('[SW] Installing service worker');
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS);
    })
  );
  // Force waiting service worker to become active
  self.skipWaiting();
});

// Activate event – clean up old caches
self.addEventListener('activate', (event) => {
  console.log('[SW] Activating service worker');
  event.waitUntil(
    caches.keys().then((keyList) => {
      return Promise.all(
        keyList.map((key) => {
          if (key !== CACHE_NAME) {
            console.log('[SW] Deleting old cache:', key);
            return caches.delete(key);
          }
        })
      );
    })
  );
  // Take control of all clients immediately
  self.clients.claim();
});

// Fetch event – network-first for APIs, cache-first for static assets
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  const isApiRequest = url.pathname.startsWith('/api/');
  const isStaticAsset = /\.(js|css|png|jpg|jpeg|svg|woff2|ico|json)$/.test(url.pathname);
  const isHtml = event.request.mode === 'navigate';

  // For HTML navigation: network-first, fallback to offline page
  if (isHtml) {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          // Cache the fresh HTML for offline use
          const copy = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
          return response;
        })
        .catch(() => caches.match(event.request).then((cached) => cached || caches.match(OFFLINE_PAGE)))
    );
    return;
  }

  // For API requests: network-first, no caching (or stale-while-revalidate)
  if (isApiRequest) {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          // Optionally cache API responses for offline? Better not for financial data.
          return response;
        })
        .catch(() => {
          // Return offline friendly error (JSON)
          return new Response(
            JSON.stringify({ error: 'You are offline. Please check your connection.' }),
            { status: 503, headers: { 'Content-Type': 'application/json' } }
          );
        })
    );
    return;
  }

  // For static assets: cache-first (fastest)
  if (isStaticAsset) {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        if (cached) {
          return cached;
        }
        return fetch(event.request).then((response) => {
          const copy = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
          return response;
        });
      })
    );
    return;
  }

  // Default: network-first fallback to cache (for other resources)
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        const copy = response.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});