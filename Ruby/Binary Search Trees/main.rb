# frozen_string_literal: true

require_relative 'tree'

def print_header(title)
  puts "\n#{'=' * 70}"
  puts "  #{title}"
  puts "#{'=' * 70}\n"
end

def print_section(title)
  puts "\n#{'-' * 50}"
  puts ">> #{title}"
  puts "#{'-' * 50}"
end

def print_traversals(tree)
  puts '  Level order: ' + tree.level_order.to_a.inspect
  puts '  Pre-order:   ' + tree.preorder.to_a.inspect
  puts '  In-order:    ' + tree.inorder.to_a.inspect
  puts '  Post-order:  ' + tree.postorder.to_a.inspect
end

print_header('THE ODIN PROJECT: BINARY SEARCH TREES DRIVER SCRIPT')

# 1. Create a binary search tree from an array of random numbers
print_section('Step 1: Create a BST from an array of 15 random numbers (1..100)')
random_numbers = Array.new(15) { rand(1..100) }
puts "Generated random array: #{random_numbers.inspect}"
tree = Tree.new(random_numbers)
puts "Unique sorted elements (#{tree.size} nodes): #{tree.to_a.inspect}"
puts "\nVisualizing initial tree structure:"
tree.pretty_print

# 2. Confirm that the tree is balanced by calling #balanced?
print_section('Step 2: Confirm tree balance')
is_balanced = tree.balanced?
puts "Calling tree.balanced?: #{is_balanced}"
puts "Root node value: #{tree.root.data}"
puts "Root height:     #{tree.height(tree.root)}"
puts "Left subtree height:  #{tree.height(tree.root.left)}"
puts "Right subtree height: #{tree.height(tree.root.right)}"

# 3. Print out all elements in level, pre, post, and in order
print_section('Step 3: Print all elements in level, pre, post, and in-order')
print_traversals(tree)

# 4. Unbalance the tree by adding several numbers whose value is more than 100
print_section('Step 4: Unbalance tree by inserting numbers > 100')
unbalancing_numbers = [105, 120, 140, 160, 185]
puts "Inserting numbers: #{unbalancing_numbers.inspect}"
unbalancing_numbers.each do |num|
  tree.insert(num)
  puts "  + Inserted #{num} (current depth: #{tree.depth(num)})"
end

puts "\nVisualizing unbalanced tree structure:"
tree.pretty_print

# 5. Confirm that the tree is unbalanced by calling #balanced?
print_section('Step 5: Confirm tree is now unbalanced')
is_balanced = tree.balanced?
puts "Calling tree.balanced?: #{is_balanced}"
puts "Root height:          #{tree.height(tree.root)}"
puts "Left subtree height:  #{tree.height(tree.root.left)}"
puts "Right subtree height: #{tree.height(tree.root.right)}"

# 6. Balance the tree by calling #rebalance
print_section('Step 6: Rebalance the tree by calling #rebalance')
puts 'Calling tree.rebalance...'
tree.rebalance
puts "\nVisualizing rebalanced tree structure:"
tree.pretty_print

# 7. Confirm that the tree is balanced by calling #balanced?
print_section('Step 7: Confirm tree is balanced again')
is_balanced = tree.balanced?
puts "Calling tree.balanced?: #{is_balanced}"
puts "Root node value:      #{tree.root.data}"
puts "Root height:          #{tree.height(tree.root)}"
puts "Left subtree height:  #{tree.height(tree.root.left)}"
puts "Right subtree height: #{tree.height(tree.root.right)}"

# 8. Print out all elements in level, pre, post, and in order
print_section('Step 8: Print all elements in level, pre, post, and in-order after rebalancing')
print_traversals(tree)

# Bonus Demonstrations
print_section('Bonus: Additional Method Demonstrations')
sample_val = tree.root.data
puts "Lookup & Search:"
puts "  tree.include?(#{sample_val}): #{tree.include?(sample_val)}"
puts "  tree.include?(9999):          #{tree.include?(9999)}"
puts "  tree.find(#{sample_val}):     #{tree.find(sample_val).inspect}"

puts "\nNode Metrics:"
puts "  tree.min: #{tree.min}"
puts "  tree.max: #{tree.max}"
puts "  tree.size: #{tree.size}"
puts "  tree.height(#{sample_val}): #{tree.height(sample_val)}"
puts "  tree.depth(#{sample_val}):  #{tree.depth(sample_val)}"

leaf_val = tree.to_a.first
puts "  tree.height(#{leaf_val}) [leaf]: #{tree.height(leaf_val)}"
puts "  tree.depth(#{leaf_val})  [leaf]: #{tree.depth(leaf_val)}"

puts "\nBlock Yielding Demonstration (Doubling each value in level order):"
doubled = []
tree.level_order { |val| doubled << (val * 2) }
puts "  Doubled values: #{doubled.inspect}"

print_header('DRIVER SCRIPT EXECUTION COMPLETE')
