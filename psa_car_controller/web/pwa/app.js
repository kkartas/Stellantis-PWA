const state = {
  vehicles: [],
  selectedVin: null,
  deferredPrompt: null,
  refreshTimer: null,
  lastAuthError: null,
  lastRemoteAuthError: null,
  isAuthenticated: false,
  isElectricVehicle: true,
  remoteControlReady: false,
  tripsRaw: [],
  tripsFiltered: [],
  tripMaps: new Map(),
  tripPathCache: new Map(),
  tripPathRequests: new Map(),
  overviewMap: null,
  overviewMapMarker: null,
  busyButtons: new WeakSet(),
};

const refs = {
  connectionState: document.getElementById("connection-state"),
  vehicleSelect: document.getElementById("vehicle-select"),
  refreshButton: document.getElementById("refresh-btn"),
  installButton: document.getElementById("install-btn"),
  toast: document.getElementById("toast"),
  tabs: Array.from(document.querySelectorAll(".tab")),
  panels: Array.from(document.querySelectorAll(".tab-panel")),
  overviewPositionMap: document.getElementById("overview-position-map"),
  overviewPositionEmpty: document.getElementById("overview-position-empty"),
  tripsBody: document.getElementById("trips-body"),
  chargingBody: document.getElementById("charging-body"),
  oauthMessage: document.getElementById("oauth-message"),
  oauthUrl: document.getElementById("oauth-url"),
  setupLoginCard: document.getElementById("setup-login-card"),
  setupOtpCard: document.getElementById("setup-otp-card"),
  brandChip: document.getElementById("brand-chip"),
  brandLogo: document.getElementById("brand-logo"),
  brandName: document.getElementById("brand-name"),
  vehiclePhoto: document.getElementById("vehicle-photo"),
  vehiclePhotoFallback: document.getElementById("vehicle-photo-fallback"),
  vehicleName: document.getElementById("vehicle-name"),
  vehicleVin: document.getElementById("vehicle-vin"),
  tripsFuelHeader: document.getElementById("trips-fuel-header"),
  summaryConsumptionLabel: document.getElementById("summary-consumption-label"),
  tripFiltersForm: document.getElementById("trip-filters-form"),
  tripFilterFrom: document.getElementById("trip-filter-from"),
  tripFilterTo: document.getElementById("trip-filter-to"),
  tripFilterMinDistance: document.getElementById("trip-filter-min-distance"),
  tripFilterMaxDistance: document.getElementById("trip-filter-max-distance"),
  tripFilterSort: document.getElementById("trip-filter-sort"),
  tripFiltersReset: document.getElementById("trip-filters-reset"),
  tripFilterSummary: document.getElementById("trip-filter-summary"),
  tripStatCount: document.getElementById("trip-stat-count"),
  tripStatDistance: document.getElementById("trip-stat-distance"),
  tripStatDuration: document.getElementById("trip-stat-duration"),
  tripStatSpeed: document.getElementById("trip-stat-speed"),
  tripStatLongest: document.getElementById("trip-stat-longest"),
  tripStatConsumption: document.getElementById("trip-stat-consumption"),
  tripStatConsumptionLabel: document.getElementById("trip-stat-consumption-label"),
  liveSignals: document.getElementById("live-signals"),
};

function showToast(message, type = "ok") {
  refs.toast.textContent = message;
  refs.toast.classList.remove("ok", "bad");
  refs.toast.classList.add(type === "bad" ? "bad" : "ok", "show");
  window.clearTimeout(showToast.timer);
  showToast.timer = window.setTimeout(() => refs.toast.classList.remove("show"), 2800);
}

function setConnectionState(text, healthy) {
  refs.connectionState.textContent = text;
  refs.connectionState.classList.remove("ok", "bad");
  refs.connectionState.classList.add(healthy ? "ok" : "bad");
}

function resolveSubmitButton(event) {
  if (event && event.submitter) {
    return event.submitter;
  }
  const form = event && event.currentTarget;
  if (!form) {
    return null;
  }
  return form.querySelector("button[type='submit']");
}

async function withBusyButton(button, loadingText, operation) {
  if (!button) {
    return operation();
  }
  if (state.busyButtons.has(button)) {
    return undefined;
  }

  state.busyButtons.add(button);
  const originalText = button.textContent;
  button.disabled = true;
  button.classList.add("is-loading");
  button.setAttribute("aria-busy", "true");
  if (loadingText) {
    button.textContent = loadingText;
  }

  try {
    return await operation();
  } finally {
    button.disabled = false;
    button.classList.remove("is-loading");
    button.removeAttribute("aria-busy");
    button.textContent = originalText;
    state.busyButtons.delete(button);
  }
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function fmtNumber(value, digits = 1, suffix = "") {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "-";
  }
  return `${Number(value).toFixed(digits)}${suffix}`;
}

function fmtDate(value) {
  if (!value) {
    return "-";
  }
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return String(value);
  }
  const day = String(parsed.getDate()).padStart(2, "0");
  const month = String(parsed.getMonth() + 1).padStart(2, "0");
  const year = parsed.getFullYear();
  const hour = String(parsed.getHours()).padStart(2, "0");
  const minute = String(parsed.getMinutes()).padStart(2, "0");
  return `${day}/${month}/${year} ${hour}:${minute}`;
}

function average(values) {
  const valid = values.filter((value) => Number.isFinite(value));
  if (valid.length === 0) {
    return null;
  }
  return valid.reduce((sum, value) => sum + value, 0) / valid.length;
}

function toFiniteNumber(value) {
  if (value === null || value === undefined) {
    return null;
  }
  if (typeof value === "string" && value.trim() === "") {
    return null;
  }
  const numberValue = Number(value);
  if (!Number.isFinite(numberValue)) {
    return null;
  }
  return numberValue;
}

function getTripFuelMetrics(trip) {
  const distance = toFiniteNumber(trip && trip.distance);
  const durationMinutes = toFiniteNumber(trip && trip.duration);
  const litersPer100Km = toFiniteNumber(trip && trip.consumption_fuel_km);

  const hasValidBase =
    Number.isFinite(distance) &&
    distance > 0 &&
    Number.isFinite(durationMinutes) &&
    durationMinutes > 0 &&
    Number.isFinite(litersPer100Km) &&
    litersPer100Km > 0;

  if (!hasValidBase) {
    return {
      liters: 0,
      distance: 0,
      includeInAverage: false,
    };
  }

  const directFuelValue = toFiniteNumber(trip && trip.consumption_fuel);
  const liters =
    Number.isFinite(directFuelValue) && directFuelValue > 0
      ? directFuelValue
      : (litersPer100Km * distance) / 100;

  if (!Number.isFinite(liters) || liters <= 0) {
    return {
      liters: 0,
      distance: 0,
      includeInAverage: false,
    };
  }

  return {
    liters,
    distance,
    includeInAverage: true,
  };
}

function getTripFuelConsumedLiters(trip) {
  return getTripFuelMetrics(trip).liters;
}

function fuelConsumptionPer100Km(trips) {
  const totals = (Array.isArray(trips) ? trips : []).reduce(
    (aggregate, trip) => {
      const metrics = getTripFuelMetrics(trip);
      if (!metrics.includeInAverage) {
        return aggregate;
      }
      aggregate.distance += metrics.distance;
      aggregate.fuel += metrics.liters;
      return aggregate;
    },
    { distance: 0, fuel: 0 },
  );

  if (totals.distance <= 0) {
    return null;
  }
  return (totals.fuel / totals.distance) * 100;
}

function normalizeTripPoint(point) {
  if (!point || typeof point !== "object") {
    return null;
  }
  const latitude = toFiniteNumber(point.latitude ?? point.lat);
  const longitude = toFiniteNumber(point.longitude ?? point.lng ?? point.lon);
  if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
    return null;
  }
  const fallbackUrl = `https://www.openstreetmap.org/?mlat=${latitude}&mlon=${longitude}#map=16/${latitude}/${longitude}`;
  return {
    latitude,
    longitude,
    mapUrl: point.openstreetmap_url || point.google_maps_url || fallbackUrl,
  };
}

