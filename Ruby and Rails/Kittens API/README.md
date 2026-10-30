# 🐱 Odin Kittens API: The RESTful Kitten Sanctuary

A full-featured Ruby on Rails application serving as both an interactive web application and a dual-format **RESTful API**, created for [The Odin Project: Ruby on Rails Kittens API](https://www.theodinproject.com/lessons/ruby-on-rails-kittens-api).

---

## 📖 Overview

The goal of this project is to build a vanilla Rails resource that produces both standard HTML views for browser users and clean JSON data payloads for API consumers. This mirrors real-world production architectures where a single backend powers web interfaces, mobile apps, and third-party developer integrations.

### Key Objectives Achieved:
1. **Full RESTful Resource**: All 7 RESTful actions implemented (`index`, `show`, `new`, `create`, `edit`, `update`, `destroy`).
2. **Default Root Route**: Application root routes directly to `kittens#index`.
3. **Dual-Format `respond_to`**:
   - `GET /kittens` renders HTML cards or returns JSON array of all kittens.
   - `GET /kittens/:id` renders full kitten profile or returns single kitten JSON.
   - Supports both `Accept: application/json` headers and direct `.json` extensions.
4. **Interactive In-Browser API Explorer**:
   - Live tabbed code snippets for **Ruby HTTParty**, **cURL**, **JavaScript fetch()**, and a **Live JSON Payload** inspector.
5. **Kittenfloof & Cuteness Rating System**:
   - Model-level numericality and presence validations.
   - Dynamic softness and cuteness gauge meters.
6. **Playful Flash Messaging**:
   - Celebrates successful additions, makeovers, and adoptions.
   - Playfully roasts the user when form validations fail (e.g. typos, unrealistic age parameters).
7. **Direct Delete Links Everywhere**:
   - Delete buttons with Turbo confirmation dialogs on the **Index** page (next to each kitten card), **Show** page, and **Edit** page.

---

## 🏗️ Architecture & Data Model

### Database Schema (`kittens` table):
| Column | Type | Constraints / Validations | Description |
| :--- | :--- | :--- | :--- |
| `id` | `integer` | Primary Key, Auto-increment | Unique identifier |
| `name` | `string` | `presence: true`, max 50 chars | Kitten name |
| `age` | `integer` | `0 <= age <= 35`, integer | Age in years (0 for babies < 1 year) |
| `cuteness`| `integer` | `1 <= cuteness <= 10` | Cuteness quotient (1–10) |
| `softness`| `integer` | `1 <= softness <= 10` | Floofiness / fur texture index (1–10) |
| `created_at` | `datetime` | Managed by Rails | Sanctuary registration timestamp |
| `updated_at` | `datetime` | Managed by Rails | Last profile update timestamp |

### RESTful Routing Map:
| Verb | Path | Controller#Action | Format Support | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/` | `kittens#index` | HTML / JSON | Default root: lists all kittens |
| `GET` | `/kittens` | `kittens#index` | HTML / JSON | Index catalog of all kittens |
| `GET` | `/kittens/:id` | `kittens#show` | HTML / JSON | Detailed profile of a single kitten |
| `GET` | `/kittens/new` | `kittens#new` | HTML | Registration form |
| `POST`| `/kittens` | `kittens#create` | HTML | Adds kitten to sanctuary |
| `GET` | `/kittens/:id/edit`| `kittens#edit` | HTML | Profile editor (includes delete action) |
| `PATCH`| `/kittens/:id`| `kittens#update` | HTML | Updates kitten attributes |
| `DELETE`| `/kittens/:id`| `kittens#destroy` | HTML | De-registers kitten from sanctuary |

---

## ⚡ API Usage & Testing with HTTParty

The project includes the `httparty` gem in the `Gemfile` for testing API endpoints from the console or external scripts.

### 1. Launch the Rails Server
```bash
bundle exec rails server -p 3000
```

### 2. Open Rails Console
```bash
bundle exec rails console
```

### 3. Query Endpoints via HTTParty
```ruby
require 'httparty'

# --- 1. Fetching HTML (Default Content-Type) ---
response = HTTParty.get("http://localhost:3000/kittens")
puts response.code    #=> 200
puts response.headers['content-type'] #=> "text/html; charset=utf-8"

# --- 2. Fetching All Kittens as JSON ---
json_response = HTTParty.get("http://localhost:3000/kittens", headers: { 'Accept' => 'application/json' })
puts json_response.body
# Or access parsed Ruby hash/array:
kittens = json_response.parsed_response
puts "Total kittens: #{kittens.length}"
puts "First kitten: #{kittens.first['name']} (Cuteness: #{kittens.first['cuteness']}/10)"

# --- 3. Fetching a Single Kitten by ID as JSON ---
kitten_response = HTTParty.get("http://localhost:3000/kittens/1", headers: { 'Accept' => 'application/json' })
kitten = kitten_response.parsed_response
puts "Kitten: #{kitten['name']}"
puts "Floof level: #{kitten['softness_label']}"
puts "Cuteness badge: #{kitten['cuteness_label']}"

# --- 4. Direct .json URL Alternative ---
alt_response = HTTParty.get("http://localhost:3000/kittens.json")
puts alt_response.parsed_response
```

---

## 💻 Testing with cURL & Frontend JavaScript

### Using cURL:
```bash
# Query all kittens JSON:
curl -i -H "Accept: application/json" http://localhost:3000/kittens

# Query single kitten JSON:
curl -i -H "Accept: application/json" http://localhost:3000/kittens/1

# Alternatively query with .json suffix:
curl -i http://localhost:3000/kittens.json
curl -i http://localhost:3000/kittens/1.json
```

### Using Frontend JavaScript (`fetch`):
```javascript
// Retrieve all kittens
fetch('/kittens.json')
  .then(response => response.json())
  .then(data => {
    console.log("Kittens API payload:", data);
    console.table(data);
  });

// Retrieve single kitten
fetch('/kittens/1.json')
  .then(response => response.json())
  .then(kitten => {
    console.log(`Retrieved ${kitten.name}:`, kitten);
  });
```

---

## 🧪 Automated Test Suite

A complete test suite is provided covering all model validations and controller integration scenarios:

```bash
bundle exec rails test
```

### Test Coverage Highlights:
- **`KittenTest`** (`test/models/kitten_test.rb`):
  - Validates presence of `name` and maximum character length.
  - Validates `age` between 0 and 35 years.
  - Validates `cuteness` rating between 1 and 10.
  - Validates `softness` floof scale between 1 and 10.
  - Validates custom `as_json` serialization formatting and computed labels.
- **`KittensControllerTest`** (`test/controllers/kittens_controller_test.rb`):
  - Tests HTML index and JSON index (`Accept` header & `.json` format).
  - Tests HTML show and JSON show.
  - Tests new form rendering.
  - Tests successful kitten creation with celebratory flash notice.
  - Tests invalid creation handling (`422 Unprocessable Entity`) with humorous error flash.
  - Tests edit form rendering and delete link presence.
  - Tests update and validation rejections.
  - Tests kitten destruction and redirection.

---

## 🚀 Getting Started Locally

```bash
# 1. Install dependencies
bundle install

# 2. Setup database and run migrations
bundle exec rails db:migrate

# 3. Seed initial kitten residents
bundle exec rails db:seed

# 4. Start the server
bundle exec rails server -p 3000

# 5. Visit the application in your browser:
# http://localhost:3000
```

---

## 🔗 Project Links
- [The Odin Project: Kittens API Lesson](https://www.theodinproject.com/lessons/ruby-on-rails-kittens-api)
- [Flickr API Documentation Reference](http://www.flickr.com/services/api/)
