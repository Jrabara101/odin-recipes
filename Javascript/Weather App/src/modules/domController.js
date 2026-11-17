/**
 * DOM Controller Module
 * Handles all UI rendering, state transitions, dynamic icon placement,
 * loading states, and error alerts
 */

import {
  formatTemp,
  formatWindSpeed,
  formatPrecipitation,
  formatPressure,
  formatVisibility,
  Unit,
} from "./unitConverter";
import { getWeatherIconUrl } from "./iconLoader";
import { applyWeatherTheme } from "./themeManager";

export class DOMController {
  constructor() {
    this.currentData = null;
    this.currentUnit = Unit.CELSIUS;

    // Cache primary DOM elements
    this.appContainer = document.getElementById("app");
    this.searchForm = document.getElementById("search-form");
    this.searchInput = document.getElementById("search-input");
    this.unitToggle = document.getElementById("unit-toggle");
    this.unitLabel = document.getElementById("unit-label");
    this.geoBtn = document.getElementById("geo-btn");
    this.quickChipsContainer = document.getElementById("quick-chips");
    this.loadingContainer = document.getElementById("loading-state");
    this.errorContainer = document.getElementById("error-state");
    this.weatherContent = document.getElementById("weather-content");
    this.settingsModal = document.getElementById("settings-modal");
  }

  /**
   * Sets the active unit ('C' or 'F') and updates toggle UI
   * @param {'C' | 'F'} unit
   */
  setUnit(unit) {
    this.currentUnit = unit === Unit.FAHRENHEIT ? Unit.FAHRENHEIT : Unit.CELSIUS;
    if (this.unitToggle) {
      this.unitToggle.checked = this.currentUnit === Unit.FAHRENHEIT;
    }
    if (this.unitLabel) {
      this.unitLabel.textContent = `°${this.currentUnit}`;
    }

    // If data is already rendered, update temperatures and speeds dynamically
    if (this.currentData) {
      this.updateDynamicUnits();
    }
  }

  /**
   * Shows the loading indicator while fetching weather
   * @param {string} location
   */
  showLoading(location) {
    if (this.errorContainer) {
      this.errorContainer.classList.add("hidden");
    }
    if (this.weatherContent) {
      this.weatherContent.classList.add("hidden");
    }
    if (this.loadingContainer) {
      this.loadingContainer.classList.remove("hidden");
      const targetCity = this.loadingContainer.querySelector(".loading-city");
      if (targetCity) {
        targetCity.textContent = location ? `"${location}"` : "forecast";
      }
    }
  }

  /**
   * Hides the loading indicator
   */
  hideLoading() {
    if (this.loadingContainer) {
      this.loadingContainer.classList.add("hidden");
    }
  }

  /**
   * Displays an error message
   * @param {string} message
   */
  showError(message) {
    this.hideLoading();
    if (this.weatherContent) {
      this.weatherContent.classList.add("hidden");
    }
    if (this.errorContainer) {
      this.errorContainer.classList.remove("hidden");
      const errorMsg = this.errorContainer.querySelector(".error-message");
      if (errorMsg) {
        errorMsg.textContent = message;
      }
    }
  }

  /**
   * Hides the error banner
   */
  hideError() {
    if (this.errorContainer) {
      this.errorContainer.classList.add("hidden");
    }
  }

  /**
   * Renders the quick search chips
   * @param {string[]} chips
   * @param {Function} onSelect
   */
  renderQuickChips(chips, onSelect) {
    if (!this.quickChipsContainer) return;
    this.quickChipsContainer.innerHTML = "";

    chips.forEach((city) => {
      const chip = document.createElement("button");
      chip.type = "button";
      chip.className = "quick-chip";
      chip.textContent = city;
      chip.addEventListener("click", () => onSelect(city));
      this.quickChipsContainer.appendChild(chip);
    });
  }

