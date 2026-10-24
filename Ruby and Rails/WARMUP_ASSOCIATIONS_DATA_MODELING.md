# Warmup: Thinking Data First — ActiveRecord Associations

This document details the data architecture and schema design for the warmup scenarios presented in The Odin Project's **Private Events** lesson.

---

## Scenario 1: Pet-Sitting Platform

> *A site for pet-sitting (watching someone’s pet while they’re gone). People can babysit for multiple pets and pets can have multiple petsitters.*

### Domain Analysis
- **Core Entities:** `User` (owners and pet-sitters), `Pet`, and the join model representing the sitting relationship / bookings (`PetSitting` or `SittingAssignment`).
- **Relationships:**
  - A `Pet` belongs to an owner (`User`).
  - A `Pet` can have many `sitters` (`User`) through `pet_sittings`.
  - A pet-sitter (`User`) can sit for many `pets` through `pet_sittings`.
  - Many-to-many relationship between `Pet` and `User` (as sitter) with rich join attributes (e.g. `start_date`, `end_date`, `status`, `notes`).

### Models & Schema

#### `users` Table
| Column | Type | Constraints / Indexes |
|---|---|---|
| `id` | integer | Primary Key |
| `name` | string | not null |
| `email` | string | not null, unique index |
| `phone_number` | string | |
| `created_at` | datetime | not null |
| `updated_at` | datetime | not null |

#### `pets` Table
| Column | Type | Constraints / Indexes |
|---|---|---|
| `id` | integer | Primary Key |
| `owner_id` | integer | not null, foreign key (`users.id`), index |
| `name` | string | not null |
| `species` | string | not null |
| `breed` | string | |
| `special_instructions` | text | |
| `created_at` | datetime | not null |
| `updated_at` | datetime | not null |

#### `pet_sittings` Table (Join Table)
| Column | Type | Constraints / Indexes |
|---|---|---|
| `id` | integer | Primary Key |
| `pet_id` | integer | not null, foreign key (`pets.id`), index |
| `sitter_id` | integer | not null, foreign key (`users.id`), index |
| `start_time` | datetime | not null |
| `end_time` | datetime | not null |
| `status` | string | default: "pending" (pending, confirmed, completed, cancelled) |
| `notes` | text | |
| `created_at` | datetime | not null |
| `updated_at` | datetime | not null |

### ActiveRecord Model Definitions

```ruby
class User < ApplicationRecord
  # Pets owned by this user
  has_many :owned_pets, class_name: "Pet", foreign_key: :owner_id, dependent: :destroy

  # Sitting appointments where this user is the sitter
  has_many :pet_sittings, foreign_key: :sitter_id, dependent: :destroy
  # The pets this user babysits
  has_many :sitting_pets, through: :pet_sittings, source: :pet
end

class Pet < ApplicationRecord
  # The owner of the pet
  belongs_to :owner, class_name: "User"

  # Sittings involving this pet
  has_many :pet_sittings, dependent: :destroy
  # The users who babysit this pet
  has_many :sitters, through: :pet_sittings, source: :sitter
end

class PetSitting < ApplicationRecord
  belongs_to :pet
  belongs_to :sitter, class_name: "User"

  validates :start_time, :end_time, presence: true
  validates :status, inclusion: { in: %w[pending confirmed completed cancelled] }
end
```

---

## Scenario 2: Dinner Party Invitation Site

> *You like hosting people for dinner so you want to build a dinner party invitation site. A user can create parties, invite people to a party, and accept an invitation to someone else’s party.*

### Domain Analysis
- **Core Entities:** `User`, `DinnerParty`, and `Invitation` (join model).
- **Roles:**
  - A `User` can be a **host** (`created_parties`).
  - A `User` can be an **invitee** / **guest** (`invitations` -> `invited_parties`).
  - An `Invitation` connects a `DinnerParty` with an invitee (`User`), tracking acceptance status (`pending`, `accepted`, `declined`).

### Models & Schema

#### `users` Table
| Column | Type | Constraints / Indexes |
|---|---|---|
| `id` | integer | Primary Key |
| `name` | string | not null |
| `email` | string | not null, unique index |
| `created_at` | datetime | not null |
| `updated_at` | datetime | not null |

#### `dinner_parties` Table
| Column | Type | Constraints / Indexes |
|---|---|---|
| `id` | integer | Primary Key |
| `host_id` | integer | not null, foreign key (`users.id`), index |
| `title` | string | not null |
| `menu` | text | |
| `date_time` | datetime | not null |
| `location` | string | not null |
| `created_at` | datetime | not null |
| `updated_at` | datetime | not null |

#### `invitations` Table (Join Table)
| Column | Type | Constraints / Indexes |
|---|---|---|
| `id` | integer | Primary Key |
| `dinner_party_id` | integer | not null, foreign key (`dinner_parties.id`), index |
| `guest_id` | integer | not null, foreign key (`users.id`), index |
| `status` | string | default: "pending" (pending, accepted, declined) |
| `dietary_restrictions`| text | |
| `created_at` | datetime | not null |
| `updated_at` | datetime | not null |

