# Re-Former (The Odin Project: Ruby on Rails Forms)

This is part of the Forms Project in The Odin Project’s Ruby on Rails Curriculum. Find it at [https://www.theodinproject.com](https://www.theodinproject.com/).

## Overview

The purpose of this project is to demystify how forms work in Ruby on Rails by starting from first principles and progressing through the layers of abstraction:
1. **Pure HTML Forms (`<form>`)**: Understanding HTTP methods, actions, `accept-charset="UTF-8"`, and raw `<input>` elements.
2. **CSRF & Authenticity Tokens**: Discovering why Rails throws `ActionController::InvalidAuthenticityToken`, and how `<%= form_authenticity_token %>` solves it.
3. **Strong Parameters & Nested Attributes**: Structuring input names like `name="user[username]"` to produce clean nested hashes for `User.new(user_params)` via `params.require(:user).permit(:username, :email, :password)`.
4. **Rails Form Helper (`#form_with`)**: Refactoring the form to modern Rails helpers (`form_with model: @user`), automatic CSRF tokens, and automatic route resolution for both new records (`POST /users`) and persisted records (`PATCH /users/:id`).
5. **Turbo Integration**: Observing form submission behavior with and without `data-turbo="false"`.
6. **Editing & Validation Feedback**: Handling `#edit` and `#update`, the hidden `_method="patch"` field, and rendering model validation errors via `@user.errors.full_messages`.

---

## Requirements & Stack

- **Ruby**: 3.3+
- **Rails**: 7.2+
- **Database**: SQLite3
- **Frontend / Assets**: Hotwire (Turbo + Stimulus), Importmap, modern clean CSS

---

## Routes

| Method | Path | Controller#Action | Description |
|---|---|---|---|
| GET | `/users/new` | `users#new` | New user creation form |
| POST | `/users` | `users#create` | Create a user |
| GET | `/users/:id/edit` | `users#edit` | Edit user form |
| PATCH / PUT | `/users/:id` | `users#update` | Update a user |

---

## Setup & Running

```bash
# Install dependencies
bundle install

# Setup and migrate the database
bin/rails db:migrate

# Start the Rails server
bin/rails server
```

Visit [http://localhost:3000/users/new](http://localhost:3000/users/new) in your browser.
