# frozen_string_literal: true

require_relative 'linked_list'

puts '=================================================='
puts '  The Odin Project: Project Linked Lists Demo     '
puts '=================================================='
puts

# 1. Assignment Default Test Case
puts '--- 1. Testing Default Example from Assignment ---'
list = LinkedList.new
list.append('dog')
list.append('cat')
list.append('parrot')
list.append('hamster')
list.append('snake')
list.append('turtle')

puts list
puts

# 2. Testing Inspection Methods
puts '--- 2. Inspecting List Properties ---'
puts "Size:        #{list.size}"
puts "Head value:  #{list.head}"
puts "Tail value:  #{list.tail}"
puts "at(0):       #{list.at(0)}"
puts "at(2):       #{list.at(2)}"
puts "at(5):       #{list.at(5)}"
puts "at(99):      #{list.at(99).inspect} (out of bounds returns nil)"
puts

# 3. Testing Search Methods (#contains?, #index)
puts '--- 3. Testing #contains? and #index ---'
puts "Contains 'cat'?      #{list.contains?('cat')}"
puts "Contains 'dragon'?   #{list.contains?('dragon')}"
puts "Index of 'parrot':   #{list.index('parrot')}"
puts "Index of 'turtle':   #{list.index('turtle')}"
puts "Index of 'unicorn':  #{list.index('unicorn').inspect}"
puts

# 4. Testing #prepend
puts '--- 4. Testing #prepend ---'
puts 'Prepending "wolf"...'
list.prepend('wolf')
puts "Current list: #{list}"
puts "New Head:     #{list.head}"
puts "New Size:     #{list.size}"
puts

# 5. Testing #pop (Removes head node and returns its value)
puts '--- 5. Testing #pop (removes head node) ---'
popped = list.pop
puts "Popped value: #{popped}"
puts "Current list: #{list}"
puts "New Head:     #{list.head}"
puts "New Size:     #{list.size}"
puts

# 6. Testing Extra Credit: #insert_at
puts '--- 6. Testing Extra Credit: #insert_at ---'
num_list = LinkedList.new
num_list.append(1).append(2).append(3)
puts "Initial numbers list: #{num_list}"

puts 'Inserting 10, 11 at index 1...'
num_list.insert_at(1, 10, 11)
puts "After insertion:      #{num_list}"
puts "Expected:             ( 1 ) -> ( 10 ) -> ( 11 ) -> ( 2 ) -> ( 3 ) -> nil"
puts

puts 'Inserting 99 at index 0 (start)...'
num_list.insert_at(0, 99)
puts "After insert at 0:    #{num_list}"
puts "New head:             #{num_list.head}"
puts

puts 'Inserting 500 at index size (end)...'
num_list.insert_at(num_list.size, 500)
puts "After insert at end:  #{num_list}"
puts "New tail:             #{num_list.tail}"
puts

# 7. Testing Extra Credit: #remove_at
puts '--- 7. Testing Extra Credit: #remove_at ---'
puts "Current numbers:      #{num_list}"
puts "Removing node at index 0: #{num_list.remove_at(0)} removed"
puts "After remove_at(0):   #{num_list}"
puts "Removing node at index 2: #{num_list.remove_at(2)} removed"
puts "After remove_at(2):   #{num_list}"
last_idx = num_list.size - 1
puts "Removing tail at index #{last_idx}: #{num_list.remove_at(last_idx)} removed"
puts "After tail removal:   #{num_list}"
puts "New tail value:       #{num_list.tail}"
puts

# 8. Testing IndexError Handling
puts '--- 8. Testing Out-of-Bounds Error Handling ---'
begin
  num_list.insert_at(100, 42)
rescue IndexError => e
  puts "Caught expected error on insert_at(100): #{e.message}"
end

begin
  num_list.remove_at(-1)
rescue IndexError => e
  puts "Caught expected error on remove_at(-1): #{e.message}"
end
puts

# 9. Testing Empty List Behaviors
puts '--- 9. Testing Empty List Edge Cases ---'
empty_list = LinkedList.new
puts "Empty list to_s:      #{empty_list.to_s.inspect}"
puts "Empty list size:      #{empty_list.size}"
puts "Empty list head:      #{empty_list.head.inspect}"
puts "Empty list tail:      #{empty_list.tail.inspect}"
puts "Empty list at(0):     #{empty_list.at(0).inspect}"
puts "Empty list pop:       #{empty_list.pop.inspect}"
puts "Empty list contains?: #{empty_list.contains?('anything')}"
puts "Empty list index:     #{empty_list.index('anything').inspect}"
puts

# 10. Enumerable Support
puts '--- 10. Testing Enumerable integration ---'
names_list = LinkedList.new.append('alice').append('bob').append('charlie')
capitalized = names_list.map(&:capitalize)
puts "Mapped with .map:     #{capitalized.inspect}"
puts

puts 'All checks completed successfully!'