function tripPointFromLegacyPositions(trip, index) {
  const positions = trip && typeof trip === "object" ? trip.positions : null;
  if (!positions || typeof positions !== "object") {
    return null;
  }
  const latitudes = Array.isArray(positions.lat) ? positions.lat : [];
  const longitudes = Array.isArray(positions.long) ? positions.long : [];
  if (latitudes.length === 0 || longitudes.length === 0) {
    return null;
  }
  const safeIndex = index < 0 ? latitudes.length - 1 : index;
  if (safeIndex < 0 || safeIndex >= latitudes.length || safeIndex >= longitudes.length) {
    return null;
  }
  return normalizeTripPoint({
    latitude: latitudes[safeIndex],
    longitude: longitudes[safeIndex],
  });
}

function getTripStartPoint(trip) {
  return normalizeTripPoint(trip.start_position) || tripPointFromLegacyPositions(trip, 0);
}

function getTripEndPoint(trip) {
  return normalizeTripPoint(trip.end_position) || tripPointFromLegacyPositions(trip, -1);
}

function tripPrimaryDate(trip) {
  return new Date(trip.start_at || trip.end_at || 0);
}

function tripTimestamp(trip) {
  const date = tripPrimaryDate(trip);
  const time = date.getTime();
  return Number.isFinite(time) ? time : 0;
}

function tripPointCoordinateLabel(point) {
  return `${point.latitude.toFixed(5)}, ${point.longitude.toFixed(5)}`;
}

function tripColumnCount() {
  return state.isElectricVehicle ? 7 : 6;
}

function tripMapContainerId(tripIndex) {
  return `trip-map-${tripIndex}`;
}

function tripPathCacheKey(vin, tripId) {
  if (!vin || !tripId) {
    return null;
  }
  return `${vin}:${tripId}`;
}

function tripPathPointsFromPositions(positions) {
  if (!positions || typeof positions !== "object") {
    return [];
  }
  const latitudes = Array.isArray(positions.lat) ? positions.lat : [];
  const longitudes = Array.isArray(positions.long) ? positions.long : [];
  const pointCount = Math.min(latitudes.length, longitudes.length);
  const points = [];
  for (let index = 0; index < pointCount; index += 1) {
    const normalized = normalizeTripPoint({
      latitude: latitudes[index],
      longitude: longitudes[index],
    });
    if (normalized) {
      points.push(normalized);
    }
  }
  return points;
}

function compactTripPath(points) {
  if (!Array.isArray(points) || points.length === 0) {
    return [];
  }
  const compacted = [];
  points.forEach((point) => {
    if (!point) {
      return;
    }
    const normalized = normalizeTripPoint(point);
    if (!normalized) {
      return;
    }
    const previous = compacted[compacted.length - 1];
    if (previous && previous.latitude === normalized.latitude && previous.longitude === normalized.longitude) {
      return;
    }
    compacted.push(normalized);
  });
  return compacted;
}

function downsampleTripPath(points, maxPoints = 320) {
  if (!Array.isArray(points) || points.length <= maxPoints) {
    return points;
  }
  const result = [];
  const step = (points.length - 1) / (maxPoints - 1);
  for (let index = 0; index < maxPoints; index += 1) {
    const sourceIndex = Math.round(index * step);
    const point = points[sourceIndex];
    if (!point) {
      continue;
    }
    result.push(point);
  }
  return compactTripPath(result);
}

async function fetchTripPath(trip) {
  const tripId = trip && trip.id ? String(trip.id) : "";
  const vin = trip && trip.vin ? String(trip.vin) : state.selectedVin;
  const cacheKey = tripPathCacheKey(vin, tripId);
  if (!cacheKey) {
    return null;
  }
  if (state.tripPathCache.has(cacheKey)) {
    return state.tripPathCache.get(cacheKey);
  }
  if (state.tripPathRequests.has(cacheKey)) {
    return state.tripPathRequests.get(cacheKey);
  }

  const requestPromise = apiRequest(`api/trips/${encodeURIComponent(vin)}/${encodeURIComponent(tripId)}/path`)
    .then((payload) => {
      const normalizedPoints = compactTripPath(Array.isArray(payload.points) ? payload.points : []);
      const normalizedPayload = {
        ...payload,
        points: normalizedPoints,
        start_position: normalizeTripPoint(payload.start_position) || normalizedPoints[0] || null,
        end_position: normalizeTripPoint(payload.end_position) || normalizedPoints[normalizedPoints.length - 1] || null,
      };
      state.tripPathCache.set(cacheKey, normalizedPayload);
      return normalizedPayload;
    })
    .finally(() => {
      state.tripPathRequests.delete(cacheKey);
    });

  state.tripPathRequests.set(cacheKey, requestPromise);
  return requestPromise;
}

function destroyTripMaps() {
  state.tripMaps.forEach((mapInstance) => {
    try {
      mapInstance.remove();
    } catch (_error) {
      // Ignore map disposal errors.
    }
  });
  state.tripMaps.clear();
}

function setTripDetailExpanded(tripIndex, expanded) {
  const summaryRow = refs.tripsBody.querySelector(`.trip-summary-row[data-trip-index="${tripIndex}"]`);
  const detailRow = refs.tripsBody.querySelector(`.trip-detail-row[data-trip-index="${tripIndex}"]`);
  if (!summaryRow || !detailRow) {
    return;
  }

  summaryRow.classList.toggle("is-open", expanded);
  summaryRow.setAttribute("aria-expanded", expanded ? "true" : "false");
  detailRow.classList.toggle("hidden", !expanded);

  const icon = summaryRow.querySelector(".trip-expand-icon");
  if (icon) {
    icon.textContent = expanded ? "v" : ">";
  }
}

function collapseTripDetails(exceptIndex = null) {
  refs.tripsBody.querySelectorAll(".trip-summary-row").forEach((summaryRow) => {
    const rowIndex = Number(summaryRow.dataset.tripIndex);
    if (!Number.isFinite(rowIndex) || rowIndex === exceptIndex) {
      return;
    }
    setTripDetailExpanded(rowIndex, false);
  });
}

async function renderTripMap(trip, tripIndex) {
  const mapId = tripMapContainerId(tripIndex);
  if (state.tripMaps.has(mapId)) {
    const existingMap = state.tripMaps.get(mapId);
    window.setTimeout(() => existingMap.invalidateSize(), 0);
    return;
  }

  const mapContainer = document.getElementById(mapId);
  if (!mapContainer) {
    return;
  }
  if (!window.L) {
    mapContainer.innerHTML = '<p class="trip-map-empty">Map library not available.</p>';
    return;
  }

  mapContainer.innerHTML = '<p class="trip-map-empty">Loading trip map...</p>';

  let pathPoints = compactTripPath(tripPathPointsFromPositions(trip && trip.positions));
  let startPoint = getTripStartPoint(trip);
  let endPoint = getTripEndPoint(trip);

  const canFetchPath = Boolean(trip && trip.id && (trip.vin || state.selectedVin));
  const shouldFetchPath = canFetchPath && pathPoints.length < 3;
  if (shouldFetchPath) {
    try {
      const remotePath = await fetchTripPath(trip);
      if (remotePath) {
        if (Array.isArray(remotePath.points) && remotePath.points.length > 0) {
          pathPoints = compactTripPath(remotePath.points);
        }
        startPoint = normalizeTripPoint(remotePath.start_position) || startPoint;
        endPoint = normalizeTripPoint(remotePath.end_position) || endPoint;
      }
    } catch (error) {
      if (!(pathPoints.length > 0 || startPoint || endPoint)) {
        mapContainer.innerHTML = `<p class="trip-map-empty">${escapeHtml(error.message || "Trip path unavailable")}</p>`;
        return;
      }
    }
  }

  const hasPath = pathPoints.length >= 2;
  if (!startPoint && pathPoints.length > 0) {
    startPoint = pathPoints[0];
  }
  if (!endPoint && pathPoints.length > 0) {
    endPoint = pathPoints[pathPoints.length - 1];
  }

  if (!startPoint && !endPoint && !hasPath) {
    mapContainer.innerHTML = '<p class="trip-map-empty">No map coordinates available for this trip.</p>';
    return;
  }

  mapContainer.innerHTML = "";
  const mapInstance = window.L.map(mapContainer, { zoomControl: true });
  window.L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 19,
  }).addTo(mapInstance);

  const bounds = [];
  if (hasPath) {
    const sampledPath = downsampleTripPath(pathPoints);
    const latLngs = sampledPath.map((point) => [point.latitude, point.longitude]);
    window.L.polyline(latLngs, {
      color: "#60a5fa",
      weight: 4,
      opacity: 0.92,
      lineJoin: "round",
    }).addTo(mapInstance);
    latLngs.forEach((latLng) => bounds.push(latLng));
  }

  if (startPoint) {
    const startLatLng = [startPoint.latitude, startPoint.longitude];
    window.L.circleMarker(startLatLng, {
      radius: 8,
      color: "#14532d",
      weight: 2,
      fillColor: "#22c55e",
      fillOpacity: 0.95,
    }).bindTooltip("Start").addTo(mapInstance);
    bounds.push(startLatLng);
  }

  if (endPoint) {
    const endLatLng = [endPoint.latitude, endPoint.longitude];
    window.L.circleMarker(endLatLng, {
      radius: 8,
      color: "#7f1d1d",
      weight: 2,
      fillColor: "#ef4444",
      fillOpacity: 0.95,
    }).bindTooltip("End").addTo(mapInstance);
    bounds.push(endLatLng);
  }

  if (bounds.length === 1) {
    mapInstance.setView(bounds[0], 14);
  } else {
    mapInstance.fitBounds(bounds, { padding: [28, 28] });
  }

  state.tripMaps.set(mapId, mapInstance);
  window.setTimeout(() => mapInstance.invalidateSize(), 80);
}