  /**
   * Primary render method for full weather data
   * @param {object} data - Processed weather object from weatherData.js
   */
  async renderWeather(data) {
    this.currentData = data;
    this.hideLoading();
    this.hideError();

    if (!data) return;

    // Apply reactive theme & ambient background
    applyWeatherTheme(data.current.icon);

    if (this.weatherContent) {
      this.weatherContent.classList.remove("hidden");
    }

    // 1. Render Current Hero Section
    await this.renderHero(data);

    // 2. Render Highlights Grid
    this.renderHighlights(data.current);

    // 3. Render 24-hour Hourly Forecast
    await this.renderHourly(data.hourly);

    // 4. Render 7-day Daily Forecast
    await this.renderDaily(data.forecastDays);
  }

  /**
   * Renders hero weather card (Location, Big Temp, Dynamic Icon, Condition)
   * @param {object} data
   */
  async renderHero(data) {
    const { location, current } = data;

    // Location info
    const locationEl = document.getElementById("hero-location");
    if (locationEl) {
      locationEl.textContent = location.address;
    }

    const timeEl = document.getElementById("hero-time");
    if (timeEl) {
      const now = new Date();
      timeEl.textContent = now.toLocaleDateString(undefined, {
        weekday: "long",
        month: "short",
        day: "numeric",
      });
    }

    // Big Temperature
    const tempEl = document.getElementById("hero-temp");
    if (tempEl) {
      tempEl.textContent = formatTemp(current.temp, this.currentUnit, false);
      tempEl.dataset.tempC = current.temp;
    }

    const unitEl = document.getElementById("hero-unit");
    if (unitEl) {
      unitEl.textContent = `°${this.currentUnit}`;
    }

    // High & Low
    const highEl = document.getElementById("hero-high");
    if (highEl) {
      highEl.textContent = formatTemp(current.tempmax, this.currentUnit);
      highEl.dataset.tempC = current.tempmax;
    }

    const lowEl = document.getElementById("hero-low");
    if (lowEl) {
      lowEl.textContent = formatTemp(current.tempmin, this.currentUnit);
      lowEl.dataset.tempC = current.tempmin;
    }

    // Feels like
    const feelsEl = document.getElementById("hero-feels");
    if (feelsEl) {
      feelsEl.textContent = formatTemp(current.feelslike, this.currentUnit);
      feelsEl.dataset.tempC = current.feelslike;
    }

    // Condition text
    const conditionEl = document.getElementById("hero-condition");
    if (conditionEl) {
      conditionEl.textContent = current.conditions;
    }

    // Hero Dynamic Icon using dynamic import
    const iconContainer = document.getElementById("hero-icon-container");
    if (iconContainer) {
      iconContainer.innerHTML = "";
      const iconUrl = await getWeatherIconUrl(current.icon);
      if (iconUrl) {
        const img = document.createElement("img");
        img.src = iconUrl;
        img.alt = current.conditions;
        img.className = "hero-weather-icon";
        iconContainer.appendChild(img);
      }
    }
  }

