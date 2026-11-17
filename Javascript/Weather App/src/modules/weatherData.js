/**
 * Weather Data Processing Module
 * Transforms raw Visual Crossing API response into a clean, minimal data structure
 * As requested by The Odin Project: "return an object with only the data you require for your app"
 */

import { format, parseISO, isToday, isTomorrow } from "date-fns";

/**
 * Formats a date string (YYYY-MM-DD) into a friendly day name
 * @param {string} dateString
 * @returns {string} e.g. "Today", "Tomorrow", "Wednesday"
 */
function getFriendlyDayName(dateString) {
  try {
    const parsedDate = parseISO(dateString);
    if (isToday(parsedDate)) return "Today";
    if (isTomorrow(parsedDate)) return "Tomorrow";
    return format(parsedDate, "EEEE");
  } catch {
    return dateString;
  }
}

/**
 * Formats date into short display (e.g. "Nov 17")
 * @param {string} dateString
 * @returns {string}
 */
function getShortDate(dateString) {
  try {
    return format(parseISO(dateString), "MMM d");
  } catch {
    return dateString;
  }
}

/**
 * Converts 24h time ("14:00:00") into friendly 12h or 24h time ("2 PM")
 * @param {string} timeString
 * @returns {string}
 */
function formatHourTime(timeString) {
  if (!timeString) return "";
  const parts = timeString.split(":");
  if (parts.length < 2) return timeString;
  const hour = parseInt(parts[0], 10);
  const period = hour >= 12 ? "PM" : "AM";
  const hour12 = hour % 12 === 0 ? 12 : hour % 12;
  return `${hour12} ${period}`;
}

/**
 * Filters and combines hourly forecast to provide the upcoming 24 hours of data
 * @param {Array} days
 * @param {string} currentTimeStr
 * @returns {Array} 24 hourly forecast objects
 */
function extractNext24Hours(days, currentTimeStr) {
  if (!days || !days.length) return [];

  const allHours = [];
  let currentHour = 0;

  if (currentTimeStr) {
    const [h] = currentTimeStr.split(":");
    currentHour = parseInt(h, 10) || 0;
  }

  // Today's remaining hours
  const today = days[0];
  if (today && Array.isArray(today.hours)) {
    const remainingToday = today.hours.filter((h) => {
      const [hourVal] = (h.datetime || "00:00:00").split(":");
      return parseInt(hourVal, 10) >= currentHour;
    });
    allHours.push(...remainingToday);
  }

  // Tomorrow's hours to fill 24 hours
  const tomorrow = days[1];
  if (tomorrow && Array.isArray(tomorrow.hours)) {
    allHours.push(...tomorrow.hours);
  }

  return allHours.slice(0, 24).map((h) => ({
    time: formatHourTime(h.datetime),
    rawTime: h.datetime,
    temp: h.temp !== undefined ? h.temp : null,
    feelslike: h.feelslike !== undefined ? h.feelslike : null,
    humidity: h.humidity || 0,
    precip: h.precip || 0,
    precipprob: h.precipprob || 0,
    windspeed: h.windspeed || 0,
    conditions: h.conditions || "Clear",
    icon: h.icon || "clear-day",
  }));
}

/**
 * Process the JSON data and return an object with only the required fields
 * @param {object} raw - Raw JSON returned by Visual Crossing API
 * @returns {object} Clean, tailored weather data object
 */
export function processWeatherData(raw) {
  if (!raw || !raw.currentConditions) {
    throw new Error("Invalid weather data format received from API.");
  }

  const { resolvedAddress, timezone, latitude, longitude, currentConditions, days } =
    raw;

  const today = days && days.length > 0 ? days[0] : {};

  // Clean current weather data
  const current = {
    datetime: currentConditions.datetime,
    temp: currentConditions.temp,
    feelslike:
      currentConditions.feelslike !== undefined
        ? currentConditions.feelslike
        : currentConditions.temp,
    tempmax: today.tempmax !== undefined ? today.tempmax : currentConditions.temp,
    tempmin: today.tempmin !== undefined ? today.tempmin : currentConditions.temp,
    humidity: currentConditions.humidity !== undefined ? currentConditions.humidity : 0,
    precip: currentConditions.precip !== null ? currentConditions.precip : 0,
    precipprob:
      currentConditions.precipprob !== undefined
        ? currentConditions.precipprob
        : today.precipprob || 0,
    windspeed:
      currentConditions.windspeed !== undefined ? currentConditions.windspeed : 0,
    winddir: currentConditions.winddir || 0,
    windgust: currentConditions.windgust || 0,
    pressure: currentConditions.pressure || 1013,
    visibility:
      currentConditions.visibility !== undefined ? currentConditions.visibility : 10,
    cloudcover: currentConditions.cloudcover || 0,
    uvindex:
      currentConditions.uvindex !== undefined
        ? currentConditions.uvindex
        : today.uvindex || 0,
    conditions: currentConditions.conditions || "Clear",
    icon: currentConditions.icon || "clear-day",
    sunrise: today.sunrise || "06:00:00",
    sunset: today.sunset || "18:00:00",
  };

  // Next 7 days forecast
  const forecastDays = (days || []).slice(0, 7).map((day) => ({
    date: day.datetime,
    dayName: getFriendlyDayName(day.datetime),
    shortDate: getShortDate(day.datetime),
    tempmax: day.tempmax,
    tempmin: day.tempmin,
    temp: day.temp,
    feelslike: day.feelslike,
    humidity: day.humidity || 0,
    precip: day.precip || 0,
    precipprob: day.precipprob || 0,
    windspeed: day.windspeed || 0,
    conditions: day.conditions || "Clear",
    icon: day.icon || "clear-day",
    sunrise: day.sunrise,
    sunset: day.sunset,
  }));

  // Hourly forecast for next 24 hours
  const hourly = extractNext24Hours(days, currentConditions.datetime);

  const processed = {
    location: {
      address: resolvedAddress || "Unknown Location",
      timezone: timezone || "UTC",
      lat: latitude,
      lon: longitude,
    },
    current,
    forecastDays,
    hourly,
  };

  console.log("Processed Weather Model:", processed);
  return processed;
}
