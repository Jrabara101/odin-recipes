# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'node'
require_relative 'linked_list'

class NodeTest < Minitest::Test
  def test_defaults_to_nil
    node = Node.new
    assert_nil node.value
    assert_nil node.next_node
  end

  def test_custom_values
    next_node = Node.new('world')
    node = Node.new('hello', next_node)
    assert_equal 'hello', node.value
    assert_equal next_node, node.next_node
  end
end

class LinkedListTest < Minitest::Test
  def setup
    @list = LinkedList.new
  end

  def test_initial_state
    assert_equal 0, @list.size
    assert_nil @list.head
    assert_nil @list.tail
    assert_nil @list.head_node
    assert_nil @list.tail_node
    assert_equal '', @list.to_s
    assert @list.empty?
  end

  def test_append_single_element
    @list.append('dog')
    assert_equal 1, @list.size
    assert_equal 'dog', @list.head
    assert_equal 'dog', @list.tail
    assert_equal '( dog ) -> nil', @list.to_s
  end

  def test_append_multiple_elements
    @list.append('dog').append('cat').append('parrot')
    assert_equal 3, @list.size
    assert_equal 'dog', @list.head
    assert_equal 'parrot', @list.tail
    assert_equal '( dog ) -> ( cat ) -> ( parrot ) -> nil', @list.to_s
  end

  def test_prepend_on_empty_list
    @list.prepend('turtle')
    assert_equal 1, @list.size
    assert_equal 'turtle', @list.head
    assert_equal 'turtle', @list.tail
    assert_equal '( turtle ) -> nil', @list.to_s
  end

  def test_prepend_on_populated_list
    @list.append('dog')
    @list.prepend('wolf')
    assert_equal 2, @list.size
    assert_equal 'wolf', @list.head
    assert_equal 'dog', @list.tail
    assert_equal '( wolf ) -> ( dog ) -> nil', @list.to_s
  end

  def test_at_valid_indices
    @list.append('apple').append('banana').append('cherry')
    assert_equal 'apple', @list.at(0)
    assert_equal 'banana', @list.at(1)
    assert_equal 'cherry', @list.at(2)
  end

  def test_at_out_of_bounds
    @list.append('apple')
    assert_nil @list.at(-1)
    assert_nil @list.at(1)
    assert_nil @list.at(10)
  end

  def test_pop_empty_list
    assert_nil @list.pop
  end

  def test_pop_removes_head_node
    @list.append('first').append('second').append('third')
    popped = @list.pop
    assert_equal 'first', popped
    assert_equal 2, @list.size
    assert_equal 'second', @list.head
    assert_equal 'third', @list.tail
    assert_equal '( second ) -> ( third ) -> nil', @list.to_s
  end

  def test_pop_until_empty
    @list.append('solo')
    assert_equal 'solo', @list.pop
    assert_equal 0, @list.size
    assert_nil @list.head
    assert_nil @list.tail
    assert_equal '', @list.to_s
  end

  def test_contains
    @list.append('ruby').append('rails')
    assert @list.contains?('ruby')
    assert @list.contains?('rails')
    refute @list.contains?('python')
    refute LinkedList.new.contains?('anything')
  end

  def test_index_found_and_duplicate
    @list.append('a').append('b').append('c').append('b')
    assert_equal 0, @list.index('a')
    assert_equal 1, @list.index('b'), 'Should return index of first matching node'
    assert_equal 2, @list.index('c')
    assert_nil @list.index('z')
    assert_nil LinkedList.new.index('a')
  end

  def test_insert_at_middle_multiple_values
    @list.append(1).append(2).append(3)
    @list.insert_at(1, 10, 11)
    assert_equal '( 1 ) -> ( 10 ) -> ( 11 ) -> ( 2 ) -> ( 3 ) -> nil', @list.to_s
    assert_equal 5, @list.size
  end

  def test_insert_at_start
    @list.append(2).append(3)
    @list.insert_at(0, 0, 1)
    assert_equal '( 0 ) -> ( 1 ) -> ( 2 ) -> ( 3 ) -> nil', @list.to_s
    assert_equal 0, @list.head
    assert_equal 3, @list.tail
    assert_equal 4, @list.size
  end

  def test_insert_at_end
    @list.append(1).append(2)
    @list.insert_at(2, 3, 4)
    assert_equal '( 1 ) -> ( 2 ) -> ( 3 ) -> ( 4 ) -> nil', @list.to_s
    assert_equal 1, @list.head
    assert_equal 4, @list.tail
    assert_equal 4, @list.size
  end

  def test_insert_at_empty_list
    @list.insert_at(0, 'alpha', 'beta')
    assert_equal '( alpha ) -> ( beta ) -> nil', @list.to_s
    assert_equal 'alpha', @list.head
    assert_equal 'beta', @list.tail
    assert_equal 2, @list.size
  end

  def test_insert_at_out_of_bounds_raises_index_error
    assert_raises(IndexError) { @list.insert_at(-1, 'bad') }
    assert_raises(IndexError) { @list.insert_at(1, 'bad') }

    @list.append('ok')
    assert_raises(IndexError) { @list.insert_at(2, 'bad') }
  end

  def test_remove_at_head
    @list.append('a').append('b').append('c')
    removed = @list.remove_at(0)
    assert_equal 'a', removed
    assert_equal 'b', @list.head
    assert_equal 2, @list.size
    assert_equal '( b ) -> ( c ) -> nil', @list.to_s
  end

  def test_remove_at_middle
    @list.append('a').append('b').append('c')
    removed = @list.remove_at(1)
    assert_equal 'b', removed
    assert_equal 'a', @list.head
    assert_equal 'c', @list.tail
    assert_equal 2, @list.size
    assert_equal '( a ) -> ( c ) -> nil', @list.to_s
  end

  def test_remove_at_tail
    @list.append('a').append('b').append('c')
    removed = @list.remove_at(2)
    assert_equal 'c', removed
    assert_equal 'b', @list.tail
    assert_equal 2, @list.size
    assert_equal '( a ) -> ( b ) -> nil', @list.to_s
  end

  def test_remove_at_single_element
    @list.append('lone')
    removed = @list.remove_at(0)
    assert_equal 'lone', removed
    assert_nil @list.head
    assert_nil @list.tail
    assert_equal 0, @list.size
    assert_equal '', @list.to_s
  end

  def test_remove_at_out_of_bounds_raises_index_error
    assert_raises(IndexError) { @list.remove_at(0) } # empty list
    assert_raises(IndexError) { @list.remove_at(-1) }

    @list.append('x')
    assert_raises(IndexError) { @list.remove_at(1) }
  end

  def test_enumerable_methods
    @list.append(1).append(2).append(3).append(4)
    assert_equal [2, 4, 6, 8], @list.map { |n| n * 2 }
    assert_equal [2, 4], @list.select(&:even?)
    assert_equal 10, @list.sum
  end
end