  /**
   * Renders the weather highlights grid (Humidity, Wind, Pressure, etc.)
   * @param {object} current
   */
  renderHighlights(current) {
    // Humidity
    const humidityEl = document.getElementById("stat-humidity");
    if (humidityEl) humidityEl.textContent = `${Math.round(current.humidity)}%`;

    // Wind
    const windEl = document.getElementById("stat-wind");
    if (windEl) {
      windEl.textContent = formatWindSpeed(current.windspeed, this.currentUnit);
      windEl.dataset.windSpeed = current.windspeed;
    }

    // Wind Direction
    const windDirEl = document.getElementById("stat-wind-dir");
    if (windDirEl) {
      windDirEl.style.transform = `rotate(${current.winddir}deg)`;
    }

    // Precipitation Chance & Amount
    const precipProbEl = document.getElementById("stat-precip-prob");
    if (precipProbEl) {
      precipProbEl.textContent = `${Math.round(current.precipprob)}%`;
    }

    const precipAmountEl = document.getElementById("stat-precip-amount");
    if (precipAmountEl) {
      precipAmountEl.textContent = formatPrecipitation(
        current.precip,
        this.currentUnit
      );
      precipAmountEl.dataset.precipMm = current.precip;
    }

    // Pressure
    const pressureEl = document.getElementById("stat-pressure");
    if (pressureEl) {
      pressureEl.textContent = formatPressure(current.pressure);
    }

    // Visibility
    const visibilityEl = document.getElementById("stat-visibility");
    if (visibilityEl) {
      visibilityEl.textContent = formatVisibility(
        current.visibility,
        this.currentUnit
      );
      visibilityEl.dataset.visibilityKm = current.visibility;
    }

    // Cloud Cover
    const cloudEl = document.getElementById("stat-clouds");
    if (cloudEl) {
      cloudEl.textContent = `${Math.round(current.cloudcover)}%`;
    }

    // Sunrise & Sunset
    const sunriseEl = document.getElementById("stat-sunrise");
    if (sunriseEl) {
      sunriseEl.textContent = current.sunrise ? current.sunrise.slice(0, 5) : "--";
    }

    const sunsetEl = document.getElementById("stat-sunset");
    if (sunsetEl) {
      sunsetEl.textContent = current.sunset ? current.sunset.slice(0, 5) : "--";
    }
  }

  /**
   * Renders the 24-hour horizontal hourly forecast
   * @param {Array} hourlyList
   */
  async renderHourly(hourlyList) {
    const container = document.getElementById("hourly-track");
    if (!container) return;

    container.innerHTML = "";

    for (const hour of hourlyList) {
      const card = document.createElement("div");
      card.className = "hourly-card";

      const timeSpan = document.createElement("span");
      timeSpan.className = "hourly-time";
      timeSpan.textContent = hour.time;

      const iconImg = document.createElement("img");
      iconImg.className = "hourly-icon";
      iconImg.alt = hour.conditions;
      // Load dynamically
      getWeatherIconUrl(hour.icon).then((url) => {
        if (url) iconImg.src = url;
      });

      const tempSpan = document.createElement("span");
      tempSpan.className = "hourly-temp unit-temp";
      tempSpan.dataset.tempC = hour.temp;
      tempSpan.textContent = formatTemp(hour.temp, this.currentUnit);

      const precipSpan = document.createElement("span");
      precipSpan.className = "hourly-precip";
      if (hour.precipprob > 0) {
        precipSpan.textContent = `${Math.round(hour.precipprob)}%`;
      } else {
        precipSpan.textContent = "0%";
      }

      card.appendChild(timeSpan);
      card.appendChild(iconImg);
      card.appendChild(tempSpan);
      card.appendChild(precipSpan);

      container.appendChild(card);
    }
  }

  /**
   * Renders 7-day daily forecast cards
   * @param {Array} dailyList
   */
  async renderDaily(dailyList) {
    const container = document.getElementById("daily-container");
    if (!container) return;

    container.innerHTML = "";

    for (const day of dailyList) {
      const row = document.createElement("div");
      row.className = "daily-row";

      // Day Name & Short date
      const dayCol = document.createElement("div");
      dayCol.className = "daily-name-col";

      const dayTitle = document.createElement("span");
      dayTitle.className = "daily-day-name";
      dayTitle.textContent = day.dayName;

      const dateSub = document.createElement("span");
      dateSub.className = "daily-date-sub";
      dateSub.textContent = day.shortDate;

      dayCol.appendChild(dayTitle);
      dayCol.appendChild(dateSub);

      // Icon & Condition
      const condCol = document.createElement("div");
      condCol.className = "daily-cond-col";

      const iconImg = document.createElement("img");
      iconImg.className = "daily-icon";
      iconImg.alt = day.conditions;
      getWeatherIconUrl(day.icon).then((url) => {
        if (url) iconImg.src = url;
      });

      const condText = document.createElement("span");
      condText.className = "daily-cond-text";
      condText.textContent = day.conditions;

      condCol.appendChild(iconImg);
      condCol.appendChild(condText);

      // Rain prob
      const rainCol = document.createElement("div");
      rainCol.className = "daily-rain-col";
      if (day.precipprob > 15) {
        rainCol.textContent = `💧 ${Math.round(day.precipprob)}%`;
      } else {
        rainCol.textContent = "";
      }

      // Min/Max Temps
      const tempCol = document.createElement("div");
      tempCol.className = "daily-temp-col";

      const lowSpan = document.createElement("span");
      lowSpan.className = "daily-low unit-temp";
      lowSpan.dataset.tempC = day.tempmin;
      lowSpan.textContent = formatTemp(day.tempmin, this.currentUnit);

      const bar = document.createElement("div");
      bar.className = "daily-temp-bar";
      const barFill = document.createElement("div");
      barFill.className = "daily-temp-bar-fill";
      bar.appendChild(barFill);

      const highSpan = document.createElement("span");
      highSpan.className = "daily-high unit-temp";
      highSpan.dataset.tempC = day.tempmax;
      highSpan.textContent = formatTemp(day.tempmax, this.currentUnit);

      tempCol.appendChild(lowSpan);
      tempCol.appendChild(bar);
      tempCol.appendChild(highSpan);

      row.appendChild(dayCol);
      row.appendChild(condCol);
      row.appendChild(rainCol);
      row.appendChild(tempCol);

      container.appendChild(row);
    }
  }