async function toggleTripDetail(tripIndex, trips) {
  const summaryRow = refs.tripsBody.querySelector(`.trip-summary-row[data-trip-index="${tripIndex}"]`);
  if (!summaryRow) {
    return;
  }
  const isOpen = summaryRow.classList.contains("is-open");
  collapseTripDetails(isOpen ? null : tripIndex);
  setTripDetailExpanded(tripIndex, !isOpen);
  if (!isOpen && trips[tripIndex]) {
    await renderTripMap(trips[tripIndex], tripIndex);
  }
}

function wireTripRows(trips) {
  refs.tripsBody.querySelectorAll(".trip-summary-row").forEach((summaryRow) => {
    summaryRow.addEventListener("click", async () => {
      const tripIndex = Number(summaryRow.dataset.tripIndex);
      if (!Number.isFinite(tripIndex)) {
        return;
      }
      try {
        await toggleTripDetail(tripIndex, trips);
      } catch (error) {
        showToast(error.message || "Unable to load trip map", "bad");
      }
    });
  });
}

function tripDetailActions(startPoint, endPoint) {
  const actions = [];
  if (startPoint) {
    actions.push(
      `<a class="button secondary" href="${escapeHtml(startPoint.mapUrl)}" target="_blank" rel="noopener noreferrer">Open Start in OSM</a>`,
    );
  }
  if (endPoint) {
    actions.push(
      `<a class="button secondary" href="${escapeHtml(endPoint.mapUrl)}" target="_blank" rel="noopener noreferrer">Open End in OSM</a>`,
    );
  }
  if (actions.length === 0) {
    return "";
  }
  return `<div class="trip-detail-actions">${actions.join("")}</div>`;
}

function dateAtStartOfDay(value) {
  if (!value) {
    return null;
  }
  const date = new Date(`${value}T00:00:00`);
  const timestamp = date.getTime();
  if (!Number.isFinite(timestamp)) {
    return null;
  }
  return timestamp;
}

function dateAtEndOfDay(value) {
  if (!value) {
    return null;
  }
  const date = new Date(`${value}T23:59:59.999`);
  const timestamp = date.getTime();
  if (!Number.isFinite(timestamp)) {
    return null;
  }
  return timestamp;
}

async function apiRequest(path, options = {}) {
  const requestOptions = {
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    ...options,
  };

  const response = await fetch(path, requestOptions);
  const text = await response.text();
  let payload = {};
  if (text) {
    try {
      payload = JSON.parse(text);
    } catch (_error) {
      payload = { error: text };
    }
  }

  if (!response.ok) {
    throw new Error(payload.error || payload.message || `${response.status} ${response.statusText}`);
  }
  return payload;
}

function post(path, body = {}) {
  return apiRequest(path, {
    method: "POST",
    body: JSON.stringify(body),
  });
}

function getSelectedVin() {
  const vin = refs.vehicleSelect.value || state.selectedVin;
  if (!vin) {
    throw new Error("Select a vehicle first");
  }
  return vin;
}

function getSelectedVehicle() {
  if (!state.selectedVin) {
    return null;
  }
  return state.vehicles.find((vehicle) => vehicle.vin === state.selectedVin) || null;
}

function renderOverviewPosition(position) {
  if (!refs.overviewPositionMap || !refs.overviewPositionEmpty) {
    return;
  }

  if (!window.L) {
    refs.overviewPositionMap.classList.add("hidden");
    refs.overviewPositionEmpty.classList.remove("hidden");
    refs.overviewPositionEmpty.textContent = "Map is unavailable.";
    return;
  }

  const latitude = toFiniteNumber(position && position.latitude);
  const longitude = toFiniteNumber(position && position.longitude);
  if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
    refs.overviewPositionMap.classList.add("hidden");
    refs.overviewPositionEmpty.classList.remove("hidden");
    refs.overviewPositionEmpty.textContent = "No position available";
    return;
  }

  refs.overviewPositionMap.classList.remove("hidden");
  refs.overviewPositionEmpty.classList.add("hidden");

  if (!state.overviewMap) {
    state.overviewMap = window.L.map(refs.overviewPositionMap, {
      zoomControl: true,
      attributionControl: true,
    });
    window.L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19,
    }).addTo(state.overviewMap);
  }

  const currentLatLng = [latitude, longitude];
  if (!state.overviewMapMarker) {
    state.overviewMapMarker = window.L.circleMarker(currentLatLng, {
      radius: 8,
      color: "#7f1d1d",
      weight: 2,
      fillColor: "#ef4444",
      fillOpacity: 0.95,
    }).bindTooltip("Vehicle").addTo(state.overviewMap);
  } else {
    state.overviewMapMarker.setLatLng(currentLatLng);
  }

  state.overviewMap.setView(currentLatLng, 14);
  window.setTimeout(() => {
    if (state.overviewMap) {
      state.overviewMap.invalidateSize();
    }
  }, 80);
}

function setVehicleIdentity(vehicle) {
  if (!vehicle) {
    refs.vehicleName.textContent = "-";
    refs.vehicleVin.textContent = "VIN: -";
    refs.brandChip.classList.add("hidden");
    refs.vehiclePhoto.classList.add("hidden");
    refs.vehiclePhotoFallback.classList.remove("hidden");
    refs.vehiclePhoto.src = "";
    renderOverviewPosition(null);
    return;
  }

  const brand = vehicle.brand || "Stellantis";
  const label = vehicle.label || "Vehicle";
  refs.vehicleName.textContent = `${brand} ${label}`.trim();
  refs.vehicleVin.textContent = `VIN: ${vehicle.vin || "-"}`;

  if (vehicle.brand_logo_url) {
    refs.brandLogo.src = vehicle.brand_logo_url;
    refs.brandLogo.alt = `${brand} logo`;
  } else {
    refs.brandLogo.src = "/assets/pwa/brands/stellantis.svg";
    refs.brandLogo.alt = "Manufacturer logo";
  }
  refs.brandName.textContent = brand;
  refs.brandChip.classList.remove("hidden");

  if (vehicle.picture_url) {
    if (refs.vehiclePhoto.src !== new URL(vehicle.picture_url, window.location.href).href) {
      refs.vehiclePhoto.src = vehicle.picture_url;
    }
    refs.vehiclePhoto.classList.remove("hidden");
    refs.vehiclePhotoFallback.classList.add("hidden");
  } else {
    refs.vehiclePhoto.classList.add("hidden");
    refs.vehiclePhotoFallback.classList.remove("hidden");
    refs.vehiclePhoto.src = "";
  }
}

