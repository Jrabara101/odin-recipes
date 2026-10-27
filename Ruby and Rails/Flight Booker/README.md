# ✈️ Odin Flight Booker

A full-featured one-way airline ticket booking application built with **Ruby on Rails 7**, designed for [The Odin Project: Ruby on Rails Flight Booker](https://www.theodinproject.com/lessons/ruby-on-rails-flight-booker).

---

## 🎯 Overview & Objectives

This project focuses on advanced Rails forms and checkout workflows:
1. **Screen 1: Search Form (`GET /flights`)**
   - 4 prepopulated collection dropdown menus:
     - Departure Airport (Collection of Airports)
     - Arrival Airport (Collection of Airports)
     - Number of Passengers (1–4)
     - Flight Date (populated strictly from dates with existing flights in the database)
2. **Screen 2: Flight Selection**
   - Smart query parameters (`departure_airport_id` / `departure_code`, `arrival_airport_id` / `arrival_code`, `date`, `num_tickets`).
   - Radio button flight selection submitting via `GET` to `BookingsController#new`.
   - Hidden fields tracking passenger counts.
3. **Screen 3: Passenger Information (`POST /bookings`)**
   - Flight summary card displaying chosen route, date, duration, and airport names.
   - Dynamic nested sub-forms for passenger information using `fields_for :passengers`.
   - Model-level `accepts_nested_attributes_for :passengers` processing in `Booking`.
4. **Screen 4: Confirmation & Boarding Pass (`GET /bookings/:id`)**
   - Unique booking reference code generator (`SKY-XXXXXX`).
   - Digital airline boarding passes rendered for each booked passenger with seat assignments, gates, and print support (`window.print()`).

---

## 🏗️ Data Architecture & Associations

```
   ┌──────────────┐                  ┌──────────────┐
   │   Airport    │                  │   Airport    │
   │ (Departure)  │                  │  (Arrival)   │
   └──────┬───────┘                  └──────┬───────┘
          │                                 │
          │ departing_flights               │ arriving_flights
          ▼                                 ▼
   ┌────────────────────────────────────────────────┐
   │                    Flight                      │
   │  (start_datetime, duration, flight_number)     │
   └──────────────────────┬─────────────────────────┘
                          │ has_many :bookings
                          ▼
   ┌────────────────────────────────────────────────┐
   │                   Booking                      │
   │  (flight_id, booking_reference)                │
   │  accepts_nested_attributes_for :passengers     │
   └──────────────────────┬─────────────────────────┘
                          │ has_many :passengers
                          ▼
   ┌────────────────────────────────────────────────┐
   │                  Passenger                     │
   │  (booking_id, name, email)                     │
   └────────────────────────────────────────────────┘
```

### Models & Associations:
- **`Airport`**:
  - `has_many :departing_flights, class_name: "Flight", foreign_key: "departure_airport_id"`
  - `has_many :arriving_flights, class_name: "Flight", foreign_key: "arrival_airport_id"`
- **`Flight`**:
  - `belongs_to :departure_airport, class_name: "Airport"`
  - `belongs_to :arrival_airport, class_name: "Airport"`
  - `has_many :bookings, dependent: :destroy`
  - `has_many :passengers, through: :bookings`
  - `Flight.search(departure_id, arrival_id, date)` query method.
  - `Flight.available_dates` distinct dates query.
- **`Booking`**:
  - `belongs_to :flight`
  - `has_many :passengers, inverse_of: :booking, dependent: :destroy`
  - `accepts_nested_attributes_for :passengers, allow_destroy: true`
- **`Passenger`**:
  - `belongs_to :booking, inverse_of: :passengers`
  - `has_one :flight, through: :booking`

---

## 🚀 Getting Started

### Prerequisites
- **Ruby**: 3.3+
- **Rails**: 7.2+
- **Bundler**: 2.5+
- **SQLite3**

### Installation & Setup

1. **Clone or Navigate to Directory**:
   ```bash
   cd "Ruby and Rails/Flight Booker"
   ```

2. **Install Dependencies**:
   ```bash
   bundle install
   ```

3. **Prepare Database & Migrations**:
   ```bash
   ruby bin/rails db:prepare
   ```

4. **Seed Database with Sample Flights**:
   ```bash
   ruby bin/rails db:seed
   ```
   *(Or clean replant anytime with `ruby bin/rails db:seed:replant`)*

5. **Start Rails Server**:
   ```bash
   ruby bin/rails server -p 3000
   ```

6. Open your browser and navigate to `http://localhost:3000`.

---

## 🧪 Testing Verification

You can test the models and associations directly in Rails console or runner:
```bash
ruby bin/rails runner "flight = Flight.first; puts flight.departure_airport.code; puts flight.arrival_airport.code; puts Airport.first.departing_flights.count"
```
