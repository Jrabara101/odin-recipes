/**
 * Theme & Visual Experience Manager
 * Dynamically updates page styles, ambient background gradients,
 * and atmospheric animations based on live weather condition data
 */

export const WeatherTheme = {
  CLEAR_DAY: "clear-day",
  CLEAR_NIGHT: "clear-night",
  PARTLY_CLOUDY_DAY: "partly-cloudy-day",
  PARTLY_CLOUDY_NIGHT: "partly-cloudy-night",
  CLOUDY: "cloudy",
  RAIN: "rain",
  STORM: "storm",
  SNOW: "snow",
  WIND: "wind",
  FOG: "fog",
};

/**
 * Maps an API icon or condition string to a high-level UI theme
 * @param {string} iconName
 * @returns {string} Theme key
 */
export function determineTheme(iconName) {
  const icon = (iconName || "").toLowerCase();

  if (icon.includes("thunder") || icon.includes("storm")) {
    return WeatherTheme.STORM;
  }
  if (icon.includes("snow") || icon.includes("ice") || icon.includes("hail") || icon.includes("flurries")) {
    return WeatherTheme.SNOW;
  }
  if (icon.includes("rain") || icon.includes("shower") || icon.includes("drizzle")) {
    return WeatherTheme.RAIN;
  }
  if (icon.includes("wind")) {
    return WeatherTheme.WIND;
  }
  if (icon.includes("fog") || icon.includes("mist") || icon.includes("haze")) {
    return WeatherTheme.FOG;
  }
  if (icon === "clear-night") {
    return WeatherTheme.CLEAR_NIGHT;
  }
  if (icon === "clear-day") {
    return WeatherTheme.CLEAR_DAY;
  }
  if (icon === "partly-cloudy-night") {
    return WeatherTheme.PARTLY_CLOUDY_NIGHT;
  }
  if (icon === "partly-cloudy-day") {
    return WeatherTheme.PARTLY_CLOUDY_DAY;
  }
  if (icon.includes("cloud")) {
    return WeatherTheme.CLOUDY;
  }

  // Fallback
  return WeatherTheme.PARTLY_CLOUDY_DAY;
}

/**
 * Applies the visual theme to the document and manages atmospheric animations
 * @param {string} iconName
 */
export function applyWeatherTheme(iconName) {
  const theme = determineTheme(iconName);
  const body = document.body;

  // Set data-theme attribute on body for CSS styling
  body.setAttribute("data-theme", theme);

  const isNight = iconName.includes("night");
  body.setAttribute("data-time-of-day", isNight ? "night" : "day");

  // Render ambient atmospheric particles
  renderAtmosphericEffects(theme);
}

/**
 * Renders lightweight CSS ambient particles (rain, snow, stars, or subtle light rays)
 * @param {string} theme
 */
function renderAtmosphericEffects(theme) {
  let container = document.getElementById("ambient-particles");
  if (!container) {
    container = document.createElement("div");
    container.id = "ambient-particles";
    container.setAttribute("aria-hidden", "true");
    document.body.prepend(container);
  }

  container.innerHTML = "";
  container.className = `particles-${theme}`;

  if (theme === WeatherTheme.RAIN) {
    // Generate subtle rain streaks
    const dropCount = 28;
    for (let i = 0; i < dropCount; i++) {
      const drop = document.createElement("div");
      drop.className = "rain-drop";
      drop.style.left = `${Math.random() * 100}%`;
      drop.style.animationDuration = `${0.6 + Math.random() * 0.4}s`;
      drop.style.animationDelay = `${Math.random() * 1.5}s`;
      drop.style.opacity = `${0.2 + Math.random() * 0.4}`;
      container.appendChild(drop);
    }
  } else if (theme === WeatherTheme.SNOW) {
    // Generate soft drifting snowflakes
    const flakeCount = 24;
    for (let i = 0; i < flakeCount; i++) {
      const flake = document.createElement("div");
      flake.className = "snow-flake";
      const size = 3 + Math.random() * 5;
      flake.style.width = `${size}px`;
      flake.style.height = `${size}px`;
      flake.style.left = `${Math.random() * 100}%`;
      flake.style.animationDuration = `${3 + Math.random() * 4}s`;
      flake.style.animationDelay = `${Math.random() * 3}s`;
      flake.style.opacity = `${0.3 + Math.random() * 0.6}`;
      container.appendChild(flake);
    }
  } else if (theme === WeatherTheme.CLEAR_NIGHT || theme === WeatherTheme.PARTLY_CLOUDY_NIGHT) {
    // Twinkling stars
    const starCount = 30;
    for (let i = 0; i < starCount; i++) {
      const star = document.createElement("div");
      star.className = "twinkle-star";
      star.style.left = `${Math.random() * 100}%`;
      star.style.top = `${Math.random() * 65}%`;
      const size = 1 + Math.random() * 2.5;
      star.style.width = `${size}px`;
      star.style.height = `${size}px`;
      star.style.animationDelay = `${Math.random() * 3}s`;
      star.style.animationDuration = `${1.5 + Math.random() * 2}s`;
      container.appendChild(star);
    }
  } else if (theme === WeatherTheme.CLEAR_DAY) {
    // Subtle sun ambient bloom
    const glow = document.createElement("div");
    glow.className = "sun-ambient-glow";
    container.appendChild(glow);
  }
}