function setElectricUi(isElectric) {
  state.isElectricVehicle = Boolean(isElectric);
  document.querySelectorAll(".ev-only").forEach((element) => {
    element.classList.toggle("hidden", !state.isElectricVehicle);
  });

  const chargingTab = refs.tabs.find((tab) => tab.dataset.tab === "charging");
  const chargingPanel = document.getElementById("tab-charging");
  if (chargingTab) {
    chargingTab.classList.toggle("hidden", !state.isElectricVehicle);
  }
  if (chargingPanel && !state.isElectricVehicle && !chargingPanel.classList.contains("hidden")) {
    chargingPanel.classList.add("hidden");
  }

  const activeTab = refs.tabs.find((tab) => tab.classList.contains("active"));
  if (!state.isElectricVehicle && activeTab && activeTab.dataset.tab === "charging") {
    activateTab("overview");
  }

  if (refs.summaryConsumptionLabel) {
    refs.summaryConsumptionLabel.textContent = state.isElectricVehicle
      ? "Average consumption (kWh/100km)"
      : "Average fuel consumption (L/100km)";
  }
  if (refs.tripsFuelHeader) {
    refs.tripsFuelHeader.textContent = "Fuel L/100km";
  }
  if (refs.tripStatConsumptionLabel) {
    refs.tripStatConsumptionLabel.textContent = state.isElectricVehicle ? "Avg EV Consumption" : "Avg Fuel Consumption";
  }
}

function activateTab(tabName) {
  refs.tabs.forEach((tab) => {
    tab.classList.toggle("active", tab.dataset.tab === tabName);
  });
  refs.panels.forEach((panel) => {
    panel.classList.toggle("hidden", panel.id !== `tab-${tabName}`);
  });
}

function wireTabs() {
  refs.tabs.forEach((tab) => {
    tab.addEventListener("click", () => activateTab(tab.dataset.tab));
  });
}

function setTabVisibility(visibleTabs) {
  refs.tabs.forEach((tab) => {
    tab.classList.toggle("hidden", !visibleTabs.has(tab.dataset.tab));
  });

  const activeTab = refs.tabs.find((tab) => tab.classList.contains("active"));
  if (!activeTab || !visibleTabs.has(activeTab.dataset.tab)) {
    if (visibleTabs.has("setup")) {
      activateTab("setup");
      return;
    }
    const firstVisible = refs.tabs.find((tab) => visibleTabs.has(tab.dataset.tab));
    if (firstVisible) {
      activateTab(firstVisible.dataset.tab);
    }
  }
}

function ensureControlNotice() {
  let notice = document.getElementById("control-auth-required");
  if (!notice) {
    notice = document.createElement("article");
    notice.id = "control-auth-required";
    notice.className = "card hidden";
    notice.innerHTML = `
      <h2>Remote Control Unavailable</h2>
      <p id="control-auth-required-text" class="muted"></p>
    `;
    const controlPanel = document.getElementById("tab-control");
    if (controlPanel) {
      controlPanel.prepend(notice);
    }
  }
  return notice;
}

function setRemoteControlUi(ready, reason) {
  const notice = ensureControlNotice();
  const noticeText = document.getElementById("control-auth-required-text");
  const controlSections = Array.from(document.querySelectorAll("#tab-control .two-col"));

  controlSections.forEach((section) => {
    section.classList.toggle("hidden", !ready);
  });

  if (ready) {
    notice.classList.add("hidden");
    return;
  }

  if (noticeText) {
    noticeText.textContent = reason || "Complete OTP setup to enable remote controls.";
  }
  notice.classList.remove("hidden");
}

function setAuthUiState(authenticated, remoteAuthError = null) {
  const selectWrap = refs.vehicleSelect ? refs.vehicleSelect.closest(".select-wrap") : null;
  const visibleTabs = authenticated
    ? new Set(["overview", "control", "trips", "charging", "settings", "setup"])
    : new Set(["setup"]);
  const loginRequired = !authenticated;
  const otpRequired = authenticated && Boolean(remoteAuthError);

  setTabVisibility(visibleTabs);

  if (selectWrap) {
    selectWrap.classList.toggle("hidden", !authenticated);
  }
  refs.refreshButton.classList.toggle("hidden", !authenticated);
  if (refs.setupLoginCard) {
    refs.setupLoginCard.classList.toggle("hidden", !loginRequired);
  }
  if (refs.setupOtpCard) {
    refs.setupOtpCard.classList.toggle("hidden", !otpRequired);
  }
  if (!loginRequired) {
    if (refs.oauthUrl) {
      refs.oauthUrl.classList.add("hidden");
    }
    if (refs.oauthMessage) {
      refs.oauthMessage.textContent = "";
    }
  }
  if (!otpRequired) {
    const smsInput = document.getElementById("setup-sms-code");
    const pinInput = document.getElementById("setup-pin-code");
    if (smsInput) {
      smsInput.value = "";
    }
    if (pinInput) {
      pinInput.value = "";
    }
  }

  if (!authenticated) {
    setVehicleIdentity(null);
    state.remoteControlReady = false;
    setRemoteControlUi(false, "Login required before remote controls are available.");
    return;
  }

  const remoteReady = !remoteAuthError;
  state.remoteControlReady = remoteReady;
  setRemoteControlUi(
    remoteReady,
    remoteAuthError || "Remote control requires OTP setup. Use Setup tab to continue.",
  );
}

function populateVehicles(vehicles) {
  refs.vehicleSelect.innerHTML = "";
  vehicles.forEach((vehicle) => {
    const option = document.createElement("option");
    option.value = vehicle.vin;
    option.textContent = `${vehicle.brand || "Unknown"} ${vehicle.label || "Vehicle"} (${vehicle.vin})`;
    refs.vehicleSelect.appendChild(option);
  });

  if (vehicles.length > 0) {
    const hasExisting = vehicles.some((vehicle) => vehicle.vin === state.selectedVin);
    state.selectedVin = hasExisting ? state.selectedVin : vehicles[0].vin;
    refs.vehicleSelect.value = state.selectedVin;
  }
}

function signalBoolean(value) {
  if (value === true) {
    return "Yes";
  }
  if (value === false) {
    return "No";
  }
  return "-";
}

function renderLiveSignals(signals) {
  if (!refs.liveSignals) {
    return;
  }
  const safeSignals = signals && typeof signals === "object" ? signals : {};
  const lockState = Array.isArray(safeSignals.lock_state) && safeSignals.lock_state.length > 0
    ? safeSignals.lock_state.join(", ")
    : "-";
  const openDoors = Array.isArray(safeSignals.open_doors) && safeSignals.open_doors.length > 0
    ? safeSignals.open_doors.join(", ")
    : "-";

  const rows = [
    { label: "Ignition", value: safeSignals.ignition || "-" },
    { label: "Moving", value: signalBoolean(safeSignals.moving) },
    { label: "Speed", value: fmtNumber(safeSignals.speed, 1, " km/h") },
    { label: "Outside Temp", value: fmtNumber(safeSignals.outside_temperature, 1, " C") },
    { label: "Privacy", value: safeSignals.privacy_mode || "-" },
    { label: "Lock State", value: lockState },
    { label: "Open Doors", value: `${Number(safeSignals.open_doors_count) || 0} (${openDoors})` },
    { label: "Doors Updated", value: fmtDate(safeSignals.doors_updated_at) },
  ];

  refs.liveSignals.innerHTML = rows
    .map(
      (row) => `
        <div class="signal-item">
          <span>${escapeHtml(row.label)}</span>
          <strong>${escapeHtml(row.value)}</strong>
        </div>
      `,
    )
    .join("");
}

