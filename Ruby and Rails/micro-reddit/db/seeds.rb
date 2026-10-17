# Clean existing records in development
Comment.destroy_all
Post.destroy_all
User.destroy_all

puts "Seeding Micro-Reddit database..."

# 1. Create Users
u1 = User.create!(
  username: "alice_dev",
  email: "alice@example.com"
)

u2 = User.create!(
  username: "bob_coder",
  email: "bob@example.com"
)

u3 = User.create!(
  username: "charlie_tech",
  email: "charlie@example.com"
)

puts "Created #{User.count} users."

# 2. Create Posts
p1 = u1.posts.create!(
  title: "The Odin Project - Full Stack Ruby on Rails Path",
  url: "https://www.theodinproject.com",
  body: "The best free open-source curriculum for becoming a web developer."
)

p2 = u2.posts.create!(
  title: "Ruby on Rails Guides & API Reference",
  url: "https://guides.rubyonrails.org",
  body: "Official guides covering ActiveRecord, associations, migrations, and more."
)

p3 = u1.posts.create!(
  title: "Hacker News Frontpage",
  url: "https://news.ycombinator.com",
  body: "Tech news and discussions."
)

puts "Created #{Post.count} posts."

# 3. Create Comments
c1 = p1.comments.create!(
  user: u2,
  body: "I am working through the Rails models lesson right now, it is super helpful!"
)

c2 = p1.comments.create!(
  user: u3,
  body: "ActiveRecord associations make database relationships so intuitive."
)

c3 = p2.comments.create!(
  user: u1,
  body: "The edge guides are always great for reference when building models."
)

puts "Created #{Comment.count} comments."
puts "Seeding complete!"
