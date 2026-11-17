/**
 * WeatherPulse - Main Application Entrypoint
 * The Odin Project: JavaScript Weather App
 */

// Stylesheets
import "./styles/main.css";
import "./styles/theme.css";
import "./styles/weather-card.css";
import "./styles/components.css";
import "./styles/animations.css";

// Application Modules
import { fetchRawWeatherData } from "./modules/api";
import { processWeatherData } from "./modules/weatherData";
import { DOMController } from "./modules/domController";
import { StorageService } from "./modules/storage";
import { Unit } from "./modules/unitConverter";

class WeatherApp {
  constructor() {
    this.dom = new DOMController();
    this.currentLocation = StorageService.getLastLocation();
    this.activeUnit = StorageService.getUnit();
    this.customApiKey = StorageService.getApiKey();

    this.init();
  }

  /**
   * Initializes application state, UI components, and event listeners
   */
  init() {
    // 1. Initialize Unit Toggle
    this.dom.setUnit(this.activeUnit);

    // 2. Render Search History Chips
    this.refreshQuickChips();

    // 3. Attach Event Listeners
    this.setupEventListeners();

    // 4. Load initial forecast
    this.loadForecast(this.currentLocation);
  }

  /**
   * Re-renders quick location suggestion chips
   */
  refreshQuickChips() {
    const history = StorageService.getSearchHistory();
    this.dom.renderQuickChips(history, (city) => {
      this.dom.searchInput.value = city;
      this.loadForecast(city);
    });
  }

  /**
   * Primary workflow: Fetches and displays weather for a given query
   * @param {string} query - City name, postal code, or lat,lon
   */
  async loadForecast(query) {
    if (!query || !query.trim()) return;

    const trimmed = query.trim();
    this.dom.showLoading(trimmed);

    try {
      // 1. Fetch raw JSON from Visual Crossing API
      const rawData = await fetchRawWeatherData(trimmed, this.customApiKey);

      // 2. Process data into clean app model
      const processed = processWeatherData(rawData);

      // 3. Render into DOM
      await this.dom.renderWeather(processed);

      // 4. Save state & history
      this.currentLocation = trimmed;
      StorageService.setLastLocation(trimmed);
      StorageService.addToSearchHistory(processed.location.address || trimmed);
      this.refreshQuickChips();
    } catch (error) {
      console.error("Forecast loading error:", error);
      this.dom.showError(error.message);
    }
  }

  /**
   * Handles user request to fetch weather for current geographic location
   */
  handleGeolocation() {
    if (!navigator.geolocation) {
      this.dom.showError("Geolocation is not supported by your browser.");
      return;
    }

    this.dom.showLoading("current location");

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        const coordsQuery = `${latitude.toFixed(4)},${longitude.toFixed(4)}`;
        this.loadForecast(coordsQuery);
      },
      (geoError) => {
        let msg = "Could not determine your physical location.";
        if (geoError.code === geoError.PERMISSION_DENIED) {
          msg = "Location access was denied. Please search by city name instead.";
        }
        this.dom.showError(msg);
      },
      { timeout: 10000 }
    );
  }

  /**
   * Sets up all DOM event bindings
   */
  setupEventListeners() {
    // 1. Search Form Submission
    if (this.dom.searchForm) {
      this.dom.searchForm.addEventListener("submit", (e) => {
        e.preventDefault();
        const value = this.dom.searchInput.value.trim();
        if (value) {
          this.loadForecast(value);
        }
      });
    }

    // 2. Geolocation Button
    if (this.dom.geoBtn) {
      this.dom.geoBtn.addEventListener("click", () => {
        this.handleGeolocation();
      });
    }

    // 3. Unit Toggle Switch (°C <-> °F)
    if (this.dom.unitToggle) {
      this.dom.unitToggle.addEventListener("change", (e) => {
        const newUnit = e.target.checked ? Unit.FAHRENHEIT : Unit.CELSIUS;
        this.activeUnit = newUnit;
        StorageService.setUnit(newUnit);
        this.dom.setUnit(newUnit);
      });
    }

    // 4. Error Close Button
    const errorCloseBtn = document.getElementById("error-close-btn");
    if (errorCloseBtn) {
      errorCloseBtn.addEventListener("click", () => {
        this.dom.hideError();
      });
    }

    // 5. Settings Modal Controls
    const settingsBtn = document.getElementById("settings-btn");
    const modalCloseBtn = document.getElementById("modal-close-btn");
    const saveSettingsBtn = document.getElementById("save-settings-btn");
    const customApiKeyInput = document.getElementById("custom-api-key");

    if (settingsBtn && this.dom.settingsModal) {
      settingsBtn.addEventListener("click", () => {
        if (customApiKeyInput) {
          customApiKeyInput.value = StorageService.getApiKey();
        }
        this.dom.settingsModal.classList.remove("hidden");
      });
    }

    if (modalCloseBtn && this.dom.settingsModal) {
      modalCloseBtn.addEventListener("click", () => {
        this.dom.settingsModal.classList.add("hidden");
      });
    }

    if (this.dom.settingsModal) {
      this.dom.settingsModal.addEventListener("click", (e) => {
        if (e.target === this.dom.settingsModal) {
          this.dom.settingsModal.classList.add("hidden");
        }
      });
    }

    if (saveSettingsBtn && this.dom.settingsModal) {
      saveSettingsBtn.addEventListener("click", () => {
        if (customApiKeyInput) {
          const key = customApiKeyInput.value.trim();
          StorageService.setApiKey(key);
          this.customApiKey = key;
        }
        this.dom.settingsModal.classList.add("hidden");
      });
    }
  }
}

// Instantiate application on DOM ready
document.addEventListener("DOMContentLoaded", () => {
  new WeatherApp();
});