function renderOverview(data) {
  const status = data.status || {};
  const battery = status.battery || {};
  const fuel = status.fuel || {};
  const position = status.position || null;
  const remainingKm = status.remaining_km || {};

  document.getElementById("metric-battery").textContent = fmtNumber(battery.level, 0, "%");
  document.getElementById("metric-charge-status").textContent = battery.charging_status || "-";
  const electricRange = toFiniteNumber(remainingKm.electric ?? battery.autonomy);
  const fuelRange = toFiniteNumber(remainingKm.fuel ?? fuel.autonomy);
  const totalRange = toFiniteNumber(remainingKm.total);

  let resolvedTotalRange = totalRange;
  if (!Number.isFinite(resolvedTotalRange)) {
    if (Number.isFinite(electricRange) || Number.isFinite(fuelRange)) {
      resolvedTotalRange = (Number.isFinite(electricRange) ? electricRange : 0) + (Number.isFinite(fuelRange) ? fuelRange : 0);
    } else {
      resolvedTotalRange = null;
    }
  }

  document.getElementById("metric-range").textContent = fmtNumber(resolvedTotalRange, 0, " km");
  const rangeDetail = document.getElementById("metric-range-detail");
  if (rangeDetail) {
    const hasElectric = Number.isFinite(electricRange);
    const hasFuel = Number.isFinite(fuelRange);
    if (hasElectric && hasFuel) {
      rangeDetail.textContent = `Electric ${fmtNumber(electricRange, 0, " km")} + Fuel ${fmtNumber(fuelRange, 0, " km")}`;
    } else if (hasElectric) {
      rangeDetail.textContent = `Electric range ${fmtNumber(electricRange, 0, " km")}`;
    } else if (hasFuel) {
      rangeDetail.textContent = `Fuel range ${fmtNumber(fuelRange, 0, " km")}`;
    } else {
      rangeDetail.textContent = "No range data available";
    }
  }
  document.getElementById("metric-mileage").textContent = fmtNumber(status.mileage, 1, " km");
  document.getElementById("metric-soh").textContent = fmtNumber(data.soh, 1, "%");
  document.getElementById("metric-updated").textContent = fmtDate(status.updated_at);
  renderOverviewPosition(position);

  const trips = data.trips || [];
  const chargings = data.chargings || [];
  const avgConsumption = average(trips.map((trip) => Number(trip.consumption_km)));
  const avgFuelConsumption = fuelConsumptionPer100Km(trips);
  const avgCo2 = average(chargings.map((charging) => Number(charging.co2)));
  const avgChargeSpeed = average(
    chargings.map((charging) => {
      const durationMinutes = Number(charging.duration_min);
      const consumed = Number(charging.kw);
      if (!Number.isFinite(durationMinutes) || durationMinutes <= 0 || !Number.isFinite(consumed)) {
        return Number.NaN;
      }
      return consumed / (durationMinutes / 60);
    }),
  );

  const summaryConsumption = state.isElectricVehicle ? avgConsumption : avgFuelConsumption;
  const consumptionSuffix = state.isElectricVehicle ? " kWh/100km" : " L/100km";
  document.getElementById("summary-consumption").textContent = fmtNumber(summaryConsumption, 2, consumptionSuffix);
  document.getElementById("summary-charge-speed").textContent = fmtNumber(avgChargeSpeed, 1, " kW");
  document.getElementById("summary-co2").textContent = fmtNumber(avgCo2, 1, " g/kWh");
  document.getElementById("summary-sessions").textContent = String(chargings.length);
  renderLiveSignals(status.signals || {});
}

function readTripFilters() {
  return {
    fromDate: refs.tripFilterFrom ? refs.tripFilterFrom.value : "",
    toDate: refs.tripFilterTo ? refs.tripFilterTo.value : "",
    minDistance: toFiniteNumber(refs.tripFilterMinDistance ? refs.tripFilterMinDistance.value : null),
    maxDistance: toFiniteNumber(refs.tripFilterMaxDistance ? refs.tripFilterMaxDistance.value : null),
    sortBy: refs.tripFilterSort ? refs.tripFilterSort.value : "date_desc",
  };
}

function sortTrips(trips, sortBy) {
  const sorted = [...trips];
  const numeric = (trip, key) => {
    const numberValue = Number(trip[key]);
    return Number.isFinite(numberValue) ? numberValue : Number.NEGATIVE_INFINITY;
  };

  switch (sortBy) {
    case "distance_desc":
      sorted.sort((left, right) => numeric(right, "distance") - numeric(left, "distance"));
      break;
    case "duration_desc":
      sorted.sort((left, right) => numeric(right, "duration") - numeric(left, "duration"));
      break;
    case "speed_desc":
      sorted.sort((left, right) => numeric(right, "speed_average") - numeric(left, "speed_average"));
      break;
    case "efficiency_electric":
      sorted.sort((left, right) => {
        const leftValue = Number(left.consumption_km);
        const rightValue = Number(right.consumption_km);
        if (!Number.isFinite(leftValue) && !Number.isFinite(rightValue)) {
          return tripTimestamp(right) - tripTimestamp(left);
        }
        if (!Number.isFinite(leftValue)) {
          return 1;
        }
        if (!Number.isFinite(rightValue)) {
          return -1;
        }
        return leftValue - rightValue;
      });
      break;
    case "efficiency_fuel":
      sorted.sort((left, right) => {
        const leftValue = Number(left.consumption_fuel_km);
        const rightValue = Number(right.consumption_fuel_km);
        if (!Number.isFinite(leftValue) && !Number.isFinite(rightValue)) {
          return tripTimestamp(right) - tripTimestamp(left);
        }
        if (!Number.isFinite(leftValue)) {
          return 1;
        }
        if (!Number.isFinite(rightValue)) {
          return -1;
        }
        return leftValue - rightValue;
      });
      break;
    case "date_desc":
    default:
      sorted.sort((left, right) => tripTimestamp(right) - tripTimestamp(left));
  }

  return sorted;
}

function filterTrips(trips) {
  const filters = readTripFilters();
  const fromTimestamp = dateAtStartOfDay(filters.fromDate);
  const toTimestamp = dateAtEndOfDay(filters.toDate);

  const filtered = trips.filter((trip) => {
    const tripTime = tripTimestamp(trip);
    if (fromTimestamp !== null && tripTime < fromTimestamp) {
      return false;
    }
    if (toTimestamp !== null && tripTime > toTimestamp) {
      return false;
    }

    const distance = Number(trip.distance);
    if (Number.isFinite(filters.minDistance) && filters.minDistance > 0 && (!Number.isFinite(distance) || distance < filters.minDistance)) {
      return false;
    }
    if (Number.isFinite(filters.maxDistance) && filters.maxDistance >= 0 && (!Number.isFinite(distance) || distance > filters.maxDistance)) {
      return false;
    }
    return true;
  });

  return sortTrips(filtered, filters.sortBy);
}

function renderTripStatistics(trips) {
  const count = trips.length;
  const totalDistance = trips.reduce((sum, trip) => sum + (Number.isFinite(Number(trip.distance)) ? Number(trip.distance) : 0), 0);
  const totalDurationMinutes = trips.reduce((sum, trip) => sum + (Number.isFinite(Number(trip.duration)) ? Number(trip.duration) : 0), 0);

  const weightedSpeed = totalDurationMinutes > 0 ? totalDistance / (totalDurationMinutes / 60) : null;
  const longestTrip = trips.reduce((max, trip) => {
    const distance = Number(trip.distance);
    if (!Number.isFinite(distance)) {
      return max;
    }
    return Math.max(max, distance);
  }, 0);

  const avgElectricConsumption = average(trips.map((trip) => Number(trip.consumption_km)));
  const avgFuelConsumption = fuelConsumptionPer100Km(trips);
  const averageConsumption = state.isElectricVehicle ? avgElectricConsumption : avgFuelConsumption;
  const consumptionSuffix = state.isElectricVehicle ? " kWh/100km" : " L/100km";

  if (refs.tripStatCount) {
    refs.tripStatCount.textContent = String(count);
  }
  if (refs.tripStatDistance) {
    refs.tripStatDistance.textContent = fmtNumber(totalDistance, 1, " km");
  }
  if (refs.tripStatDuration) {
    refs.tripStatDuration.textContent = fmtNumber(totalDurationMinutes / 60, 1, " h");
  }
  if (refs.tripStatSpeed) {
    refs.tripStatSpeed.textContent = fmtNumber(weightedSpeed, 1, " km/h");
  }
  if (refs.tripStatLongest) {
    refs.tripStatLongest.textContent = fmtNumber(longestTrip, 1, " km");
  }
  if (refs.tripStatConsumption) {
    refs.tripStatConsumption.textContent = fmtNumber(averageConsumption, 2, consumptionSuffix);
  }
}

