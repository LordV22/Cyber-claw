const CACHE_NAME = 'cyberclawai-v1';
const ASSETS_TO_CACHE = ['/', '/index.html'];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(ASSETS_TO_CACHE)));
  self.skipWaiting();
});

self.addEventListener('activate', (e) => {
  e.waitUntil(caches.keys().then(nomes => nomes.filter(n => n !== CACHE_NAME).map(n => caches.delete(n))));
  self.clients.claim();
});

self.addEventListener('fetch', (e) => {
  e.respondWith(caches.match(e.request).then(resposta => resposta || fetch(e.request)));
});
