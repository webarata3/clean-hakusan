// キャッシュファイルの指定
const CACHE_NAME = 'cache-20230318-01';
const cacheWhitelist = ['cache-20230318-01'];
const urlsToCache = [
  '/',
  '/static/css/main.99cb5867.css',
  '/static/css/main.99cb5867.css.map',
  '/static/js/787.d3befce1.chunk.js',
  '/static/js/787.d3befce1.chunk.js.map',
  '/static/js/main.9db2c9c6.js',
  '/static/js/main.9db2c9c6.js.LICENSE.txt',
  '/static/js/main.9db2c9c6.js.map',
  '/static/media/bars.c7c76bb26f2789cc8c55c9714f901716.svg',
  '/static/media/KosugiMaru-Regular.60613d8076cd8d332ee3.ttf',
  '/static/media/rotate-right.aeb4284ed32e4ac1412774228e44f558.svg',
  '/static/media/twitter.bf36f3f69522a27a80a43488f00cffa0.svg',
  '/static/media/xmark.60382e088b541402b90bf47cb2f3b5df.svg',
  '/index.html'
];

self.addEventListener('install', event => {
  // Perform install steps
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(response => {
      // Cache hit - return response
      if (response) {
        return response;
      }
      return fetch(event.request);
    })
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames =>
      Promise.all(
        cacheNames.map(cacheName => {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      )
    )
  );
});
