# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'node'
require_relative 'tree'

class NodeTest < Minitest::Test
  def setup
    @node = Node.new(10)
  end

  def test_initialization
    assert_equal 10, @node.data
    assert_nil @node.left
    assert_nil @node.right
  end

  def test_comparable
    smaller = Node.new(5)
    larger = Node.new(20)
    equal = Node.new(10)

    assert @node > smaller
    assert @node < larger
    assert_equal @node, equal
  end

  def test_child_helpers
    assert @node.leaf?
    refute @node.one_child?
    refute @node.two_children?
    assert_nil @node.only_child

    @node.left = Node.new(5)
    refute @node.leaf?
    assert @node.one_child?
    refute @node.two_children?
    assert_equal 5, @node.only_child.data

    @node.right = Node.new(15)
    refute @node.leaf?
    refute @node.one_child?
    assert @node.two_children?
  end

  def test_string_representation
    assert_equal '10', @node.to_s
    assert_includes @node.inspect, 'Node(data: 10'
  end
end

class TreeTest < Minitest::Test
  def setup
    # Array from TOP prompt: [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]
    # Unique sorted: [1, 3, 4, 5, 7, 8, 9, 23, 67, 324, 6345] (11 elements)
    @sample_data = [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]
    @tree = Tree.new(@sample_data)
  end

  def test_build_tree_removes_duplicates_and_sorts
    expected_sorted = [1, 3, 4, 5, 7, 8, 9, 23, 67, 324, 6345]
    assert_equal expected_sorted, @tree.inorder.to_a
    assert_equal 11, @tree.size
  end

  def test_empty_tree
    empty_tree = Tree.new([])
    assert_nil empty_tree.root
    assert empty_tree.empty?
    assert_equal 0, empty_tree.size
    assert empty_tree.balanced?
    assert_nil empty_tree.min
    assert_nil empty_tree.max
    assert_empty empty_tree.inorder.to_a
  end

  def test_single_element_tree
    single_tree = Tree.new([42])
    assert_equal 42, single_tree.root.data
    assert single_tree.root.leaf?
    assert single_tree.balanced?
    assert_equal 0, single_tree.height(42)
    assert_equal 0, single_tree.depth(42)
  end

  def test_include_and_find
    assert @tree.include?(8)
    assert @tree.include?(1)
    assert @tree.include?(6345)
    refute @tree.include?(999)
    refute @tree.include?(-5)

    node = @tree.find(23)
    assert_instance_of Node, node
    assert_equal 23, node.data
    assert_nil @tree.find(999)
  end

  def test_insert_new_value
    refute @tree.include?(10)
    initial_size = @tree.size

    @tree.insert(10)
    assert @tree.include?(10)
    assert_equal initial_size + 1, @tree.size

    # Verify BST ordering remains intact
    assert_equal [1, 3, 4, 5, 7, 8, 9, 10, 23, 67, 324, 6345], @tree.inorder.to_a
  end

  def test_insert_duplicate_does_nothing
    initial_size = @tree.size
    @tree.insert(7)
    assert_equal initial_size, @tree.size
    assert_equal [1, 3, 4, 5, 7, 8, 9, 23, 67, 324, 6345], @tree.inorder.to_a
  end

  def test_insert_into_empty_tree
    tree = Tree.new([])
    tree.insert(50)
    assert_equal 50, tree.root.data
    assert_equal [50], tree.to_a
  end

  def test_delete_leaf_node
    # In unique sorted array: 1 is a leaf or near leaf
    leaf_val = 1
    assert @tree.include?(leaf_val)
    @tree.delete(leaf_val)
    refute @tree.include?(leaf_val)
    assert_equal [3, 4, 5, 7, 8, 9, 23, 67, 324, 6345], @tree.inorder.to_a
  end

  def test_delete_node_with_one_child
    # Build tree with 1-child nodes:
    # 20 has only left child (15)
    # 5 has only right child (7)
    custom_tree = Tree.new([])
    [10, 5, 20, 15, 7].each { |v| custom_tree.insert(v) }

    node_20 = custom_tree.find(20)
    assert node_20.one_child?
    assert_equal 15, node_20.left.data

    node_5 = custom_tree.find(5)
    assert node_5.one_child?
    assert_equal 7, node_5.right.data

    # Delete node with only left child
    custom_tree.delete(20)
    refute custom_tree.include?(20)
    assert custom_tree.include?(15)
    assert_equal 15, custom_tree.root.right.data

    # Delete node with only right child
    custom_tree.delete(5)
    refute custom_tree.include?(5)
    assert custom_tree.include?(7)
    assert_equal 7, custom_tree.root.left.data

    assert_equal [7, 10, 15], custom_tree.inorder.to_a
  end

  def test_delete_node_with_two_children
    # In @sample_data: root node has two children
    root_val = @tree.root.data
    assert @tree.root.two_children?

    @tree.delete(root_val)
    refute @tree.include?(root_val)
    assert_equal 10, @tree.size

    # Verify remaining elements are still in BST order
    expected = [1, 3, 4, 5, 7, 8, 9, 23, 67, 324, 6345] - [root_val]
    assert_equal expected, @tree.inorder.to_a
  end

  def test_delete_non_existent_value_does_nothing
    initial_size = @tree.size
    @tree.delete(9999)
    assert_equal initial_size, @tree.size
  end

  def test_level_order_iterative
    # Testing level order traversal returns self with block
    yielded = []
    result = @tree.level_order { |val| yielded << val }
    assert_equal @tree, result
    assert_equal @tree.size, yielded.length
    assert_equal @tree.root.data, yielded.first

    # Testing level order without block returns Enumerator
    enum = @tree.level_order
    assert_instance_of Enumerator, enum
    assert_equal yielded, enum.to_a
  end

  def test_level_order_recursive
    iterative_vals = @tree.level_order.to_a
    recursive_vals = @tree.level_order_recursive.to_a
    assert_equal iterative_vals, recursive_vals

    yielded = []
    result = @tree.level_order_recursive { |v| yielded << v }
    assert_equal @tree, result
    assert_equal iterative_vals, yielded
  end

  def test_depth_first_traversals
    # Simple balanced tree: [1, 2, 3] -> root 2, left 1, right 3
    t = Tree.new([1, 2, 3])
    assert_equal [1, 2, 3], t.inorder.to_a
    assert_equal [2, 1, 3], t.preorder.to_a
    assert_equal [1, 3, 2], t.postorder.to_a

    # Yields correctly and returns self
    in_yield = []
    assert_equal t, t.inorder { |v| in_yield << v }
    assert_equal [1, 2, 3], in_yield

    pre_yield = []
    assert_equal t, t.preorder { |v| pre_yield << v }
    assert_equal [2, 1, 3], pre_yield

    post_yield = []
    assert_equal t, t.postorder { |v| post_yield << v }
    assert_equal [1, 3, 2], post_yield
  end

  def test_height
    # For a leaf node, height is 0
    # In tree [1, 2, 3]: root 2, leaves 1 and 3
    t = Tree.new([1, 2, 3])
    assert_equal 0, t.height(1)
    assert_equal 0, t.height(3)
    assert_equal 1, t.height(2)

    # Calling with Node object directly
    assert_equal 1, t.height(t.root)

    # Non-existent value returns nil
    assert_nil t.height(999)
  end

  def test_depth
    # In tree [1, 2, 3]: root 2 (depth 0), children 1 and 3 (depth 1)
    t = Tree.new([1, 2, 3])
    assert_equal 0, t.depth(2)
    assert_equal 1, t.depth(1)
    assert_equal 1, t.depth(3)

    # Calling with Node object directly
    assert_equal 0, t.depth(t.root)
    assert_equal 1, t.depth(t.root.left)

    # Non-existent value returns nil
    assert_nil t.depth(999)
  end

  def test_balanced_initial_tree
    assert @tree.balanced?
  end

  def test_unbalanced_detection
    # Unbalance the tree by inserting elements in ascending order
    @tree.insert(7000)
    @tree.insert(8000)
    @tree.insert(9000)
    @tree.insert(10000)
    refute @tree.balanced?
  end

  def test_balanced_pitfall_internal_subtree_unbalanced
    # Build tree where root height diff is <= 1, but an internal subtree is unbalanced:
    # Root: 50
    # Right child of root: 75 (leaf, height 0)
    # Left child of root: 25 -> 20 -> 15 (chain of length 2 on left, height 2)
    # Root height left = 2, right = 0 -> height diff = 2.
    # What if right subtree has height 1:
    # Left subtree: 30 has left child 20, 20 has left child 10 (height 2, height diff inside is 2).
    # Right subtree of root: 70 has right child 80 (height 1).
    # Root left_height = 2, right_height = 1 (diff is 1). Root condition ALONE would say balanced,
    # but left subtree is UNBALANCED!
    t = Tree.new([])
    [50, 30, 70, 80, 20, 10].each { |v| t.insert(v) }
    # Verify root left height vs right height:
    # 50's left is 30 (height 2). 50's right is 70 (height 1). Diff is 1!
    # But 30's left is 20 (height 1), 30's right is nil (height -1). Diff is 2 -> UNBALANCED!
    refute t.balanced?
  end

  def test_rebalance
    # Unbalance tree
    [100, 200, 300, 400, 500].each { |v| @tree.insert(v) }
    refute @tree.balanced?

    # Rebalance
    @tree.rebalance
    assert @tree.balanced?

    # Check all elements retained
    expected = [1, 3, 4, 5, 7, 8, 9, 23, 67, 100, 200, 300, 324, 400, 500, 6345]
    assert_equal expected, @tree.inorder.to_a
  end

  def test_min_and_max
    assert_equal 1, @tree.min
    assert_equal 6345, @tree.max
  end
end
