# Micro-Reddit 🚀

A lightweight Reddit data model clone built with **Ruby 3.3** and **Ruby on Rails 7.2**, following [The Odin Project's Ruby on Rails Curriculum](https://www.theodinproject.com/lessons/ruby-on-rails-micro-reddit).

This project focuses on Active Record data modeling, schema migrations, validations, and associations (`has_many`, `belongs_to`, and cascading deletes) without front-end overhead.

---

## 🗄️ Data Models & Schema

### 1. `User`
- **Columns**:
  - `id`: integer (PK)
  - `username`: string (unique, indexed, null: false)
  - `email`: string (unique, indexed, null: false)
  - `created_at`, `updated_at`: datetime
- **Validations**:
  - `username`: presence, uniqueness (case-insensitive), length between 4 and 20 characters
  - `email`: presence, uniqueness (case-insensitive), valid email format regex
- **Associations**:
  - `has_many :posts, dependent: :destroy`
  - `has_many :comments, dependent: :destroy`

### 2. `Post`
- **Columns**:
  - `id`: integer (PK)
  - `title`: string (null: false)
  - `url`: string (link submission)
  - `body`: text (optional text submission)
  - `user_id`: integer (FK, indexed, null: false)
  - `created_at`, `updated_at`: datetime
- **Validations**:
  - `title`: presence, length between 3 and 150 characters
  - `url`: presence, format validation (`http` / `https`)
  - `user`: presence required (handled by `belongs_to`)
- **Associations**:
  - `belongs_to :user`
  - `has_many :comments, dependent: :destroy`

### 3. `Comment`
- **Columns**:
  - `id`: integer (PK)
  - `body`: text (null: false)
  - `user_id`: integer (FK, indexed, null: false)
  - `post_id`: integer (FK, indexed, null: false)
  - `created_at`, `updated_at`: datetime
- **Validations**:
  - `body`: presence, length between 1 and 1000 characters
  - `user`: presence required (`belongs_to :user`)
  - `post`: presence required (`belongs_to :post`)
- **Associations**:
  - `belongs_to :user`
  - `belongs_to :post`

---

## 🛠️ Setup & Running

```bash
# 1. Navigate to the project directory
cd "Ruby and Rails/micro-reddit"

# 2. Run migrations
ruby bin/rails db:migrate

# 3. Seed sample data
ruby bin/rails db:seed

# 4. Run tests
ruby bin/rails test
```

---

## 💻 Playing in the Rails Console (`rails c`)

Start the Rails interactive console:
```bash
ruby bin/rails console
```

### Testing Users & Validations
```ruby
# View all users
User.all

# Blank user is invalid
u = User.new
u.valid? # => false
u.errors.full_messages
# => ["Username can't be blank", "Username is too short (minimum is 4 characters)", "Email can't be blank", "Email must be a valid email address"]

# Create a valid user
u1 = User.create(username: "sammy_dev", email: "sammy@example.com")
u1.persisted? # => true
```

### Testing Posts & Associations
```ruby
# Finding user's posts
u1 = User.first
u1.posts

# Build a post through the association (automatically sets user_id!)
p1 = u1.posts.build(title: "Awesome Rails Article", url: "https://rubyonrails.org")
p1.user_id == u1.id # => true
p1.save

# Finding the post's user
Post.first.user
```

### Testing Comments & Interlinked Associations
```ruby
u2 = User.find(2)
p1 = Post.first

# User 2 comments on User 1's post
c1 = p1.comments.create(user: u2, body: "Great link, thanks!")

# Traverse associations:
u2.comments.first         # returns c1
c1.user                   # returns u2
p1.comments.first         # returns c1
c1.post                   # returns p1
```

---

## 🧪 Test Suite

Run the Minitest suite covering validations, associations, and cascading deletes:
```bash
ruby bin/rails test
```
All 23 tests and 66 assertions pass!

