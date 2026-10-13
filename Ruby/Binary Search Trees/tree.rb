# frozen_string_literal: true

require_relative 'node'

# Tree represents a Balanced Binary Search Tree (BST).
# It provides operations for building, inspecting, searching, inserting,
# deleting, traversing, and rebalancing the tree.
class Tree
  attr_reader :root

  def initialize(array = [])
    @root = build_tree(array)
  end

  # Builds a balanced binary search tree from an array.
  # Removes duplicates and sorts the array prior to building.
  # Returns the level-0 root Node.
  def build_tree(array)
    return nil if array.nil? || array.empty?

    clean_sorted = array.compact.uniq.sort
    build_balanced_tree(clean_sorted, 0, clean_sorted.length - 1)
  end

  # Searches for a node with the given value.
  # Returns the Node if found, or nil if not found.
  def find(value)
    current = @root
    while current
      return current if current.data == value

      current = value < current.data ? current.left : current.right
    end
    nil
  end

  # Returns true if value is in the tree, false otherwise.
  def include?(value)
    !find(value).nil?
  end

  # Inserts a new node with the given value into the tree.
  # Preserves BST property. If value already exists, does nothing.
  # Returns self to allow method chaining.
  def insert(value)
    @root = insert_node(@root, value)
    self
  end

  # Deletes the node containing the given value from the tree.
  # Handles 3 cases: leaf node, one child, and two children (in-order successor).
  # If value is not found, does nothing.
  # Returns self.
  def delete(value)
    @root = delete_node(@root, value)
    self
  end

  # Traverses the tree in breadth-first level order.
  # Yields each value to the provided block and returns self.
  # If no block is given, returns an Enumerator.
  def level_order
    return to_enum(:level_order) unless block_given?
    return self if @root.nil?

    queue = [@root]
    until queue.empty?
      current = queue.shift
      yield current.data
      queue.push(current.left) if current.left
      queue.push(current.right) if current.right
    end
    self
  end

  # Recursive implementation of level order traversal.
  # Yields each value to the provided block and returns self.
  # If no block is given, returns an Enumerator.
  def level_order_recursive(&block)
    return to_enum(:level_order_recursive) unless block_given?
    return self if @root.nil?

    traverse_level_order_recursive([@root], &block)
    self
  end

  # Traverses the tree in depth-first in-order (Left, Root, Right).
  # Yields each value to the provided block and returns self.
  # If no block is given, returns an Enumerator.
  def inorder(&block)
    return to_enum(:inorder) unless block_given?

    traverse_inorder(@root, &block)
    self
  end

  # Traverses the tree in depth-first pre-order (Root, Left, Right).
  # Yields each value to the provided block and returns self.
  # If no block is given, returns an Enumerator.
  def preorder(&block)
    return to_enum(:preorder) unless block_given?

    traverse_preorder(@root, &block)
    self
  end

  # Traverses the tree in depth-first post-order (Left, Right, Root).
  # Yields each value to the provided block and returns self.
  # If no block is given, returns an Enumerator.
  def postorder(&block)
    return to_enum(:postorder) unless block_given?

    traverse_postorder(@root, &block)
    self
  end

  # Returns the height of the node containing the given value.
  # Height is defined as the number of edges on the longest path from that node to a leaf.
  # Leaf nodes have a height of 0.
  # Returns nil if the value is not found.
  def height(value_or_node = @root)
    return nil if value_or_node.nil?

    node = value_or_node.is_a?(Node) ? value_or_node : find(value_or_node)
    return nil if node.nil?

    calculate_node_height(node)
  end

  # Returns the depth of the node containing the given value.
  # Depth is defined as the number of edges from the root to that node.
  # The root node has a depth of 0.
  # Returns nil if the value is not found.
  def depth(value_or_node)
    return nil if @root.nil? || value_or_node.nil?

    target_val = value_or_node.is_a?(Node) ? value_or_node.data : value_or_node
    current = @root
    current_depth = 0

    while current
      return current_depth if current.data == target_val

      current = target_val < current.data ? current.left : current.right
      current_depth += 1
    end

    nil
  end

  # Returns true if the tree is balanced, false otherwise.
  # A tree is balanced if, for EVERY node, the height difference between
  # left and right subtrees is <= 1, and both subtrees are balanced.
  def balanced?(node = @root)
    return true if node.nil?

    left_height = calculate_node_height(node.left)
    right_height = calculate_node_height(node.right)
    height_diff = (left_height - right_height).abs

    height_diff <= 1 && balanced?(node.left) && balanced?(node.right)
  end

  # Rebalances an unbalanced tree.
  # Traverses the tree in-order to retrieve sorted elements,
  # then rebuilds the balanced tree and updates @root.
  # Returns self.
  def rebalance
    elements = inorder.to_a
    @root = build_tree(elements)
    self
  end

  # Pretty-prints the binary search tree visually in console.
  def pretty_print(node = @root, prefix = '', is_left: true)
    return unless node

    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", is_left: false)
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", is_left: true)
  end

  # Returns the total number of nodes in the tree.
  def size
    inorder.count
  end

  # Returns true if the tree has no nodes.
  def empty?
    @root.nil?
  end

  # Returns the minimum value stored in the tree, or nil if empty.
  def min
    return nil if @root.nil?

    min_node(@root).data
  end

  # Returns the maximum value stored in the tree, or nil if empty.
  def max
    return nil if @root.nil?

    max_node(@root).data
  end

  # Converts the tree to a sorted array of values.
  def to_a
    inorder.to_a
  end

  private

  # Recursively constructs a balanced BST from sorted slice [start_idx..end_idx]
  def build_balanced_tree(sorted_arr, start_idx, end_idx)
    return nil if start_idx > end_idx

    mid_idx = (start_idx + end_idx) / 2
    node = Node.new(sorted_arr[mid_idx])
    node.left = build_balanced_tree(sorted_arr, start_idx, mid_idx - 1)
    node.right = build_balanced_tree(sorted_arr, mid_idx + 1, end_idx)
    node
  end

  # Recursive helper to insert a node preserving BST properties
  def insert_node(node, value)
    return Node.new(value) if node.nil?

    if value < node.data
      node.left = insert_node(node.left, value)
    elsif value > node.data
      node.right = insert_node(node.right, value)
    end
    # If value == node.data, do nothing (duplicates ignored)
    node
  end

  # Recursive helper to delete a node preserving BST properties
  def delete_node(node, value)
    return nil if node.nil?

    if value < node.data
      node.left = delete_node(node.left, value)
    elsif value > node.data
      node.right = delete_node(node.right, value)
    else
      # Node to delete found!
      # Case 1: Leaf node
      return nil if node.left.nil? && node.right.nil?

      # Case 2: Exactly one child
      return node.right if node.left.nil?
      return node.left if node.right.nil?

      # Case 3: Two children
      # Find in-order successor (smallest node in right subtree)
      successor = min_node(node.right)
      node.data = successor.data
      node.right = delete_node(node.right, successor.data)
    end
    node
  end

  # Finds the node with the minimum value in a subtree
  def min_node(node)
    current = node
    current = current.left until current.left.nil?
    current
  end

  # Finds the node with the maximum value in a subtree
  def max_node(node)
    current = node
    current = current.right until current.right.nil?
    current
  end

  # Calculates the height of a given node (leaf has height 0, nil has height -1)
  def calculate_node_height(node)
    return -1 if node.nil?

    1 + [calculate_node_height(node.left), calculate_node_height(node.right)].max
  end

  # Recursive helper for breadth-first queue traversal
  def traverse_level_order_recursive(queue, &block)
    return if queue.empty?

    current = queue.shift
    yield current.data
    queue.push(current.left) if current.left
    queue.push(current.right) if current.right
    traverse_level_order_recursive(queue, &block)
  end

  def traverse_inorder(node, &block)
    return unless node

    traverse_inorder(node.left, &block)
    yield node.data
    traverse_inorder(node.right, &block)
  end

  def traverse_preorder(node, &block)
    return unless node

    yield node.data
    traverse_preorder(node.left, &block)
    traverse_preorder(node.right, &block)
  end

  def traverse_postorder(node, &block)
    return unless node

    traverse_postorder(node.left, &block)
    traverse_postorder(node.right, &block)
    yield node.data
  end
end
