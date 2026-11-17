/**
 * LocalStorage Service Module
 * Handles persistence for user preferences, recent searches, and unit settings
 */

const STORAGE_KEYS = {
  UNIT: "odin_weather_unit",
  LAST_LOCATION: "odin_weather_last_location",
  SEARCH_HISTORY: "odin_weather_history",
  API_KEY: "odin_weather_api_key",
};

export const StorageService = {
  /**
   * Retrieves saved temperature unit ('C' or 'F')
   */
  getUnit() {
    try {
      const saved = localStorage.getItem(STORAGE_KEYS.UNIT);
      return saved === "F" ? "F" : "C";
    } catch {
      return "C";
    }
  },

  /**
   * Saves preferred temperature unit
   * @param {'C' | 'F'} unit
   */
  setUnit(unit) {
    try {
      localStorage.setItem(STORAGE_KEYS.UNIT, unit === "F" ? "F" : "C");
    } catch (e) {
      console.warn("Could not save unit to localStorage", e);
    }
  },

  /**
   * Retrieves the last queried location
   */
  getLastLocation() {
    try {
      return localStorage.getItem(STORAGE_KEYS.LAST_LOCATION) || "Tokyo";
    } catch {
      return "Tokyo";
    }
  },

  /**
   * Saves the last queried location
   * @param {string} location
   */
  setLastLocation(location) {
    try {
      if (location && typeof location === "string") {
        localStorage.setItem(STORAGE_KEYS.LAST_LOCATION, location.trim());
      }
    } catch (e) {
      console.warn("Could not save last location", e);
    }
  },

  /**
   * Retrieves recent search history (up to 6 items)
   * @returns {string[]}
   */
  getSearchHistory() {
    try {
      const data = localStorage.getItem(STORAGE_KEYS.SEARCH_HISTORY);
      if (data) {
        const parsed = JSON.parse(data);
        if (Array.isArray(parsed)) return parsed;
      }
    } catch (e) {
      console.warn("Error reading search history", e);
    }
    return ["Tokyo", "London", "New York", "Paris", "Sydney"];
  },

  /**
   * Adds a location to search history
   * @param {string} location
   */
  addToSearchHistory(location) {
    if (!location || typeof location !== "string") return;
    const trimmed = location.trim();
    if (!trimmed) return;

    try {
      let history = this.getSearchHistory().filter(
        (item) => item.toLowerCase() !== trimmed.toLowerCase()
      );
      history.unshift(trimmed);
      if (history.length > 8) history = history.slice(0, 8);
      localStorage.setItem(STORAGE_KEYS.SEARCH_HISTORY, JSON.stringify(history));
    } catch (e) {
      console.warn("Could not add to search history", e);
    }
  },

  /**
   * Retrieves custom Visual Crossing API key if user configured one
   */
  getApiKey() {
    try {
      return localStorage.getItem(STORAGE_KEYS.API_KEY) || "";
    } catch {
      return "";
    }
  },

  /**
   * Saves custom Visual Crossing API key
   * @param {string} key
   */
  setApiKey(key) {
    try {
      if (!key) {
        localStorage.removeItem(STORAGE_KEYS.API_KEY);
      } else {
        localStorage.setItem(STORAGE_KEYS.API_KEY, key.trim());
      }
    } catch (e) {
      console.warn("Could not save API key", e);
    }
  },
};