*Composite unique index on `[:dinner_party_id, :guest_id]` to prevent duplicate invites.*

### ActiveRecord Model Definitions

```ruby
class User < ApplicationRecord
  # Parties hosted by this user
  has_many :hosted_parties, class_name: "DinnerParty", foreign_key: :host_id, dependent: :destroy

  # Invitations received by this user
  has_many :invitations, foreign_key: :guest_id, dependent: :destroy
  # Parties this user has been invited to
  has_many :invited_parties, through: :invitations, source: :dinner_party

  # Convenient query for parties accepted by this user
  def attending_parties
    invited_parties.where(invitations: { status: "accepted" })
  end
end

class DinnerParty < ApplicationRecord
  # The host who created the party
  belongs_to :host, class_name: "User"

  # Invitations sent out for this party
  has_many :invitations, dependent: :destroy
  # All invited users
  has_many :guests, through: :invitations, source: :guest

  # Attending guests
  has_many :attending_guests, -> { where(invitations: { status: "accepted" }) }, through: :invitations, source: :guest
end

class Invitation < ApplicationRecord
  belongs_to :dinner_party
  belongs_to :guest, class_name: "User"

  validates :status, inclusion: { in: %w[pending accepted declined] }
  validates :guest_id, uniqueness: { scope: :dinner_party_id, message: "already invited to this dinner party" }

  # Status helper methods
  def accept!
    update!(status: "accepted")
  end

  def decline!
    update!(status: "declined")
  end
end
```

---

## Scenario 3: Social Follow System (Extra Credit)

> *You and your friends just love posting things and following each other. How would you set up the models so a user can follow another user?*

### Domain Analysis
- This is a **self-referential many-to-many relationship**.
- Both the follower and the followed are `User` instances.
- A join table `follows` (or `relationships`) contains two foreign keys: `follower_id` and `followed_id` (or `leader_id`), both pointing to `users.id`.
- A user can also have many `posts`, and can view posts from users they follow (a "feed").

### Models & Schema

#### `users` Table
| Column | Type | Constraints / Indexes |
|---|---|---|
| `id` | integer | Primary Key |
| `username` | string | not null, unique index |
| `email` | string | not null, unique index |
| `created_at` | datetime | not null |
| `updated_at` | datetime | not null |

#### `follows` Table (Join Table)
| Column | Type | Constraints / Indexes |
|---|---|---|
| `id` | integer | Primary Key |
| `follower_id` | integer | not null, foreign key (`users.id`), index |
| `followed_id` | integer | not null, foreign key (`users.id`), index |
| `created_at` | datetime | not null |
| `updated_at` | datetime | not null |

*Composite unique index on `[:follower_id, :followed_id]` ensures a user cannot follow another user multiple times.*

#### `posts` Table
| Column | Type | Constraints / Indexes |
|---|---|---|
| `id` | integer | Primary Key |
| `user_id` | integer | not null, foreign key (`users.id`), index |
| `body` | text | not null |
| `created_at` | datetime | not null |
| `updated_at` | datetime | not null |

### ActiveRecord Model Definitions

```ruby
class User < ApplicationRecord
  has_many :posts, dependent: :destroy

  # Active relationships: People THIS user follows
  has_many :active_follows, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :active_follows, source: :followed

  # Passive relationships: People who follow THIS user
  has_many :passive_follows, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy
  has_many :followers, through: :passive_follows, source: :follower

  # Follow / Unfollow helper methods
  def follow(other_user)
    return if self == other_user
    following << other_user unless following?(other_user)
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  # Feed generation: posts from followed users + own posts
  def feed
    Post.where(user_id: following_ids << id).order(created_at: :desc)
  end
end

class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates :follower_id, uniqueness: { scope: :followed_id, message: "already following this user" }
  validate :cannot_follow_self

  private

  def cannot_follow_self
    errors.add(:followed_id, "can't follow yourself") if follower_id == followed_id
  end
end

class Post < ApplicationRecord
  belongs_to :user
  validates :body, presence: true, length: { maximum: 280 }
end
```

---

## Key Takeaways on ActiveRecord Associations for Many-to-Many

1. **`has_many :through` vs `has_and_belongs_to_many` (HABTM):**
   - Always prefer `has_many :through` when the relationship entity carries attributes of its own (e.g. `status`, `start_time`, `role`), or when validations / callbacks / direct querying on the join record are needed.
2. **Explicit Naming with `:class_name`, `:foreign_key`, and `:source`:**
   - When association names deviate from standard convention (e.g., `creator` instead of `user`, `attendee` instead of `user`, `attended_event` instead of `event`), specify `:class_name` on `belongs_to` and `:foreign_key` / `:source` on `has_many`.
3. **Database-level constraints:**
   - Always place unique compound indexes on join tables (`[:event_id, :user_id]`) in addition to model validations (`validates :user_id, uniqueness: { scope: :event_id }`) to prevent race conditions and duplicate associations at the database layer.
