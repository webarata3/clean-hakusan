// キャッシュファイルの指定
const CACHE_NAME = 'cache-20190627-03';
const cacheWhitelist = ['cache-20190627-03'];
const urlsToCache = [
  '/api/01.json',
  '/api/02.json',
  '/api/03.json',
  '/api/04.json',
  '/api/05.json',
  '/api/06.json',
  '/api/07.json',
  '/api/08.json',
  '/api/09.json',
  '/api/10.json',
  '/api/11.json',
  '/api/12.json',
  '/api/13.json',
  '/api/14.json',
  '/api/15.json',
  '/api/16.json',
  '/api/17.json',
  '/api/18.json',
  '/api/19.json',
  '/api/20.json',
  '/api/21.json',
  '/api/22.json',
  '/api/23.json',
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
  '/webfont/fa-brands-400.eot',
  '/webfont/fa-brands-400.svg',
  '/webfont/fa-brands-400.ttf',
  '/webfont/fa-brands-400.woff',
  '/webfont/fa-brands-400.woff2',
  '/webfont/fa-regular-400.eot',
  '/webfont/fa-regular-400.svg',
  '/webfont/fa-regular-400.ttf',
  '/webfont/fa-regular-400.woff',
  '/webfont/fa-regular-400.woff2',
  '/webfont/fa-solid-900.eot',
  '/webfont/fa-solid-900.svg',
  '/webfont/fa-solid-900.ttf',
  '/webfont/fa-solid-900.woff',
  '/webfont/fa-solid-900.woff2',
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
