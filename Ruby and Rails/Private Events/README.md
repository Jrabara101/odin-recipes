# 🎟️ Private Events (Ruby on Rails)

A full-featured event hosting and RSVP platform inspired by Eventbrite, built as part of [The Odin Project's Ruby on Rails Curriculum](https://www.theodinproject.com/lessons/ruby-on-rails-private-events).

This project focuses on advanced **ActiveRecord associations**, specifically modeling many-to-many relationships using custom foreign keys, source classes, and association proxies without relying on default conventions.

---

## 🌟 Key Features

- **User Authentication (Devise):** Complete authentication with full name, unique username, email, and secure password handling.
- **Custom ActiveRecord Associations:**
  - `User` has many `created_events` (foreign key: `creator_id`, class: `Event`).
  - `Event` belongs to `creator` (foreign key: `creator_id`, class: `User`).
  - `EventAttendance` join model connecting `attendee` (User) and `attended_event` (Event).
  - `User` has many `attended_events` through `event_attendances`.
  - `Event` has many `attendees` through `event_attendances`.
- **Prepopulated `#build` Association Method:**
  - Events are initialized using `current_user.created_events.build(event_params)` ensuring explicit foreign key binding.
- **Scopes & Date Queries:**
  - `Event.upcoming` and `Event.past` scopes order and filter upcoming vs archive events.
  - In-view querying on `User#show`: `@user.attended_events.where("date >= ?", Time.current)` and `@user.attended_events.where("date < ?", Time.current)`.
- **Private Events & Personal Invitations:**
  - Events can be toggled between **Public** and **Private**.
  - Hosts can invite registered community members to private events via a direct invitation system.
  - Non-attendees cannot view private event details unless invited.
- **Extra Credit Implemented:**
  - ✨ Full event editing and deletion restricted to event creators.
  - ✨ RSVP cancellation (attendees can remove themselves from an event).
  - ✨ Creator privacy toggle (`Make Public` / `Make Private`).
  - ✨ Community member directory with user profile statistics.
- **Modern UI & Aesthetic:**
  - Sleek glassmorphic dark theme with Google Fonts (*Space Grotesk* & *Plus Jakarta Sans*).
  - Glowing status badges, interactive cards, micro-animations, and alert banners.

---

## 📐 Data Architecture

```
+------------------+         +----------------------+         +--------------------+
|      User        |         |   EventAttendance    |         |       Event        |
+------------------+         +----------------------+         +--------------------+
| id               |<---\    | id                   |    /--->| id                 |
| name             |     \---| attendee_id          |   /     | title              |
| username         |         | attended_event_id    |--/      | description        |
| email            |         | status               |         | location           |
| ...              |         +----------------------+         | date               |
|                  |<-----------------------------------------| creator_id         |
+------------------+   (has_many :created_events)             | private (boolean)  |
                                                              +--------------------+
```

### Models & Associations

#### `app/models/user.rb`
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :created_events, class_name: "Event", foreign_key: :creator_id, dependent: :destroy
  has_many :event_attendances, foreign_key: :attendee_id, dependent: :destroy
  has_many :attended_events, through: :event_attendances, source: :attended_event
end
```

#### `app/models/event.rb`
```ruby
class Event < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :event_attendances, foreign_key: :attended_event_id, dependent: :destroy
  has_many :attendees, through: :event_attendances, source: :attendee

  scope :past, -> { where("date < ?", Time.current).order(date: :desc) }
  scope :upcoming, -> { where("date >= ?", Time.current).order(date: :asc) }
  scope :public_events, -> { where(private: false) }
end
```

#### `app/models/event_attendance.rb`
```ruby
class EventAttendance < ApplicationRecord
  belongs_to :attendee, class_name: "User"
  belongs_to :attended_event, class_name: "Event"

  validates :attendee_id, uniqueness: { scope: :attended_event_id }
end
```

---

## 🚀 Getting Started

### 1. Prerequisites
- Ruby 3.3+
- Rails 7.2+
- SQLite3

### 2. Setup & Database Migration
```bash
# Navigate to the project directory
cd "Ruby and Rails/Private Events"

# Install gem dependencies
bundle install

# Run database migrations
rails db:migrate

# Seed demo users, events, and attendances
rails db:seed
```

### 3. Start the Development Server
```bash
rails server
```
Visit `http://localhost:3000` in your web browser.

---

## 🔑 Demo Accounts

The database comes pre-seeded with test accounts (`password123` for all):

| User | Email | Username | Role / Activity |
|---|---|---|---|
| Alice Morgan | `alice@example.com` | `alicem` | Hosts Rooftop BBQ & VIP Jazz Tasting |
| Bob Vance | `bob@example.com` | `bobvance` | Hosts Tech Hackathon & Murder Mystery |
| Carol Danvers | `carol@example.com` | `carold` | Hosts Pizza Making Masterclass |
| David Miller | `david@example.com` | `davidm` | Community Member & Attendee |

---

## 📝 Warmup Exercises
Detailed schema models and association breakdowns for the three warmup scenarios (Pet-Sitting, Dinner Party Invitations, and Social Follow System) can be found in [WARMUP_ASSOCIATIONS_DATA_MODELING.md](../WARMUP_ASSOCIATIONS_DATA_MODELING.md).
