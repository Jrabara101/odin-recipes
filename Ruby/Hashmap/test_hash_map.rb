# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'node'
require_relative 'hash_map'
require_relative 'hash_set'

class NodeTest < Minitest::Test
  def test_defaults_and_attributes
    node = Node.new('hello')
    assert_equal 'hello', node.key
    assert_nil node.value
    assert_nil node.next_node

    node.value = 'world'
    node.next_node = Node.new('next', 123)
    assert_equal 'world', node.value
    assert_equal 'next', node.next_node.key
    assert_equal 123, node.next_node.value
  end
end

class HashMapTest < Minitest::Test
  def setup
    @map = HashMap.new
  end

  def test_initial_state
    assert_equal 0, @map.length
    assert_equal 0, @map.size
    assert_equal 16, @map.capacity
    assert_in_delta 0.75, @map.load_factor
    assert_in_delta 0.0, @map.load_level
    assert @map.empty?
    assert_empty @map.keys
    assert_empty @map.values
    assert_empty @map.entries
  end

  def test_custom_capacity_and_load_factor
    custom_map = HashMap.new(32, 0.5)
    assert_equal 32, custom_map.capacity
    assert_in_delta 0.5, custom_map.load_factor
  end

  def test_hash_function
    idx = @map.hash('apple')
    assert idx >= 0 && idx < @map.capacity
    # Same key always produces the exact same hash index
    assert_equal idx, @map.hash('apple')

    raw = @map.raw_hash('apple')
    assert_equal raw % @map.capacity, idx
  end

  def test_index_boundary_checking
    assert_raises(IndexError) { @map.check_index(-1) }
    assert_raises(IndexError) { @map.check_index(16) }
    assert_raises(IndexError) { @map.check_index(100) }

    # Valid indices should not raise error
    @map.check_index(0)
    @map.check_index(15)
  end

  def test_set_and_get_single_pair
    @map.set('apple', 'red')
    assert_equal 1, @map.length
    refute @map.empty?
    assert_equal 'red', @map.get('apple')
  end

  def test_get_non_existent_key
    assert_nil @map.get('non_existent')
  end

  def test_has_predicate
    @map.set('cat', 'meow')
    assert @map.has?('cat')
    refute @map.has?('dog')
  end

  def test_overwrite_existing_key
    @map.set('apple', 'red')
    assert_equal 1, @map.length

    # Overwrite value
    @map.set('apple', 'green')
    assert_equal 1, @map.length
    assert_equal 16, @map.capacity
    assert_equal 'green', @map.get('apple')
  end

  def test_remove_existing_key
    @map.set('banana', 'yellow')
    @map.set('carrot', 'orange')

    deleted = @map.remove('banana')
    assert_equal 'yellow', deleted
    assert_equal 1, @map.length
    assert_nil @map.get('banana')
    refute @map.has?('banana')
    assert_equal 'orange', @map.get('carrot')
  end

  def test_remove_non_existent_key
    assert_nil @map.remove('ghost')
    @map.set('a', 1)
    assert_nil @map.remove('ghost')
    assert_equal 1, @map.length
  end

  def test_collision_handling_and_removal_in_chain
    # Force collision or find keys that collide on capacity 16
    # We can explicitly test multiple items that hash to the same bucket
    @map.set('key1', 'val1')
    # Let's find two keys that have the same hash
    target_idx = @map.hash('test_alpha')
    colliding_key = (1..1000).find { |i| @map.hash("k_#{i}") == target_idx }

    @map.set('test_alpha', 'first')
    @map.set("k_#{colliding_key}", 'second')

    assert_equal 'first', @map.get('test_alpha')
    assert_equal 'second', @map.get("k_#{colliding_key}")

    # Remove the first node in chain
    assert_equal 'second', @map.remove("k_#{colliding_key}")
    assert_nil @map.get("k_#{colliding_key}")
    assert_equal 'first', @map.get('test_alpha')

    # Remove the remaining node in chain
    assert_equal 'first', @map.remove('test_alpha')
    assert_nil @map.get('test_alpha')
  end

  def test_clear
    @map.set('a', 1)
    @map.set('b', 2)
    @map.set('c', 3)
    assert_equal 3, @map.length

    @map.clear
    assert_equal 0, @map.length
    assert @map.empty?
    assert_empty @map.keys
    assert_empty @map.values
    assert_empty @map.entries
    assert_nil @map.get('a')
  end

  def test_keys_values_entries
    pairs = { 'apple' => 'red', 'banana' => 'yellow', 'cherry' => 'crimson' }
    pairs.each { |k, v| @map.set(k, v) }

    assert_equal 3, @map.length
    assert_equal pairs.keys.sort, @map.keys.sort
    assert_equal pairs.values.sort, @map.values.sort
    assert_equal pairs.to_a.sort, @map.entries.sort
  end

  def test_odin_project_walkthrough_and_dynamic_growth
    # Step 1: Set 12 items into HashMap (load factor threshold = 16 * 0.75 = 12)
    initial_items = [
      %w[apple red],
      %w[banana yellow],
      %w[carrot orange],
      %w[dog brown],
      %w[elephant gray],
      %w[frog green],
      %w[grape purple],
      %w[hat black],
      ['ice cream', 'white'],
      %w[jacket blue],
      %w[kite pink],
      %w[lion golden]
    ]

    initial_items.each { |k, v| @map.set(k, v) }

    # Validate full load capacity before exceeding load factor
    assert_equal 12, @map.length
    assert_equal 16, @map.capacity
    assert_in_delta 0.75, @map.load_level

    # Step 2: Overwrite existing keys - length and capacity must remain unchanged
    @map.set('apple', 'crimson')
    @map.set('frog', 'emerald')
    assert_equal 12, @map.length
    assert_equal 16, @map.capacity
    assert_equal 'crimson', @map.get('apple')
    assert_equal 'emerald', @map.get('frog')

    # Step 3: Populate 13th item -> triggers doubling capacity to 32
    @map.set('moon', 'silver')
    assert_equal 13, @map.length
    assert_equal 32, @map.capacity
    assert_in_delta 13.0 / 32, @map.load_level
    assert @map.load_level < @map.load_factor

    # All initial items plus 'moon' must still be accessible
    assert_equal 'crimson', @map.get('apple')
    assert_equal 'yellow', @map.get('banana')
    assert_equal 'orange', @map.get('carrot')
    assert_equal 'brown', @map.get('dog')
    assert_equal 'gray', @map.get('elephant')
    assert_equal 'emerald', @map.get('frog')
    assert_equal 'purple', @map.get('grape')
    assert_equal 'black', @map.get('hat')
    assert_equal 'white', @map.get('ice cream')
    assert_equal 'blue', @map.get('jacket')
    assert_equal 'pink', @map.get('kite')
    assert_equal 'golden', @map.get('lion')
    assert_equal 'silver', @map.get('moon')

    # Overwrite again after resize
    @map.set('moon', 'platinum')
    assert_equal 13, @map.length
    assert_equal 32, @map.capacity
    assert_equal 'platinum', @map.get('moon')

    # Check inspection methods after resize
    assert_equal 13, @map.keys.length
    assert_equal 13, @map.values.length
    assert_equal 13, @map.entries.length
    assert @map.has?('moon')
    assert @map.has?('lion')
    refute @map.has?('sun')
  end