function renderTrips(trips) {
  const sourceTrips = Array.isArray(trips) ? trips : [];
  const filteredTrips = filterTrips(sourceTrips);
  state.tripsFiltered = filteredTrips;
  renderTripStatistics(filteredTrips);
  destroyTripMaps();

  if (refs.tripFilterSummary) {
    refs.tripFilterSummary.textContent = `Showing ${filteredTrips.length} of ${sourceTrips.length} trips.`;
  }

  if (filteredTrips.length === 0) {
    const colCount = tripColumnCount();
    refs.tripsBody.innerHTML =
      `<tr><td colspan="${colCount}">No trips match current filters. Adjust filters or wait for more vehicle data.</td></tr>`;
    return;
  }

  const colCount = tripColumnCount();
  refs.tripsBody.innerHTML = filteredTrips
    .map((trip, tripIndex) => {
      const startPoint = getTripStartPoint(trip);
      const endPoint = getTripEndPoint(trip);
      const startCoords = startPoint ? tripPointCoordinateLabel(startPoint) : "-";
      const endCoords = endPoint ? tripPointCoordinateLabel(endPoint) : "-";
      const canRenderMap = Boolean(startPoint || endPoint || trip.id);
      const fuelUsedLiters = getTripFuelConsumedLiters(trip);
      const secondaryConsumptionCard = state.isElectricVehicle
        ? `
                <div class="trip-detail-item">
                  <span>Fuel Consumption</span>
                  <strong>${escapeHtml(fmtNumber(trip.consumption_fuel_km, 2, " L/100km"))}</strong>
                </div>
          `
        : `
                <div class="trip-detail-item">
                  <span>Fuel Used</span>
                  <strong>${escapeHtml(fmtNumber(fuelUsedLiters, 2, " L"))}</strong>
                </div>
          `;
      const detailMapBlock = canRenderMap
        ? `
          <div class="trip-map-legend">
            <span><span class="trip-marker-dot route"></span>Path</span>
            <span><span class="trip-marker-dot start"></span>Start</span>
            <span><span class="trip-marker-dot end"></span>End</span>
          </div>
          <div id="${tripMapContainerId(tripIndex)}" class="trip-map"></div>
        `
        : '<p class="trip-map-empty">No map coordinates available for this trip.</p>';

      return `
        <tr class="trip-summary-row" data-trip-index="${tripIndex}" aria-expanded="false">
          <td>
            <span class="trip-summary-main">
              <span class="trip-expand-icon" aria-hidden="true">></span>
              <span>${escapeHtml(fmtDate(trip.start_at))}</span>
            </span>
          </td>
          <td>${escapeHtml(fmtNumber(trip.distance, 1, " km"))}</td>
          <td>${escapeHtml(fmtNumber(trip.duration, 0, " min"))}</td>
          <td>${escapeHtml(fmtNumber(trip.speed_average, 1, " km/h"))}</td>
          ${state.isElectricVehicle ? `<td>${escapeHtml(fmtNumber(trip.consumption_km, 2))}</td>` : ""}
          <td>${escapeHtml(fmtNumber(trip.consumption_fuel_km, 2))}</td>
          <td>${escapeHtml(fmtNumber(fuelUsedLiters, 2, " L"))}</td>
        </tr>
        <tr class="trip-detail-row hidden" data-trip-index="${tripIndex}">
          <td colspan="${colCount}">
            <div class="trip-detail-panel">
              <div class="trip-detail-meta">
                <div class="trip-detail-item">
                  <span>Ended</span>
                  <strong>${escapeHtml(fmtDate(trip.end_at))}</strong>
                </div>
                <div class="trip-detail-item">
                  <span>Start Coordinates</span>
                  <strong>${escapeHtml(startCoords)}</strong>
                </div>
                <div class="trip-detail-item">
                  <span>End Coordinates</span>
                  <strong>${escapeHtml(endCoords)}</strong>
                </div>
                <div class="trip-detail-item">
                  <span>Max Speed</span>
                  <strong>${escapeHtml(fmtNumber(trip.max_speed, 1, " km/h"))}</strong>
                </div>
                <div class="trip-detail-item">
                  <span>${state.isElectricVehicle ? "EV Consumption" : "Fuel Consumption"}</span>
                  <strong>${escapeHtml(
                    state.isElectricVehicle ? fmtNumber(trip.consumption_km, 2, " kWh/100km") : fmtNumber(trip.consumption_fuel_km, 2, " L/100km"),
                  )}</strong>
                </div>
                ${secondaryConsumptionCard}
              </div>
              ${tripDetailActions(startPoint, endPoint)}
              ${detailMapBlock}
            </div>
          </td>
        </tr>`;
    })
    .join("");

  wireTripRows(filteredTrips);
}

function renderChargings(chargings) {
  const sorted = [...chargings].sort((left, right) => new Date(right.start_at) - new Date(left.start_at));
  if (sorted.length === 0) {
    refs.chargingBody.innerHTML = '<tr><td colspan="9">No charging data yet.</td></tr>';
    return;
  }

  refs.chargingBody.innerHTML = sorted
    .map(
      (charging) => `
        <tr>
          <td>${escapeHtml(fmtDate(charging.start_at))}</td>
          <td>${escapeHtml(fmtDate(charging.stop_at))}</td>
          <td>${escapeHtml(charging.duration_str || "-")}</td>
          <td>${escapeHtml(fmtNumber(charging.start_level, 0, "%"))}</td>
          <td>${escapeHtml(fmtNumber(charging.end_level, 0, "%"))}</td>
          <td>${escapeHtml(fmtNumber(charging.kw, 2))}</td>
          <td>${escapeHtml(fmtNumber(charging.co2, 1))}</td>
          <td>${escapeHtml(fmtNumber(charging.price, 2))}</td>
          <td>${escapeHtml(charging.charging_mode || "-")}</td>
        </tr>`,
    )
    .join("");
}

function renderControl(data) {
  const chargeControl = data.charge_control || {};
  document.getElementById("charge-threshold").value = chargeControl.percentage_threshold ?? 100;

  const stopHour = Array.isArray(chargeControl.stop_hour) ? chargeControl.stop_hour : [0, 0];
  document.getElementById("charge-stop-hour").value = stopHour[0] ?? 0;
  document.getElementById("charge-stop-minute").value = stopHour[1] ?? 0;

  const chargeHour = Array.isArray(data.charge_hour) ? data.charge_hour : [22, 30];
  document.getElementById("charge-hour").value = chargeHour[0] ?? 22;
  document.getElementById("charge-minute").value = chargeHour[1] ?? 30;
}

function toNullableNumber(value) {
  if (value === "" || value === null || value === undefined) {
    return null;
  }
  const numberValue = Number(value);
  return Number.isNaN(numberValue) ? null : numberValue;
}

function toNullableText(value) {
  if (typeof value !== "string") {
    return value;
  }
  const trimmed = value.trim();
  return trimmed === "" ? null : trimmed;
}

function renderSettings(settings) {
  if (!settings) {
    return;
  }
  const general = settings.General || {};
  const electricity = settings.Electricity_config || {};

  document.getElementById("settings-currency").value = general.currency ?? "";
  document.getElementById("settings-export-format").value = general.export_format ?? "csv";
  document.getElementById("settings-min-trip").value = general.minimum_trip_length ?? "";

  document.getElementById("settings-day-price").value = electricity.day_price ?? "";
  document.getElementById("settings-night-price").value = electricity.night_price ?? "";
  document.getElementById("settings-night-start").value = electricity.night_hour_start ?? "";
  document.getElementById("settings-night-end").value = electricity.night_hour_end ?? "";
  document.getElementById("settings-dc-price").value = electricity.dc_charge_price ?? "";
  document.getElementById("settings-hs-dc-price").value = electricity.high_speed_dc_charge_price ?? "";
  document.getElementById("settings-hs-dc-threshold").value = electricity.high_speed_dc_charge_threshold ?? "";
  document.getElementById("settings-efficiency").value = electricity.charger_efficiency ?? "";
}

function renderRemoteAuthError(remoteAuthError) {
  if (remoteAuthError) {
    if (state.lastRemoteAuthError !== remoteAuthError) {
      showToast(remoteAuthError, "bad");
    }
    state.lastRemoteAuthError = remoteAuthError;
    if (refs.oauthMessage) {
      refs.oauthMessage.textContent = remoteAuthError;
    }
    return;
  }

  if (state.lastRemoteAuthError && refs.oauthMessage && refs.oauthMessage.textContent === state.lastRemoteAuthError) {
    refs.oauthMessage.textContent = "";
  }
  state.lastRemoteAuthError = null;
}