  /**
   * Instantly recalculates and updates all temperatures, wind speeds, and visibility
   * across all cards when the unit toggle is switched, without refetching from the API
   */
  updateDynamicUnits() {
    // 1. Hero Big Temp
    const heroTemp = document.getElementById("hero-temp");
    if (heroTemp && heroTemp.dataset.tempC !== undefined) {
      heroTemp.textContent = formatTemp(
        parseFloat(heroTemp.dataset.tempC),
        this.currentUnit,
        false
      );
    }

    const heroUnit = document.getElementById("hero-unit");
    if (heroUnit) {
      heroUnit.textContent = `°${this.currentUnit}`;
    }

    // 2. High, Low, Feels like
    const heroHigh = document.getElementById("hero-high");
    if (heroHigh && heroHigh.dataset.tempC !== undefined) {
      heroHigh.textContent = formatTemp(
        parseFloat(heroHigh.dataset.tempC),
        this.currentUnit
      );
    }

    const heroLow = document.getElementById("hero-low");
    if (heroLow && heroLow.dataset.tempC !== undefined) {
      heroLow.textContent = formatTemp(
        parseFloat(heroLow.dataset.tempC),
        this.currentUnit
      );
    }

    const heroFeels = document.getElementById("hero-feels");
    if (heroFeels && heroFeels.dataset.tempC !== undefined) {
      heroFeels.textContent = formatTemp(
        parseFloat(heroFeels.dataset.tempC),
        this.currentUnit
      );
    }

    // 3. Wind speed & Precip
    const windEl = document.getElementById("stat-wind");
    if (windEl && windEl.dataset.windSpeed !== undefined) {
      windEl.textContent = formatWindSpeed(
        parseFloat(windEl.dataset.windSpeed),
        this.currentUnit
      );
    }

    const precipAmountEl = document.getElementById("stat-precip-amount");
    if (precipAmountEl && precipAmountEl.dataset.precipMm !== undefined) {
      precipAmountEl.textContent = formatPrecipitation(
        parseFloat(precipAmountEl.dataset.precipMm),
        this.currentUnit
      );
    }

    const visibilityEl = document.getElementById("stat-visibility");
    if (visibilityEl && visibilityEl.dataset.visibilityKm !== undefined) {
      visibilityEl.textContent = formatVisibility(
        parseFloat(visibilityEl.dataset.visibilityKm),
        this.currentUnit
      );
    }

    // 4. All elements with .unit-temp
    const allTempSpans = document.querySelectorAll(".unit-temp");
    allTempSpans.forEach((el) => {
      if (el.dataset.tempC !== undefined) {
        el.textContent = formatTemp(
          parseFloat(el.dataset.tempC),
          this.currentUnit
        );
      }
    });
  }
}
