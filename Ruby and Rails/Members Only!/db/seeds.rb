# db/seeds.rb

puts "Clearing existing data..."
Post.destroy_all
User.destroy_all

puts "Creating clubhouse members..."

user1 = User.create!(
  name: "Sherlock Holmes",
  email: "sherlock@clubhouse.org",
  password: "password123",
  password_confirmation: "password123"
)

user2 = User.create!(
  name: "Irene Adler",
  email: "irene@clubhouse.org",
  password: "password123",
  password_confirmation: "password123"
)

user3 = User.create!(
  name: "Hercule Poirot",
  email: "poirot@clubhouse.org",
  password: "password123",
  password_confirmation: "password123"
)

puts "Creating secret whispers..."

user1.posts.create!(
  title: "The Mystery of the Bohemian Ruby",
  body: "The cipher delivered at midnight in the East Drawing Room has been decrypted. It references a hidden compartment behind the grandfather clock in the gallery. Do not let non-members inquire into its contents."
)

user2.posts.create!(
  title: "A Counter-Proposition Regarding Friday's Gala",
  body: "I have intercepted certain correspondence intended for the rival society across the river. If any of our members require an invitation to the masquerade, leave word at the usual drop point."
)

user3.posts.create!(
  title: "The Little Grey Cells Never Sleep",
  body: "Order and method, mon cher ami! The peculiar footsteps heard upon the cobblestones outside the secret door yesterday belong to someone wearing bespoke Italian leather shoes. We must keep our vigil."
)

user1.posts.create!(
  title: "Protocol for the Grand Vault",
  body: "Remember the paramount rule of our sanctuary: Outside, the public may only read these dispatches as anonymous tales. Inside our walls, the brotherhood stands unmasked."
)

puts "Seeds loaded successfully! #{User.count} members and #{Post.count} secret posts created."
