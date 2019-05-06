// キャッシュファイルの指定
const CACHE_NAME = 'cache-20190506-02';
const cacheWhitelist = ['cache-20190506-02'];
const urlsToCache = [
  '/css/font.css',
  '/css/main.css',
  '/css/reset.css',
  '/font/FiraSans-Light.ttf',
  '/font/FiraSans-Regular.ttf',
  '/font/FiraSans.woff2',
  '/font/Inconsolata-Bold.ttf',
  '/font/Inconsolata-Regular.ttf',
  '/font/Inconsolata.woff2',
  '/js/init.js',
  '/js/main.js',
  '/js/util.js',
  '/webfonts/fa-brands-400.eot',
  '/webfonts/fa-brands-400.svg',
  '/webfonts/fa-brands-400.ttf',
  '/webfonts/fa-brands-400.woff',
  '/webfonts/fa-brands-400.woff2',
  '/webfonts/fa-regular-400.eot',
  '/webfonts/fa-regular-400.svg',
  '/webfonts/fa-regular-400.ttf',
  '/webfonts/fa-regular-400.woff',
  '/webfonts/fa-regular-400.woff2',
  '/webfonts/fa-solid-900.eot',
  '/webfonts/fa-solid-900.svg',
  '/webfonts/fa-solid-900.ttf',
  '/webfonts/fa-solid-900.woff',
  '/webfonts/fa-solid-900.woff2',
  '/404.html',
  '/index.html'
];


self.addEventListener('install', function (event) {
  // Perform install steps
  event.waitUntil(
    caches.open(CACHE_NAME).then(function (cache) {
      return cache.addAll(urlsToCache);
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        // Cache hit - return response
        if (response) {
          return response;
        }
        return fetch(event.request);
      }
      )
  );
});

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheNames) {
      return Promise.all(
        cacheNames.map(function (cacheName) {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