async function refreshDashboard() {
  if (!state.isAuthenticated || !state.selectedVin) {
    return;
  }
  const dashboard = await apiRequest(`api/dashboard/${encodeURIComponent(state.selectedVin)}`);
  const selectedVehicle = getSelectedVehicle();
  if (selectedVehicle) {
    selectedVehicle.label = dashboard.label || selectedVehicle.label;
    selectedVehicle.brand = dashboard.brand || selectedVehicle.brand;
    selectedVehicle.brand_logo_url = dashboard.brand_logo_url || selectedVehicle.brand_logo_url;
    selectedVehicle.picture_url = dashboard.picture_url || selectedVehicle.picture_url;
    if (dashboard.supports_electric !== null && dashboard.supports_electric !== undefined) {
      selectedVehicle.supports_electric = dashboard.supports_electric;
    }
  }

  const supportsElectric = Boolean(
    dashboard.supports_electric !== null && dashboard.supports_electric !== undefined
      ? dashboard.supports_electric
      : selectedVehicle && selectedVehicle.supports_electric !== null && selectedVehicle.supports_electric !== undefined
        ? selectedVehicle.supports_electric
        : dashboard.has_battery,
  );
  setElectricUi(supportsElectric);
  setVehicleIdentity(selectedVehicle || dashboard);

  state.tripsRaw = dashboard.trips || [];
  renderOverview(dashboard);
  renderTrips(state.tripsRaw);
  renderChargings(dashboard.chargings || []);
  renderControl(dashboard);
  renderSettings(dashboard.settings);
  setAuthUiState(true, dashboard.remote_auth_error || null);
  setElectricUi(supportsElectric);
  renderRemoteAuthError(dashboard.remote_auth_error);

  if (dashboard.auth_error) {
    setConnectionState(dashboard.auth_error, false);
    if (state.lastAuthError !== dashboard.auth_error) {
      showToast(dashboard.auth_error, "bad");
    }
    state.lastAuthError = dashboard.auth_error;
  } else if (state.lastAuthError) {
    state.lastAuthError = null;
    setConnectionState("Connected to backend", true);
  }
}

async function loadAll() {
  try {
    const vehiclesResponse = await apiRequest("api/vehicles");
    state.isAuthenticated = Boolean(vehiclesResponse.authenticated);

    if (!state.isAuthenticated) {
      setConnectionState("Authentication required. Open Setup to login.", false);
      setAuthUiState(false, null);
      renderRemoteAuthError(null);
      state.vehicles = [];
      state.selectedVin = null;
      state.tripsRaw = [];
      populateVehicles([]);
      setVehicleIdentity(null);
      renderTrips([]);
      activateTab("setup");
      return;
    }

    setConnectionState("Connected to backend", true);
    setAuthUiState(true, vehiclesResponse.remote_auth_error || null);

    state.vehicles = vehiclesResponse.vehicles || [];
    renderRemoteAuthError(vehiclesResponse.remote_auth_error);
    populateVehicles(state.vehicles);
    const selectedVehicle = getSelectedVehicle();
    setVehicleIdentity(selectedVehicle);
    setElectricUi(Boolean(selectedVehicle ? selectedVehicle.supports_electric : true));

    if (state.vehicles.length === 0) {
      showToast("No vehicles configured yet. Use the Setup tab.", "bad");
      setVehicleIdentity(null);
      state.tripsRaw = [];
      renderTrips([]);
      activateTab("setup");
      return;
    }

    await refreshDashboard();
  } catch (error) {
    state.isAuthenticated = false;
    state.tripsRaw = [];
    setAuthUiState(false, null);
    setVehicleIdentity(null);
    renderTrips([]);
    setConnectionState(error.message, false);
    showToast(error.message, "bad");
  }
}

async function runAction(path, successMessage, body = {}) {
  const vin = getSelectedVin();
  const payload = await post(path(vin), body);
  if (!payload.ok && payload.error) {
    throw new Error(payload.error);
  }
  showToast(successMessage, "ok");
  await refreshDashboard();
}

function wireControlActions() {
  const actionHandlers = {
    wakeup: () => runAction((vin) => `api/vehicle/${encodeURIComponent(vin)}/wakeup`, "Wakeup sent"),
    "charge-on": () =>
      runAction((vin) => `api/vehicle/${encodeURIComponent(vin)}/charge`, "Charge start sent", { enabled: true }),
    "charge-off": () =>
      runAction((vin) => `api/vehicle/${encodeURIComponent(vin)}/charge`, "Charge stop sent", { enabled: false }),
    "precond-on": () =>
      runAction((vin) => `api/vehicle/${encodeURIComponent(vin)}/preconditioning`, "Preconditioning started", {
        enabled: true,
      }),
    "precond-off": () =>
      runAction((vin) => `api/vehicle/${encodeURIComponent(vin)}/preconditioning`, "Preconditioning stopped", {
        enabled: false,
      }),
    lock: () => runAction((vin) => `api/vehicle/${encodeURIComponent(vin)}/doors`, "Doors locked", { lock: true }),
    unlock: () =>
      runAction((vin) => `api/vehicle/${encodeURIComponent(vin)}/doors`, "Doors unlocked", { lock: false }),
  };

  document.querySelectorAll("[data-action]").forEach((button) => {
    button.addEventListener("click", async () => {
      await withBusyButton(button, "Sending", async () => {
        try {
          await actionHandlers[button.dataset.action]();
        } catch (error) {
          showToast(error.message, "bad");
        }
      });
    });
  });

  document.getElementById("horn-form").addEventListener("submit", async (event) => {
    event.preventDefault();
    const submitButton = resolveSubmitButton(event);
    const count = Number(document.getElementById("horn-count").value || 1);
    await withBusyButton(submitButton, "Sending", async () => {
      try {
        await runAction((vin) => `api/vehicle/${encodeURIComponent(vin)}/horn`, "Horn command sent", { count });
      } catch (error) {
        showToast(error.message, "bad");
      }
    });
  });

  document.getElementById("lights-form").addEventListener("submit", async (event) => {
    event.preventDefault();
    const submitButton = resolveSubmitButton(event);
    const duration = Number(document.getElementById("lights-duration").value || 10);
    await withBusyButton(submitButton, "Sending", async () => {
      try {
        await runAction((vin) => `api/vehicle/${encodeURIComponent(vin)}/lights`, "Lights command sent", { duration });
      } catch (error) {
        showToast(error.message, "bad");
      }
    });
  });

  document.getElementById("charge-control-form").addEventListener("submit", async (event) => {
    event.preventDefault();
    const submitButton = resolveSubmitButton(event);
    const percentage = Number(document.getElementById("charge-threshold").value || 100);
    const hour = Number(document.getElementById("charge-stop-hour").value || 0);
    const minute = Number(document.getElementById("charge-stop-minute").value || 0);
    await withBusyButton(submitButton, "Saving", async () => {
      try {
        await runAction((vin) => `api/vehicle/${encodeURIComponent(vin)}/charge-control`, "Charge control updated", {
          percentage,
          hour,
          minute,
        });
      } catch (error) {
        showToast(error.message, "bad");
      }
    });
  });

  document.getElementById("charge-hour-form").addEventListener("submit", async (event) => {
    event.preventDefault();
    const submitButton = resolveSubmitButton(event);
    const hour = Number(document.getElementById("charge-hour").value || 22);
    const minute = Number(document.getElementById("charge-minute").value || 30);
    await withBusyButton(submitButton, "Saving", async () => {
      try {
        await runAction((vin) => `api/vehicle/${encodeURIComponent(vin)}/charge-hour`, "Charge hour updated", {
          hour,
          minute,
        });
      } catch (error) {
        showToast(error.message, "bad");
      }
    });
  });

}

function wireSettingsForm() {
  document.getElementById("settings-form").addEventListener("submit", async (event) => {
    event.preventDefault();
    const submitButton = resolveSubmitButton(event);

    const generalPayload = {
      currency: toNullableText(document.getElementById("settings-currency").value),
      export_format: toNullableText(document.getElementById("settings-export-format").value) || "csv",
      minimum_trip_length: toNullableNumber(document.getElementById("settings-min-trip").value),
    };

    const electricityPayload = {
      day_price: toNullableNumber(document.getElementById("settings-day-price").value),
      night_price: toNullableNumber(document.getElementById("settings-night-price").value),
      night_hour_start: toNullableText(document.getElementById("settings-night-start").value),
      night_hour_end: toNullableText(document.getElementById("settings-night-end").value),
      dc_charge_price: toNullableNumber(document.getElementById("settings-dc-price").value),
      high_speed_dc_charge_price: toNullableNumber(document.getElementById("settings-hs-dc-price").value),
      high_speed_dc_charge_threshold: toNullableNumber(document.getElementById("settings-hs-dc-threshold").value),
      charger_efficiency: toNullableNumber(document.getElementById("settings-efficiency").value),
    };

    await withBusyButton(submitButton, "Saving", async () => {
      try {
        await post("api/settings/general", generalPayload);
        await post("api/settings/electricity_config", electricityPayload);
        showToast("Settings saved", "ok");
        await refreshDashboard();
      } catch (error) {
        showToast(error.message, "bad");
      }
    });
  });
}

