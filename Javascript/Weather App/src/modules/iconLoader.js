/**
 * Dynamic Weather Icon Loader using Webpack dynamic imports
 * Demonstrates the Webpack dynamic import feature requested by The Odin Project
 */

// Cache for loaded icon URLs to avoid repeated imports
const iconCache = new Map();

/**
 * Dynamically loads the SVG icon URL corresponding to the weather condition icon name.
 * @param {string} iconName - Visual Crossing icon identifier (e.g. 'clear-day', 'rain', 'partly-cloudy-day')
 * @returns {Promise<string>} - Resolves to the bundled asset URL
 */
export async function getWeatherIconUrl(iconName) {
  const normalized = iconName ? iconName.toLowerCase().trim() : "cloudy";

  if (iconCache.has(normalized)) {
    return iconCache.get(normalized);
  }

  try {
    // Webpack analyzes dynamic imports and splits icons into on-demand chunks
    const iconModule = await import(
      /* webpackChunkName: "icon-[request]" */ `../assets/icons/${normalized}.svg`
    );
    const url = iconModule.default;
    iconCache.set(normalized, url);
    return url;
  } catch (error) {
    console.warn(`Icon "${normalized}" not found, using fallback icon.`, error);
    try {
      const fallback = await import(
        /* webpackChunkName: "icon-cloudy" */ "../assets/icons/cloudy.svg"
      );
      const url = fallback.default;
      iconCache.set(normalized, url);
      return url;
    } catch (fallbackError) {
      console.error("Failed to load fallback icon:", fallbackError);
      return "";
    }
  }
}
