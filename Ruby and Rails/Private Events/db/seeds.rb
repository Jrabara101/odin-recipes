# Seed data for Private Events application

puts "Cleaning existing database records..."
EventAttendance.destroy_all
Event.destroy_all
User.destroy_all

puts "Creating demo users..."
alice = User.create!(
  name: "Alice Morgan",
  username: "alicem",
  email: "alice@example.com",
  password: "password123",
  password_confirmation: "password123"
)

bob = User.create!(
  name: "Bob Vance",
  username: "bobvance",
  email: "bob@example.com",
  password: "password123",
  password_confirmation: "password123"
)

carol = User.create!(
  name: "Carol Danvers",
  username: "carold",
  email: "carol@example.com",
  password: "password123",
  password_confirmation: "password123"
)

david = User.create!(
  name: "David Miller",
  username: "davidm",
  email: "david@example.com",
  password: "password123",
  password_confirmation: "password123"
)

puts "Creating events..."

# 1. Upcoming Public Event (Alice)
event1 = alice.created_events.create!(
  title: "Annual Summer Rooftop BBQ & Board Games",
  description: "Join us for handcrafted smoked brisket, vegan BBQ options, craft mocktails/cocktails, and a massive selection of modern strategy board games under the city skyline!",
  location: "The Skyline Lounge, 88 Grand Ave",
  date: 5.days.from_now.change(hour: 18, min: 30),
  private: false
)
event1.event_attendances.create!(attendee: alice, status: "attending")
event1.event_attendances.create!(attendee: bob, status: "attending")
event1.event_attendances.create!(attendee: david, status: "attending")

# 2. Upcoming Public Event (Bob)
event2 = bob.created_events.create!(
  title: "Indie Tech Hackathon & Showcase",
  description: "A fast-paced weekend collaboration where developers, designers, and creators build cool tools and apps. Demos, prizes, pizza, and mentorship included!",
  location: "Founders Hub, 452 Innovation Blvd",
  date: 12.days.from_now.change(hour: 10, min: 0),
  private: false
)
event2.event_attendances.create!(attendee: bob, status: "attending")
event2.event_attendances.create!(attendee: alice, status: "attending")
event2.event_attendances.create!(attendee: carol, status: "attending")

# 3. Upcoming Private Event (Alice)
event3 = alice.created_events.create!(
  title: "Exclusive VIP Wine & Jazz Tasting",
  description: "An intimate evening with sommelier pairings and live acoustic jazz. Limited guest capacity. Please RSVP to confirm your seat at the tasting table.",
  location: "The Cellar Speakeasy, 14 Mulberry St",
  date: 8.days.from_now.change(hour: 19, min: 0),
  private: true
)
event3.event_attendances.create!(attendee: alice, status: "attending")
event3.event_attendances.create!(attendee: carol, status: "attending")
# David is invited but hasn't accepted yet
event3.event_attendances.create!(attendee: david, status: "invited")

# 4. Past Public Event (Carol)
event4 = carol.created_events.create!(
  title: "Spring Artisan Pizza Making Masterclass",
  description: "Learned traditional Neapolitan dough fermentation, high-temperature wood fire baking, and secret sauce recipes from master pizzaiolos.",
  location: "Bella Napoli Kitchen, 204 Little Italy Way",
  date: 14.days.ago.change(hour: 17, min: 0),
  private: false
)
event4.event_attendances.create!(attendee: carol, status: "attending")
event4.event_attendances.create!(attendee: alice, status: "attending")
event4.event_attendances.create!(attendee: bob, status: "attending")

# 5. Past Private Event (Bob)
event5 = bob.created_events.create!(
  title: "Secret 1920s Murder Mystery Dinner Party",
  description: "A thrilling speakeasy murder investigation game paired with a four-course dinner. Congratulations to detective Alice for uncovering the culprit!",
  location: "Vance Manor, 77 West Hill Road",
  date: 25.days.ago.change(hour: 19, min: 30),
  private: true
)
event5.event_attendances.create!(attendee: bob, status: "attending")
event5.event_attendances.create!(attendee: alice, status: "attending")
event5.event_attendances.create!(attendee: carol, status: "attending")

puts "Seed data successfully created!"
puts "Demo Credentials:"
puts "- alice@example.com (password123)"
puts "- bob@example.com (password123)"
puts "- carol@example.com (password123)"
puts "- david@example.com (password123)"
