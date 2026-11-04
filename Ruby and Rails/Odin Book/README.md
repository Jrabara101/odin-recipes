# OdinBook 📘

A feature-rich Facebook/Threads clone built with Ruby on Rails 7 as part of [The Odin Project's Ruby on Rails Curriculum: Odin Book](https://www.theodinproject.com/lessons/ruby-on-rails-odin-book).

---

## 🚀 Features

- **Authentication & Authorization**:
  - Secure user sign-up, sign-in, and session management using the **Devise** gem.
  - Protected application routes: users must sign in before accessing the feed, profiles, users directory, or interactions.
- **Profiles & Avatars**:
  - Profile page containing user information (name, bio, join date, friends count, posts count).
  - Profile picture support with **Active Storage** photo uploads and automatic **Gravatar** fallback.
  - Profile edit page to update name, username, bio, and avatar.
- **Friendships & Follow Requests**:
  - Send, accept, reject, and cancel friend/follow requests.
  - Two-way mutual friendship model.
  - Notification badge on navbar showing pending incoming requests count.
  - Dedicated "People & Connections" page (`/users`) with filter tabs: **All Users**, **My Friends**, and **Requests (Received & Sent)**.
  - Interactive status badges: *Add Friend*, *Requested (Cancel)*, *Confirm / Delete*, and *Friends (Unfriend)*.
- **Newsfeed & Posts**:
  - Dynamic root feed displaying recent posts from the current user and their friends.
  - Post composer ("What's on your mind?") supporting text and optional photo uploads via Active Storage.
  - Post card displaying author avatar, name, relative timestamp, content, attached image, like count, and comments.
- **Likes**:
  - Users can like and unlike posts.
  - Enforced database uniqueness (a user cannot like the same post more than once).
- **Comments**:
  - Users can comment on any post.
  - Authors can delete their own comments (post owners can also moderate comments on their posts).
- **Action Mailer & Welcome Emails**:
  - Welcome email automatically triggered upon user registration.
  - Configured with `letter_opener` in development mode to immediately preview sent emails in your browser.
- **Database Architecture**:
  - SQLite3 for zero-setup local development and testing on Windows.
  - Production-ready PostgreSQL configuration via `config/database.yml` and `gem "pg"` for cloud deployment (Render, Heroku, Fly.io, Railway).
- **Comprehensive Automated Test Suite**:
  - 28 unit and integration tests covering models, associations, friendship lifecycle, feed filtering, likes uniqueness, and authentication guards.

---

## 🛠️ Tech Stack

- **Ruby**: 3.3.12
- **Rails**: 7.2.4
- **Database**: SQLite3 (development & test) / PostgreSQL (production)
- **Frontend**: Hotwire (Turbo + Stimulus), Importmaps, Modern CSS (Responsive 3-column / 2-column Facebook UI)
- **File Storage**: Active Storage (Local disk storage)
- **Authentication**: Devise
- **Testing**: Minitest (`rails test`)
- **Email**: Action Mailer + `letter_opener`

---

## 👥 Demo Accounts (Pre-seeded)

You can instantly log in using any of the following accounts (seeded via `rails db:seed`):

| Name | Email | Password | Role / State |
| :--- | :--- | :--- | :--- |
| **Alice Johnson** | `alice@example.com` | `password123` | Main feed with friends (Bob & Charlie) + pending request from Evan |
| **Bob Smith** | `bob@example.com` | `password123` | Friend of Alice and Diana |
| **Charlie Brown** | `charlie@example.com` | `password123` | Friend of Alice |
| **Diana Prince** | `diana@example.com` | `password123` | Friend of Bob; pending request from Alice |
| **Evan Wright** | `evan@example.com` | `password123` | New user with pending request sent to Alice |

---

## 💻 Getting Started Locally

### 1. Install Dependencies
```bash
bundle install
```

### 2. Set Up the Database & Seed Sample Data
```bash
rails db:migrate
rails db:seed
```

### 3. Run the Rails Server
```bash
rails server
```
Open your browser and navigate to `http://localhost:3000`.

### 4. Run the Test Suite
```bash
rails test
```

---

## 🌐 Deploying to Production (Render / Fly.io / Heroku)

1. Ensure your production environment provides a PostgreSQL database and sets `DATABASE_URL`.
2. Set `RAILS_MASTER_KEY` or provide credentials.
3. Precompile assets and run database migrations:
   ```bash
   bundle exec rails assets:precompile
   bundle exec rails db:migrate
   ```
