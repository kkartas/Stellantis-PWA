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
  positionLink: document.getElementById("position-link"),
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
  return parsed.toLocaleString();
}

function average(values) {
  const valid = values.filter((value) => Number.isFinite(value));
  if (valid.length === 0) {
    return null;
  }
  return valid.reduce((sum, value) => sum + value, 0) / valid.length;
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

function setVehicleIdentity(vehicle) {
  if (!vehicle) {
    refs.vehicleName.textContent = "-";
    refs.vehicleVin.textContent = "VIN: -";
    refs.brandChip.classList.add("hidden");
    refs.vehiclePhoto.classList.add("hidden");
    refs.vehiclePhotoFallback.classList.remove("hidden");
    refs.vehiclePhoto.src = "";
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

function renderOverview(data) {
  const status = data.status || {};
  const battery = status.battery || {};
  const position = status.position || null;

  document.getElementById("metric-battery").textContent = fmtNumber(battery.level, 0, "%");
  document.getElementById("metric-charge-status").textContent = battery.charging_status || "-";
  document.getElementById("metric-range").textContent = fmtNumber(battery.autonomy, 0, " km");
  document.getElementById("metric-mileage").textContent = fmtNumber(status.mileage, 1, " km");
  document.getElementById("metric-soh").textContent = fmtNumber(data.soh, 1, "%");
  document.getElementById("metric-updated").textContent = fmtDate(status.updated_at);

  const positionLabel = document.getElementById("metric-position");
  if (position) {
    positionLabel.textContent = `${fmtNumber(position.latitude, 5)}, ${fmtNumber(position.longitude, 5)}`;
    refs.positionLink.href = position.google_maps_url;
    refs.positionLink.classList.remove("hidden");
  } else {
    positionLabel.textContent = "No position available";
    refs.positionLink.classList.add("hidden");
  }

  const trips = data.trips || [];
  const chargings = data.chargings || [];
  const avgConsumption = average(trips.map((trip) => Number(trip.consumption_km)));
  const avgFuelConsumption = average(trips.map((trip) => Number(trip.consumption_fuel_km)));
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
}

function renderTrips(trips) {
  const sorted = [...trips].sort((left, right) => new Date(right.start_at) - new Date(left.start_at));
  if (sorted.length === 0) {
    const colCount = state.isElectricVehicle ? 6 : 5;
    refs.tripsBody.innerHTML =
      `<tr><td colspan="${colCount}">No trip data yet (drive with refresh enabled, or wait for cloud history).</td></tr>`;
    return;
  }

  refs.tripsBody.innerHTML = sorted
    .map(
      (trip) => `
        <tr>
          <td>${escapeHtml(fmtDate(trip.start_at))}</td>
          <td>${escapeHtml(fmtNumber(trip.distance, 1, " km"))}</td>
          <td>${escapeHtml(fmtNumber(trip.duration, 0, " min"))}</td>
          <td>${escapeHtml(fmtNumber(trip.speed_average, 1, " km/h"))}</td>
          ${state.isElectricVehicle ? `<td>${escapeHtml(fmtNumber(trip.consumption_km, 2))}</td>` : ""}
          <td>${escapeHtml(fmtNumber(trip.consumption_fuel_km, 2))}</td>
        </tr>`,
    )
    .join("");
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

  renderOverview(dashboard);
  renderTrips(dashboard.trips || []);
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
      populateVehicles([]);
      setVehicleIdentity(null);
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
      activateTab("setup");
      return;
    }

    await refreshDashboard();
  } catch (error) {
    state.isAuthenticated = false;
    setAuthUiState(false, null);
    setVehicleIdentity(null);
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
  if (legacyOAuthUrl) {
    refs.oauthUrl.href = legacyOAuthUrl;
    refs.oauthUrl.classList.remove("hidden");
    refs.oauthMessage.textContent = "OAuth URL detected from query parameters.";
    activateTab("setup");
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
    await navigator.serviceWorker.register("service-worker.js");
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
