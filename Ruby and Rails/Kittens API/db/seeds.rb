# Seeds for Kittens API
puts "Clearing existing kittens..."
Kitten.destroy_all

kittens_data = [
  { name: "Mochi", age: 1, cuteness: 10, softness: 10 },
  { name: "Sir Reginald Fluffington", age: 3, cuteness: 9, softness: 10 },
  { name: "Pickles", age: 2, cuteness: 8, softness: 7 },
  { name: "Luna", age: 1, cuteness: 10, softness: 9 },
  { name: "Barnaby", age: 4, cuteness: 8, softness: 8 },
  { name: "Cleo", age: 2, cuteness: 9, softness: 8 },
  { name: "Biscuit", age: 0, cuteness: 10, softness: 10 },
  { name: "Oliver", age: 5, cuteness: 7, softness: 9 }
]

puts "Creating #{kittens_data.length} delightful kittens..."
kittens_data.each do |kitten_attrs|
  Kitten.create!(kitten_attrs)
end

puts "Done! Seeded #{Kitten.count} kittens successfully."
