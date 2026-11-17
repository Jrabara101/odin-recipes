/**
 * Weather API Service Module
 * Handles HTTP requests to the Visual Crossing Weather API using async/await
 */

const BASE_URL =
  "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline";

/**
 * Fetches raw weather data for a given location query.
 * @param {string} location - City name, zip code, or "lat,lon" coordinates
 * @param {string} [apiKey=""] - Optional personal Visual Crossing API key
 * @returns {Promise<object>} Raw JSON response from Visual Crossing API
 */
export async function fetchRawWeatherData(location, apiKey = "") {
  if (!location || !location.trim()) {
    throw new Error("Please enter a location to search.");
  }

  const cleanLocation = location.trim();
  let url = `${BASE_URL}/${encodeURIComponent(cleanLocation)}?unitGroup=metric&contentType=json`;

  if (apiKey && apiKey.trim()) {
    url += `&key=${encodeURIComponent(apiKey.trim())}`;
  }

  try {
    const response = await fetch(url, {
      method: "GET",
      headers: {
        Accept: "application/json",
      },
    });

    if (!response.ok) {
      const errorText = await response.text();

      if (response.status === 400) {
        if (errorText.toLowerCase().includes("no valid locations")) {
          throw new Error(
            `Location "${cleanLocation}" was not found. Please check spelling or try a larger nearby city.`
          );
        }
        throw new Error(
          `Invalid request: ${errorText || "Could not resolve location."}`
        );
      }

      if (response.status === 429) {
        throw new Error(
          "API query quota reached for today (1,000 queries limit). You can enter a free personal API key in Settings."
        );
      }

      if (response.status === 401 || response.status === 403) {
        throw new Error(
          "API Authentication error. Please verify your custom API key in Settings."
        );
      }

      throw new Error(
        `Weather service responded with status ${response.status}: ${
          errorText || response.statusText
        }`
      );
    }

    const data = await response.json();

    // Log the raw data as requested by The Odin Project instructions
    console.log("Raw Weather API Data for:", cleanLocation, data);

    return data;
  } catch (error) {
    if (error instanceof TypeError && error.message.includes("fetch")) {
      console.error("Network connection error:", error);
      throw new Error(
        "Network connection error. Please check your internet connection."
      );
    }
    console.error("Weather API Error:", error.message);
    throw error;
  }
}
