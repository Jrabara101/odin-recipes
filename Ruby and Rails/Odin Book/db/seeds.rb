# OdinBook Seeds

puts "Clearing existing data..."
Comment.destroy_all
Like.destroy_all
Post.destroy_all
Friendship.destroy_all
User.destroy_all

puts "Creating primary demo users..."
alice = User.create!(
  first_name: "Alice",
  last_name: "Johnson",
  username: "alice_j",
  email: "alice@example.com",
  password: "password123",
  password_confirmation: "password123",
  bio: "Full-stack developer | Open source enthusiast | Coffee lover ☕",
  avatar_url: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80"
)

bob = User.create!(
  first_name: "Bob",
  last_name: "Smith",
  username: "bob_smith",
  email: "bob@example.com",
  password: "password123",
  password_confirmation: "password123",
  bio: "Hiking, photography, and building cool things with Ruby on Rails 🏔️",
  avatar_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80"
)

charlie = User.create!(
  first_name: "Charlie",
  last_name: "Brown",
  username: "charlie_b",
  email: "charlie@example.com",
  password: "password123",
  password_confirmation: "password123",
  bio: "UI/UX Designer who loves clean layouts and accessible web experiences 🎨",
  avatar_url: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80"
)

diana = User.create!(
  first_name: "Diana",
  last_name: "Prince",
  username: "diana_p",
  email: "diana@example.com",
  password: "password123",
  password_confirmation: "password123",
  bio: "Data enthusiast, bookworm, and marathon runner 🏃‍♀️📚",
  avatar_url: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&auto=format&fit=crop&q=80"
)

evan = User.create!(
  first_name: "Evan",
  last_name: "Wright",
  username: "evan_w",
  email: "evan@example.com",
  password: "password123",
  password_confirmation: "password123",
  bio: "Just joined OdinBook! Excited to connect with friends.",
  avatar_url: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&auto=format&fit=crop&q=80"
)

puts "Creating friendships..."
# Alice & Bob: mutual friends
Friendship.create!(sender: alice, receiver: bob, status: "accepted")

# Alice & Charlie: mutual friends
Friendship.create!(sender: charlie, receiver: alice, status: "accepted")

# Bob & Diana: mutual friends
Friendship.create!(sender: bob, receiver: diana, status: "accepted")

# Evan sent pending friend request to Alice (so Alice sees a notification badge)
Friendship.create!(sender: evan, receiver: alice, status: "pending")

# Alice sent pending friend request to Diana
Friendship.create!(sender: alice, receiver: diana, status: "pending")

puts "Creating posts..."
post1 = alice.posts.create!(
  content: "Hello OdinBook! 🚀 Just launched my new Rails project. It's amazing how much you can build with Rails 7 and Hotwire!"
)

post2 = bob.posts.create!(
  content: "Spent the weekend hiking in the mountains. Fresh air, zero notifications, and breathtaking views! 🌲🧗‍♂️"
)

post3 = charlie.posts.create!(
  content: "Working on a new design system today. Simplicity and consistency are the keys to great user experiences."
)

post4 = diana.posts.create!(
  content: "Finished another great tech book: 'The Pragmatic Programmer'. What is everyone else reading this month?"
)

puts "Creating likes..."
post1.likes.create!(user: bob)
post1.likes.create!(user: charlie)
post2.likes.create!(user: alice)
post3.likes.create!(user: alice)
post3.likes.create!(user: bob)

puts "Creating comments..."
post1.comments.create!(user: bob, content: "Congrats Alice! Looking super sleek.")
post1.comments.create!(user: charlie, content: "Great work! The UI looks very clean.")
post2.comments.create!(user: alice, content: "Looks like an awesome hike, Bob!")
post3.comments.create!(user: alice, content: "Couldn't agree more, Charlie!")
post4.comments.create!(user: bob, content: "I'm reading 'Metaprogramming Ruby 2' - highly recommend it!")

puts "Database seeded successfully!"
puts "Primary demo accounts:"
puts "  Alice Johnson -> alice@example.com / password123"
puts "  Bob Smith     -> bob@example.com / password123"
puts "  Charlie Brown -> charlie@example.com / password123"
puts "  Diana Prince  -> diana@example.com / password123"
puts "  Evan Wright   -> evan@example.com / password123"
