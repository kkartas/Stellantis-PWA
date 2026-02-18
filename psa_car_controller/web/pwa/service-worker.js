const SHELL_CACHE = "psacc-shell-v4";
const API_CACHE = "psacc-api-v4";

const SHELL_FILES = [
  "./",
  "./offline.html",
  "./manifest.webmanifest",
  "./assets/pwa/styles.css",
  "./assets/pwa/app.js",
  "./assets/pwa/icons/icon-192.svg",
  "./assets/pwa/icons/icon-512.svg",
  "./assets/pwa/brands/stellantis.svg",
  "./assets/pwa/brands/peugeot.svg",
  "./assets/pwa/brands/citroen.svg",
  "./assets/pwa/brands/opel.svg",
  "./assets/pwa/brands/ds.svg",
  "./assets/pwa/brands/vauxhall.svg",
  "./assets/pwa/brands/fiat.svg",
  "./assets/pwa/brands/jeep.svg",
  "./assets/pwa/brands/alfaromeo.svg"
];

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(SHELL_CACHE).then((cache) => cache.addAll(SHELL_FILES)));
  self.skipWaiting();
});

self.addEventListener("message", (event) => {
  if (event.data && event.data.type === "SKIP_WAITING") {
    self.skipWaiting();
  }
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => ![SHELL_CACHE, API_CACHE].includes(key))
          .map((key) => caches.delete(key))
      )
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") {
    return;
  }

  const requestUrl = new URL(event.request.url);
  const isApi = requestUrl.pathname.includes("/api/");

  if (event.request.mode === "navigate") {
    event.respondWith(
      fetch(event.request).catch(() => caches.match("./offline.html"))
    );
    return;
  }

  if (isApi) {
    event.respondWith(networkFirst(event.request, API_CACHE));
    return;
  }

  event.respondWith(staleWhileRevalidate(event, SHELL_CACHE));
});

async function networkFirst(request, cacheName) {
  const cache = await caches.open(cacheName);
  try {
    const response = await fetch(request);
    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  } catch (_error) {
    const cached = await cache.match(request);
    if (cached) {
      return cached;
    }
    throw _error;
  }
}

async function staleWhileRevalidate(event, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(event.request);
  const networkFetch = fetch(event.request)
    .then((response) => {
      if (response && response.ok) {
        cache.put(event.request, response.clone());
      }
      return response;
    })
    .catch(() => null);

  if (cached) {
    event.waitUntil(networkFetch);
    return cached;
  }

  const response = await networkFetch;
  if (response) {
    return response;
  }

  return new Response("", { status: 504, statusText: "Offline" });
}