function wireTripFilters() {
  if (!refs.tripFiltersForm) {
    return;
  }

  const applyFilters = () => {
    renderTrips(state.tripsRaw || []);
  };

  refs.tripFiltersForm.addEventListener("submit", (event) => {
    event.preventDefault();
    applyFilters();
  });

  if (refs.tripFiltersReset) {
    refs.tripFiltersReset.addEventListener("click", () => {
      if (refs.tripFilterFrom) {
        refs.tripFilterFrom.value = "";
      }
      if (refs.tripFilterTo) {
        refs.tripFilterTo.value = "";
      }
      if (refs.tripFilterMinDistance) {
        refs.tripFilterMinDistance.value = "";
      }
      if (refs.tripFilterMaxDistance) {
        refs.tripFilterMaxDistance.value = "";
      }
      if (refs.tripFilterSort) {
        refs.tripFilterSort.value = "date_desc";
      }
      applyFilters();
    });
  }

  [refs.tripFilterFrom, refs.tripFilterTo, refs.tripFilterMinDistance, refs.tripFilterMaxDistance, refs.tripFilterSort]
    .filter(Boolean)
    .forEach((input) => {
      input.addEventListener("change", applyFilters);
    });
}

function wireSetupForms() {
  document.getElementById("setup-login-form").addEventListener("submit", async (event) => {
    event.preventDefault();
    const submitButton = resolveSubmitButton(event);
    const payload = {
      package_name: document.getElementById("setup-package").value,
      email: document.getElementById("setup-email").value,
      password: document.getElementById("setup-password").value,
      country_code: document.getElementById("setup-country").value,
    };

    await withBusyButton(submitButton, "Preparing", async () => {
      refs.oauthMessage.textContent = "Preparing setup. This can take up to one minute on first run...";
      try {
        const result = await post("api/setup/login", payload);
        refs.oauthUrl.href = result.redirect_url;
        refs.oauthUrl.classList.remove("hidden");
        refs.oauthMessage.textContent = "OAuth URL ready. Complete login in the opened page to continue automatically.";
        showToast("Setup session created", "ok");
      } catch (error) {
        refs.oauthMessage.textContent = "Setup failed. Check credentials and retry.";
        showToast(error.message, "bad");
      }
    });
  });

  document.getElementById("setup-send-sms").addEventListener("click", async (event) => {
    const button = event.currentTarget;
    await withBusyButton(button, "Sending", async () => {
      try {
        await post("api/setup/otp/sms");
        showToast("SMS sent", "ok");
      } catch (error) {
        showToast(error.message, "bad");
      }
    });
  });

  document.getElementById("setup-otp-form").addEventListener("submit", async (event) => {
    event.preventDefault();
    const submitButton = resolveSubmitButton(event);
    const smsCode = document.getElementById("setup-sms-code").value.trim();
    const pinCode = document.getElementById("setup-pin-code").value.trim();
    await withBusyButton(submitButton, "Configuring", async () => {
      try {
        await post("api/setup/otp", { sms_code: smsCode, pin_code: pinCode });
        showToast("OTP configuration completed", "ok");
        await loadAll();
      } catch (error) {
        showToast(error.message, "bad");
      }
    });
  });

  const params = new URLSearchParams(window.location.search);
  const legacyOAuthUrl = params.get("url");
  const oauthCallbackState = params.get("oauth");
  if (legacyOAuthUrl) {
    refs.oauthUrl.href = legacyOAuthUrl;
    refs.oauthUrl.classList.remove("hidden");
    refs.oauthMessage.textContent = "OAuth URL detected from query parameters.";
    activateTab("setup");
  }
  if (oauthCallbackState === "done") {
    refs.oauthMessage.textContent = "OAuth callback received. Finalizing login...";
    showToast("OAuth callback received. Refreshing setup status...", "ok");
    activateTab("setup");
    window.setTimeout(() => {
      loadAll().catch((error) => showToast(error.message, "bad"));
    }, 1200);
    params.delete("oauth");
    window.history.replaceState({}, "", `${window.location.pathname}${params.toString() ? `?${params.toString()}` : ""}`);
  } else if (oauthCallbackState === "error") {
    refs.oauthMessage.textContent = "OAuth callback returned an error. Check backend logs and retry setup.";
    showToast("OAuth callback failed. Check setup logs.", "bad");
    activateTab("setup");
    params.delete("oauth");
    window.history.replaceState({}, "", `${window.location.pathname}${params.toString() ? `?${params.toString()}` : ""}`);
  }
}

function wireGlobalActions() {
  refs.refreshButton.addEventListener("click", async (event) => {
    const button = event.currentTarget;
    await withBusyButton(button, "Refreshing", async () => {
      try {
        await loadAll();
        showToast("Data refreshed", "ok");
      } catch (error) {
        showToast(error.message, "bad");
      }
    });
  });

  refs.vehicleSelect.addEventListener("change", async () => {
    state.selectedVin = refs.vehicleSelect.value;
    const selectedVehicle = getSelectedVehicle();
    setVehicleIdentity(selectedVehicle);
    setElectricUi(Boolean(selectedVehicle ? selectedVehicle.supports_electric : true));
    try {
      await refreshDashboard();
    } catch (error) {
      showToast(error.message, "bad");
    }
  });
}

function wireInstallPrompt() {
  window.addEventListener("beforeinstallprompt", (event) => {
    event.preventDefault();
    state.deferredPrompt = event;
    refs.installButton.hidden = false;
  });

  refs.installButton.addEventListener("click", async (event) => {
    if (!state.deferredPrompt) {
      return;
    }
    const button = event.currentTarget;
    await withBusyButton(button, "Opening", async () => {
      state.deferredPrompt.prompt();
      await state.deferredPrompt.userChoice;
      state.deferredPrompt = null;
      refs.installButton.hidden = true;
    });
  });
}

async function registerServiceWorker() {
  if (!("serviceWorker" in navigator)) {
    return;
  }
  try {
    const registration = await navigator.serviceWorker.register("service-worker.js");

    if (registration.waiting) {
      registration.waiting.postMessage({ type: "SKIP_WAITING" });
    }

    registration.addEventListener("updatefound", () => {
      const installing = registration.installing;
      if (!installing) {
        return;
      }

      installing.addEventListener("statechange", () => {
        if (installing.state === "installed" && navigator.serviceWorker.controller) {
          showToast("Updating app...", "ok");
          installing.postMessage({ type: "SKIP_WAITING" });
        }
      });
    });

    navigator.serviceWorker.addEventListener("controllerchange", () => {
      if (registerServiceWorker.reloading) {
        return;
      }
      registerServiceWorker.reloading = true;
      window.location.reload();
    });

    if (registration.update) {
      window.setTimeout(() => {
        registration.update().catch(() => {});
      }, 3000);
    }
  } catch (error) {
    console.error("Service worker registration failed", error);
  }
}

function startAutoRefresh() {
  window.clearInterval(state.refreshTimer);
  state.refreshTimer = window.setInterval(async () => {
    try {
      if (!state.isAuthenticated) {
        await loadAll();
      } else if (state.selectedVin) {
        await refreshDashboard();
      }
    } catch (error) {
      setConnectionState(error.message, false);
    }
  }, 120000);
}

async function bootstrap() {
  wireTabs();
  wireGlobalActions();
  wireControlActions();
  wireSettingsForm();
  wireTripFilters();
  wireSetupForms();
  wireInstallPrompt();
  refs.vehiclePhoto.addEventListener("error", () => {
    refs.vehiclePhoto.classList.add("hidden");
    refs.vehiclePhotoFallback.classList.remove("hidden");
  });
  refs.vehiclePhoto.addEventListener("load", () => {
    refs.vehiclePhoto.classList.remove("hidden");
    refs.vehiclePhotoFallback.classList.add("hidden");
  });
  await registerServiceWorker();

  try {
    await loadAll();
  } finally {
    startAutoRefresh();
  }
}

bootstrap();
