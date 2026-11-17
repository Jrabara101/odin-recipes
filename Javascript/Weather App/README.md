# WeatherPulse 🌤️

A modern, responsive, and dynamic Weather Forecast application built with Vanilla JavaScript, Webpack 5, and the [Visual Crossing Weather API](https://www.visualcrossing.com/weather-api/) as part of [The Odin Project's JavaScript Curriculum](https://www.theodinproject.com/lessons/javascript-weather-app).

---

## 🌟 Live Features

- **Instant Weather Search**: Search any city, postal code, or geographic coordinates worldwide.
- **Geolocation Integration**: 1-click "Use My Location" to detect coordinates via the browser's Geolocation API.
- **Dynamic Unit Toggling (°C / °F)**: Instant toggle between Celsius and Fahrenheit (including wind speeds in km/h vs. mph and precipitation in mm vs. in) with zero extra API requests.
- **Dynamic Weather Themes**: Adaptive atmospheric backgrounds and color palettes that shift automatically depending on conditions (Clear Day, Clear Night, Partly Cloudy, Overcast, Rain, Thunderstorm, Snow, Fog, Wind).
- **Ambient Visual Effects**: Subtle particle animations for raindrops, snowflakes, and twinkling stars.
- **24-Hour Hourly Forecast**: Smooth horizontal scrolling timeline showing temperature, conditions, and precipitation probability for the next 24 hours.
- **7-Day Extended Forecast**: Detailed daily forecasts with min/max temperatures, visual temperature range bars, and rain chances.
- **Visual Crossing API Integration**: Fully asynchronous requests (`async`/`await`) with comprehensive error handling (location not found, quota alerts, network failures). Works completely out of the box with anonymous queries (up to 1,000 free queries/day) or with an optional user-supplied API key via Settings.
- **Dynamic Imports**: Weather condition icons (SVGs) are bundled and split into on-demand chunks via Webpack dynamic imports (`import()`), optimizing bundle performance.
- **Responsive Glassmorphism Design**: Sleek frosted-glass cards, refined typography, and responsive layouts tailored for mobile, tablet, and desktop screens.
- **Local Persistence**: Saves last searched city, quick search history chips, and unit preferences in `localStorage`.

---

## 🛠️ Tech Stack & Architecture

- **JavaScript (ES6+)**: Modular architecture (`api.js`, `weatherData.js`, `unitConverter.js`, `domController.js`, `themeManager.js`, `iconLoader.js`, `storage.js`).
- **Webpack 5**: Production bundling, asset modules for SVGs, CSS loaders, dynamic chunk splitting, and runtime chunk isolation.
- **date-fns**: Clean ISO date parsing and formatting for relative days and timestamps.
- **CSS3 Modern**: CSS variables, flexbox, CSS grid, glassmorphism (`backdrop-filter`), keyframe animations.
- **Visual Crossing Weather Timeline API**: Rich meteorological data covering current conditions, hourly metrics, and extended daily forecasts.

---

## 📁 Project Structure

```text
Weather App/
├── .gitignore
├── package.json
├── webpack.config.js
├── README.md
├── dist/                          # Production build output
├── src/
│   ├── index.js                   # Application coordinator & event wiring
│   ├── template.html              # Accessible HTML5 template
│   ├── assets/
│   │   └── icons/                 # Crisp custom SVG condition icons
│   │       ├── clear-day.svg
│   │       ├── clear-night.svg
│   │       ├── partly-cloudy-day.svg
│   │       ├── cloudy.svg
│   │       ├── rain.svg
│   │       ├── thunder-rain.svg
│   │       ├── snow.svg
│   │       ├── wind.svg
│   │       ├── fog.svg
│   │       └── ...
│   ├── modules/
│   │   ├── api.js                 # API requests & error handling
│   │   ├── weatherData.js         # JSON sanitization & data shaping
│   │   ├── unitConverter.js       # Metric <-> Imperial conversion utilities
│   │   ├── domController.js       # UI rendering, card updates & state views
│   │   ├── themeManager.js        # Weather-reactive themes & particle effects
│   │   ├── iconLoader.js          # Webpack dynamic imports for weather icons
│   │   └── storage.js             # LocalStorage persistence service
│   └── styles/
│       ├── main.css               # Global layout, typography, glassmorphism
│       ├── theme.css              # Adaptive weather backgrounds
│       ├── weather-card.css       # Hero card, hourly track, daily cards
│       ├── components.css         # Search bar, switch slider, modals, loader
│       └── animations.css         # Keyframe animations & ambient particles
```

---

## 🚀 Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) (v18+ recommended)
- [npm](https://www.npmjs.com/)

### Installation

1. Navigate to the project directory:
   ```bash
   cd "Javascript/Weather App"
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start development server with live reload:
   ```bash
   npm start
   ```
   Or build for production:
   ```bash
   npm run build
   ```

---

## 📖 The Odin Project Assignment Requirements

| Requirement | Implementation |
|---|---|
| **API without key / query builder** | Uses Visual Crossing Weather API anonymous query endpoint (no key required, 1000 free queries/day). Also provides optional custom key input in settings. |
| **Blank HTML document & assets** | Webpack HtmlWebpackPlugin with semantic `template.html`, linking bundled CSS and JS. |
| **API functions with async/await** | Implemented in `api.js` using `async`/`await` and `fetch()`, logging raw response to console. |
| **Data processing function** | Implemented in `weatherData.js`, extracting only required fields into a clean object. |
| **Search form & location input** | Clean search form with autocomplete disabled, search button, and quick-suggest chips. |
| **Display information & unit toggle** | Detailed current weather, 24-hour timeline, 7-day forecast, and instant °C / °F toggle. |
| **Dynamic imports for weather icons** | Implemented in `iconLoader.js` using `import(...)` for Webpack chunk splitting. |
| **Dynamic background / weather styling** | Implemented in `themeManager.js` with condition-specific color palettes and particle animations. |
| **Loading component** | Shimmer skeleton loader and animated spinner while queries resolve. |

---

## 📄 License & Attribution

- Built as part of [The Odin Project](https://www.theodinproject.com).
- Weather data provided by [Visual Crossing Weather API](https://www.visualcrossing.com/weather-api).
