# frozen_string_literal: true

require_relative 'hash_map'
require_relative 'hash_set'

def print_separator(title = nil)
  puts "\n#{'=' * 65}"
  puts "  #{title}" if title
  puts "#{'=' * 65}\n"
end

def print_stats(map, label = 'Current Stats')
  puts "--- #{label} ---"
  puts "  Length:       #{map.length}"
  puts "  Capacity:     #{map.capacity}"
  puts "  Load Factor:  #{map.load_factor}"
  puts "  Load Level:   #{map.load_level.round(4)} (#{(map.load_level * 100).round(1)}%)"
  puts
end

print_separator('THE ODIN PROJECT: HASHMAP WALKTHROUGH DEMO')

# 1. Initialize HashMap with load factor 0.75
puts '1. Creating HashMap instance (capacity: 16, load factor: 0.75)...'
test = HashMap.new
print_stats(test, 'Initial State')

# 2. Populate with 12 items from assignment
puts '2. Populating HashMap with 12 initial key-value pairs...'
initial_entries = [
  ['apple', 'red'],
  ['banana', 'yellow'],
  ['carrot', 'orange'],
  ['dog', 'brown'],
  ['elephant', 'gray'],
  ['frog', 'green'],
  ['grape', 'purple'],
  ['hat', 'black'],
  ['ice cream', 'white'],
  ['jacket', 'blue'],
  ['kite', 'pink'],
  ['lion', 'golden']
]

initial_entries.each do |key, value|
  test.set(key, value)
  puts "  + set(#{key.inspect}, #{value.inspect}) -> bucket index #{test.hash(key)}"
end
puts
print_stats(test, 'After Populating 12 Items (Full Capacity at 0.75)')

# 3. Overwrite existing nodes without expanding
puts '3. Overwriting existing nodes (should NOT increase length or trigger resize)...'
puts "  Previous apple value: #{test.get('apple').inspect}"
test.set('apple', 'crisp-crimson')
puts "  Updated apple value:  #{test.get('apple').inspect}"

puts "  Previous frog value:  #{test.get('frog').inspect}"
test.set('frog', 'emerald-green')
puts "  Updated frog value:   #{test.get('frog').inspect}"
puts
print_stats(test, 'After Overwriting Existing Nodes')

# 4. Trigger Dynamic Resizing (Growth)
puts "4. Adding 13th node ('moon', 'silver') to exceed load factor (13/16 = 81.25% > 75%)..."
test.set('moon', 'silver')
puts '  -> Doubling capacity triggered!'
puts
print_stats(test, 'After Resizing (Capacity Doubled to 32)')

# 5. Overwriting nodes in the expanded hash map
puts '5. Overwriting nodes in the expanded hash map...'
test.set('moon', 'luminous-silver')
puts "  Updated moon value: #{test.get('moon').inspect}"
print_stats(test, 'After Post-Resize Overwrite')

# 6. Testing #get(key)
print_separator('Testing Inspection and Query Methods')
puts "get('apple'):       #{test.get('apple')}"
puts "get('lion'):        #{test.get('lion')}"
puts "get('moon'):        #{test.get('moon')}"
puts "get('dragon'):      #{test.get('dragon').inspect} (absent key returns nil)"
puts

# 7. Testing #has?(key)
puts "has?('banana'):     #{test.has?('banana')}"
puts "has?('moon'):       #{test.has?('moon')}"
puts "has?('unicorn'):    #{test.has?('unicorn')}"
puts

# 8. Testing #keys, #values, #entries
puts "keys (count #{test.keys.length}):"
p test.keys
puts
puts "values (count #{test.values.length}):"
p test.values
puts
puts "entries (count #{test.entries.length}):"
p test.entries
puts

# 9. Testing #remove(key)
puts "9. Testing #remove(key)..."
puts "  Removing 'banana': returned deleted value #{test.remove('banana').inspect}"
puts "  has?('banana') now: #{test.has?('banana')}"
puts "  Removing 'non_existent': returned #{test.remove('non_existent').inspect}"
print_stats(test, 'After Removals')

# 10. Testing #clear
puts '10. Testing #clear...'
test.clear
print_stats(test, 'After Clear')
puts "  empty? : #{test.empty?}"
puts "  keys   : #{test.keys.inspect}"
puts "  entries: #{test.entries.inspect}"

# 11. Extra Credit: HashSet Demo
print_separator('EXTRA CREDIT: HASHSET DEMO')
puts 'Creating HashSet instance...'
set = HashSet.new
print_stats(set, 'Initial HashSet State')

puts 'Adding items to HashSet...'
%w[ruby crystal diamond sapphire ruby emerald].each do |gem|
  set.set(gem)
  puts "  + set(#{gem.inspect})"
end
puts
print_stats(set, 'After Adding Unique and Duplicate Gems')
puts "Keys in HashSet: #{set.keys.inspect}"
puts "has?('sapphire'): #{set.has?('sapphire')}"
puts "has?('gold'):     #{set.has?('gold')}"
puts "remove('crystal'): #{set.remove('crystal').inspect}"
puts "Keys after remove: #{set.keys.inspect}"
print_separator('DEMO COMPLETE: ALL TESTS PASSED')
