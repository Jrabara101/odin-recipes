# 📸 Odin Pexels API: Photo Gallery Widget

A modern, responsive Ruby on Rails application integrating directly with the **Pexels REST API v1**, created for [The Odin Project: Ruby on Rails - Pexels API](https://www.theodinproject.com/lessons/ruby-on-rails-pexels-api).

---

## 🌟 Overview

The Odin Project's **Pexels API** project focuses on consuming third-party external REST APIs from a Rails backend using an HTTP client gem (`HTTParty`), safely managing API secrets, decoupling external network logic from ActiveRecord models into a dedicated **Service Object** (`PexelsClient`), and building an interactive front-end widget that dynamically renders media from user collections.

---

## 🎯 Key Objectives & Features Achieved

### 1. Dedicated Service Object (`app/services/pexels_client.rb`)
- **Clean Architectural Separation**: Rails does not prescribe a single location for non-ActiveRecord external services. Rather than bloating controllers or misusing database models, network integration is encapsulated inside `app/services/pexels_client.rb` (autoloaded by Rails 7 Zeitwerk).
- **HTTP Client**: Implemented using the reliable, battle-tested `HTTParty` gem with strict timeouts (10s), headers (`Authorization`, custom `User-Agent`), and query string building.
- **Smart URL & ID Extractor**:
  Users can input either a bare collection ID (e.g., `adkmjqz`), a slug (`nature-photos-adkmjqz`), or paste a full Pexels web URL (`https://www.pexels.com/collections/nature-photos-adkmjqz/`). `PexelsClient.extract_collection_id` extracts and normalizes the target ID automatically.
- **Resilient Error Handling**:
  - `401 Unauthorized`: Detects missing or invalid API keys and guides the user to `.env`.
  - `404 Not Found`: Alerts if a collection ID does not exist or is marked private.
  - `429 Rate Limited`: Alerts if the free-tier hourly limit (200 reqs/hr) is reached.
  - `Timeouts & Network Failures`: Catches socket errors gracefully without crashing the server.

### 2. Secret Key Management & Zero-Leak Security
- Complies with strict security best practices: **API keys are never hardcoded**.
- Powered by `dotenv-rails`: automatically loads environment variables from `.env` in development/test.
- Also supports native Rails Encrypted Credentials (`Rails.application.credentials.dig(:pexels, :api_key)`).
- `.env` and master keys are strictly excluded via `.gitignore`.
- An `.env.example` file is included for quick onboarding.

### 3. Interactive Front-End Photo Gallery Widget
- **Collection Search Box**: Single text field accepting either a collection ID or full URL.
- **Zero-Layout-Shift Placeholders**: Leverages Pexels' `avg_color` metadata to render tinted background blocks immediately before image bytes finish downloading.
- **Full Attribution & Compliance**:
  - Clear links to the photographer's Pexels profile.
  - Official Pexels logo attribution and direct link to the original photo on Pexels.
  - Alt-text captions for accessibility.
- **Interactive Lightbox Modal**: Click any photo card or expand button to open a high-resolution preview with photographer details, dimensions, and download actions.
- **Pagination Navigation**: Supports Previous/Next page controls (`?page=...&per_page=...`).
- **Sample Demo Mode**: Allows immediate testing with 1-click sample collections even if the developer has not yet generated a Pexels API key.
- **Dual-Format Support**: Supports standard HTML and JSON formats (e.g. `GET /?demo=1` with `Accept: application/json`).

---

## 🗂️ Project Architecture

```
Pexels API/
├── app/
│   ├── assets/
│   │   └── stylesheets/
│   │       └── application.css            # Responsive CSS grid, lightbox, and sleek Pexels styling
│   ├── controllers/
│   │   └── static_pages_controller.rb     # Handles search params, pagination, and client delegation
│   ├── services/
│   │   └── pexels_client.rb               # Service class consuming Pexels REST API v1 via HTTParty
│   └── views/
│       ├── layouts/
│       │   └── application.html.erb       # Base layout with typography and metadata
│       └── static_pages/
│           └── home.html.erb              # Hero, search form, alert banners, photo grid, and lightbox
├── config/
│   ├── environments/
│   │   └── test.rb                        # Configured with Sprockets in-memory cache for Windows compatibility
│   └── routes.rb                          # root "static_pages#home"
├── test/
│   ├── controllers/
│   │   └── static_pages_controller_test.rb# Integration tests for views, parameters, and JSON responses
│   └── services/
│       └── pexels_client_test.rb          # Unit tests for URL parsing, errors, and mock HTTP responses
├── .env.example                           # Template for PEXELS_API_KEY
├── .gitignore                             # Secret exclusions
└── Gemfile                                # Rails 7.2, HTTParty, dotenv-rails
```

---

## 🚀 Getting Started

### 1. Prerequisites
- **Ruby**: 3.3+
- **Rails**: 7.2+
- **Bundler**: 2.5+

### 2. Installation
1. Navigate to the project directory:
   ```bash
   cd "Ruby and Rails/Pexels API"
   ```

2. Install gem dependencies:
   ```bash
   bundle install
   ```

### 3. Setting Up Your Pexels API Key
1. Sign up for a free account at [Pexels](https://www.pexels.com/).
2. Navigate to [Pexels API Key Request](https://www.pexels.com/api/key/) and generate your API key.
3. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
4. Open `.env` and paste your key:
   ```env
   PEXELS_API_KEY=your_actual_pexels_api_key_here
   ```

*(Note: Even without an API key, you can still test the complete UI and widget functionality using the built-in "Sample Demo Collection" button!)*

### 4. Running the Rails Server
Start the local Puma server:
```bash
bin/rails server
```
Or:
```bash
bundle exec rails server -p 3000
```
Visit `http://localhost:3000` in your browser.

---

## 🧪 Running the Automated Test Suite

The application includes unit tests for the service object and integration tests for the controller and views:

```bash
bundle exec rails test
```

### Test Coverage Highlights:
- **18 runs, 63 assertions, 0 failures, 0 errors, 0 skips**.
- Extraction of collection IDs from plain IDs, nested slugs, and full URLs with query parameters and anchor fragments.
- Missing and present API key detection.
- Demo mode fallback behavior and data integrity.
- Simulated HTTP `404 Not Found` and `429 Rate Limit` handling.
- Controller integration with search queries, pagination, and JSON payloads.

---

## 📖 How It Works

1. **User Input**: The user enters a Pexels Collection ID (e.g. `adkmjqz`) or a full URL (`https://www.pexels.com/collections/nature-adkmjqz/`) in the search field.
2. **Controller Processing**: `StaticPagesController#home` calls `PexelsClient.extract_collection_id` to sanitize and normalize the input.
3. **API Request**: `PexelsClient#collection_media` sends an authenticated `GET` request to:
   ```http
   GET https://api.pexels.com/v1/collections/{collection_id}?type=photos&page={page}&per_page={per_page}
   Authorization: <PEXELS_API_KEY>
   ```
4. **View Rendering**:
   - The photo grid renders each photo with its photographer credit, Pexels profile link, average color placeholder, dimensions, and alt text.
   - Users can click on any card to open a full-resolution modal lightbox.
   - If an error occurs (such as an invalid collection ID or bad API key), a friendly troubleshooting alert is displayed with direct solutions.

---

## 📜 Attribution

Photos displayed in this application are provided by [Pexels](https://www.pexels.com) and the photographers who publish their work under the [Pexels License](https://www.pexels.com/license/).
