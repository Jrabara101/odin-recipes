# Warmup: Thinking Data First — Data Modeling Solutions

This document covers the data modeling solutions for the scenarios presented in The Odin Project's **Micro-Reddit** lesson.

---

## Scenario 1: Online Learning Platform

> *You are building an online learning platform (much like The Odin Project!). You’ve got many different courses, each with a title and description, and each course has multiple lessons. Lesson content consists of a title and body text.*

### Models & Schema

#### `Course`
- `id`: integer (primary key)
- `title`: string
- `description`: text
- `created_at`: datetime
- `updated_at`: datetime

**Validations:**
- `title`: presence, uniqueness (case-insensitive), length (max 120 chars)
- `description`: presence, length (minimum 10 chars)

**Associations:**
- `has_many :lessons, dependent: :destroy`

---

#### `Lesson`
- `id`: integer (primary key)
- `title`: string
- `body`: text
- `course_id`: integer (foreign key, indexed)
- `position`: integer (optional: order of lesson within course)
- `created_at`: datetime
- `updated_at`: datetime

**Validations:**
- `title`: presence, length (max 150 chars)
- `body`: presence
- `course_id`: presence (enforced by `belongs_to :course` in Rails 5+)
- `position`: numericality (only_integer: true, greater_than: 0, optional: true)

**Associations:**
- `belongs_to :course`

---

## Scenario 2: User Profile Tab

> *You are building the profile tab for a new user on your site. You are already storing your user’s username and email, but now you want to collect demographic information like city, state, country, age and gender. Think – how many profiles should a user have? How would you relate this to the User model?*

### Thought Process:
- A user typically has **exactly one** profile (`1:1` relationship).
- Keeping core authentication data (`User`) separate from demographic details (`Profile`) keeps the `users` table fast and focused.
- Normalization: In a small app, `city`, `state`, and `country` can be simple string columns on `Profile`. In a large production app, normalising `Country` and `State`/`City` into separate lookup tables prevents typos and enables dropdown selections. Below shows both the 1:1 Profile model and normalized location tables.

### Models & Schema

#### `User`
- `id`: integer (primary key)
- `username`: string
- `email`: string
- `created_at`: datetime
- `updated_at`: datetime

**Validations:**
- `username`: presence, uniqueness, length (3..20 chars)
- `email`: presence, uniqueness, format (valid email regex)

**Associations:**
- `has_one :profile, dependent: :destroy`

---

#### `Profile`
- `id`: integer (primary key)
- `user_id`: integer (foreign key, unique index)
- `age`: integer
- `gender`: string
- `city`: string
- `state`: string
- `country`: string
- `bio`: text (optional)
- `created_at`: datetime
- `updated_at`: datetime

**Validations:**
- `user_id`: presence, uniqueness (ensures strict 1:1)
- `age`: numericality (only_integer: true, greater_than_or_equal_to: 13, less_than_or_equal_to: 125, allow_nil: true)
- `gender`: inclusion (in: %w[Female Male Non-binary Prefer-not-to-say Other], allow_blank: true)

**Associations:**
- `belongs_to :user`

*(Optional Normalized Extension: `belongs_to :country`, `belongs_to :state`, `belongs_to :city`)*

---

## Scenario 3: Virtual Pinboard (Pinterest Clone)

> *You want to build a virtual pinboard, so you’ll have users on your platform who can create “pins”. Each pin will contain the URL to an image on the web. Users can comment on pins (but can’t comment on comments).*

### Models & Schema

#### `User`
- `id`: integer (primary key)
- `username`: string
- `email`: string
- `created_at`: datetime
- `updated_at`: datetime

**Validations:**
- `username`: presence, uniqueness
- `email`: presence, uniqueness

**Associations:**
- `has_many :pins, dependent: :destroy`
- `has_many :comments, dependent: :destroy`

---

#### `Pin`
- `id`: integer (primary key)
- `title`: string
- `image_url`: string
- `user_id`: integer (foreign key, indexed)
- `created_at`: datetime
- `updated_at`: datetime

**Validations:**
- `title`: presence, length (max 100 chars)
- `image_url`: presence, format (valid URL regex / URI::DEFAULT_PARSER)
- `user_id`: presence

**Associations:**
- `belongs_to :user`
- `has_many :comments, dependent: :destroy`

---

#### `Comment`
- `id`: integer (primary key)
- `body`: text
- `user_id`: integer (foreign key, indexed)
- `pin_id`: integer (foreign key, indexed)
- `created_at`: datetime
- `updated_at`: datetime

**Validations:**
- `body`: presence, length (minimum 1, maximum 1000)
- `user_id`: presence
- `pin_id`: presence

**Associations:**
- `belongs_to :user`
- `belongs_to :pin`

---

## Scenario 4: Message Board with Nested Comments (Hacker News Clone)

> *You want to build a message board like Hacker News. Users can post links. Other users can comment on these submissions or comment on the comments. How would you make sure a comment knows where in the hierarchy it lives?*

### Thought Process on Hierarchy:
To allow comments on comments (trees/threads):
1. **Self-Referential Association (Adjacency List):** Each comment has a `parent_id` pointing to another `Comment` (or `nil` if it is a root comment).
2. **Direct Post Reference:** Each comment also keeps `post_id` so all comments for a post can be fetched with a single query `WHERE post_id = ?`, and then organized into a tree in memory or through recursive CTEs.
3. **Alternative (Polymorphic `commentable`):** A comment `belongs_to :commentable, polymorphic: true`, where `commentable` can be either a `Post` or a `Comment`.

### Models & Schema (Adjacency List Approach)

#### `User`
- `id`: integer
- `username`: string
- `email`: string
- `created_at`: datetime
- `updated_at`: datetime

**Associations:**
- `has_many :posts, dependent: :destroy`
- `has_many :comments, dependent: :destroy`

---

#### `Post`
- `id`: integer
- `title`: string
- `url`: string (optional if it's an "Ask HN" text post)
- `text`: text (optional body)
- `user_id`: integer (foreign key, indexed)
- `created_at`: datetime
- `updated_at`: datetime

**Validations:**
- `title`: presence, length (max 200 chars)
- `url`: format (valid URL, allow_blank: true)
- `user_id`: presence

**Associations:**
- `belongs_to :user`
- `has_many :comments, dependent: :destroy`

---

#### `Comment`
- `id`: integer
- `body`: text
- `user_id`: integer (foreign key, indexed)
- `post_id`: integer (foreign key, indexed)
- `parent_id`: integer (foreign key to `comments.id`, indexed, nullable)
- `created_at`: datetime
- `updated_at`: datetime

**Validations:**
- `body`: presence, length (minimum 1)
- `user_id`: presence
- `post_id`: presence

**Associations:**
- `belongs_to :user`
- `belongs_to :post`
- `belongs_to :parent, class_name: "Comment", optional: true`
- `has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy`

---