end

class HashSetTest < Minitest::Test
  def setup
    @set = HashSet.new
  end

  def test_initial_state
    assert_equal 0, @set.length
    assert_equal 0, @set.size
    assert_equal 16, @set.capacity
    assert_in_delta 0.75, @set.load_factor
    assert @set.empty?
    assert_empty @set.keys
    assert_empty @set.entries
  end

  def test_set_and_has
    @set.set('ruby')
    assert_equal 1, @set.length
    assert @set.has?('ruby')
    assert @set.include?('ruby')
    refute @set.has?('python')

    # Adding duplicate does not increment size
    @set.set('ruby')
    assert_equal 1, @set.length
  end

  def test_remove
    @set.set('alpha')
    @set.set('beta')

    removed = @set.remove('alpha')
    assert_equal 'alpha', removed
    assert_equal 1, @set.length
    refute @set.has?('alpha')
    assert @set.has?('beta')

    assert_nil @set.remove('non_existent')
    assert_equal 1, @set.length
  end

  def test_clear
    @set.set('a')
    @set.set('b')
    @set.clear
    assert_equal 0, @set.length
    assert @set.empty?
    assert_empty @set.keys
  end

  def test_keys_and_entries
    elements = %w[cat dog bird fish]
    elements.each { |el| @set.set(el) }

    assert_equal elements.sort, @set.keys.sort
    assert_equal elements.sort, @set.entries.sort
  end

  def test_index_boundary_checking
    assert_raises(IndexError) { @set.check_index(-1) }
    assert_raises(IndexError) { @set.check_index(16) }
  end

  def test_resizing_on_load_factor_exceeded
    12.times { |i| @set.set("item_#{i}") }
    assert_equal 12, @set.length
    assert_equal 16, @set.capacity

    # 13th item triggers resize
    @set.set('overflow_item')
    assert_equal 13, @set.length
    assert_equal 32, @set.capacity
    assert @set.load_level < @set.load_factor

    # All items preserved
    12.times { |i| assert @set.has?("item_#{i}") }
    assert @set.has?('overflow_item')
  end
end
