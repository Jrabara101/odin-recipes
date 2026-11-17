/**
 * Unit Converter Utility Module
 * Handles accurate temperature and speed conversions between Metric and Imperial
 */

export const Unit = {
  CELSIUS: "C",
  FAHRENHEIT: "F",
};

/**
 * Converts Celsius to Fahrenheit
 * @param {number} c
 * @returns {number}
 */
export function toFahrenheit(c) {
  if (c === null || c === undefined || isNaN(c)) return null;
  return (c * 9) / 5 + 32;
}

/**
 * Converts Fahrenheit to Celsius
 * @param {number} f
 * @returns {number}
 */
export function toCelsius(f) {
  if (f === null || f === undefined || isNaN(f)) return null;
  return ((f - 32) * 5) / 9;
}

/**
 * Formats a temperature given in Celsius based on current display unit
 * @param {number} tempInC - Temperature in Celsius
 * @param {string} unit - 'C' or 'F'
 * @param {boolean} includeSymbol - Whether to append °C or °F
 * @returns {string}
 */
export function formatTemp(tempInC, unit = Unit.CELSIUS, includeSymbol = true) {
  if (tempInC === null || tempInC === undefined || isNaN(tempInC)) {
    return "--";
  }

  const val = unit === Unit.FAHRENHEIT ? toFahrenheit(tempInC) : tempInC;
  const rounded = Math.round(val);
  return includeSymbol ? `${rounded}°${unit}` : `${rounded}°`;
}

/**
 * Formats wind speed based on active unit
 * @param {number} speedKmH - Wind speed in km/h
 * @param {string} unit - 'C' (metric: km/h) or 'F' (imperial: mph)
 * @returns {string}
 */
export function formatWindSpeed(speedKmH, unit = Unit.CELSIUS) {
  if (speedKmH === null || speedKmH === undefined || isNaN(speedKmH)) {
    return "--";
  }

  if (unit === Unit.FAHRENHEIT) {
    const mph = Math.round(speedKmH * 0.621371);
    return `${mph} mph`;
  }
  return `${Math.round(speedKmH)} km/h`;
}

/**
 * Formats precipitation amount
 * @param {number} precipMm - Precipitation in mm
 * @param {string} unit - 'C' (metric: mm) or 'F' (imperial: in)
 * @returns {string}
 */
export function formatPrecipitation(precipMm, unit = Unit.CELSIUS) {
  if (precipMm === null || precipMm === undefined || isNaN(precipMm) || precipMm < 0) {
    return "0 mm";
  }

  if (unit === Unit.FAHRENHEIT) {
    const inches = (precipMm / 25.4).toFixed(2);
    return `${inches} in`;
  }
  return `${precipMm.toFixed(1)} mm`;
}

/**
 * Formats atmospheric pressure
 * @param {number} hPa - Pressure in hPa
 * @returns {string}
 */
export function formatPressure(hPa) {
  if (!hPa && hPa !== 0) return "--";
  return `${Math.round(hPa)} hPa`;
}

/**
 * Formats visibility
 * @param {number} km - Visibility in km
 * @param {string} unit - 'C' or 'F'
 * @returns {string}
 */
export function formatVisibility(km, unit = Unit.CELSIUS) {
  if (!km && km !== 0) return "--";
  if (unit === Unit.FAHRENHEIT) {
    const miles = (km * 0.621371).toFixed(1);
    return `${miles} mi`;
  }
  return `${km.toFixed(1)} km`;
}
