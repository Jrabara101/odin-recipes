# frozen_string_literal: true

require_relative 'node'

# The Odin Project - Project: Linked Lists
# LinkedList class representing a singly linked list data structure.
class LinkedList
  include Enumerable

  # Initializes an empty LinkedList.
  def initialize
    @head = nil
    @tail = nil
    @size = 0
  end

  # Adds a new node containing value to the end of the list.
  #
  # @param value [Object] The value to append.
  # @return [LinkedList] Returns self to allow chaining.
  def append(value)
    new_node = Node.new(value)
    if @head.nil?
      @head = new_node
      @tail = new_node
    else
      @tail.next_node = new_node
      @tail = new_node
    end
    @size += 1
    self
  end

  # Adds a new node containing value to the start of the list.
  #
  # @param value [Object] The value to prepend.
  # @return [LinkedList] Returns self to allow chaining.
  def prepend(value)
    new_node = Node.new(value, @head)
    @head = new_node
    @tail = new_node if @tail.nil?
    @size += 1
    self
  end

  # Returns the total number of nodes in the list.
  #
  # @return [Integer] The list size.
  def size
    @size
  end

  # Returns the value of the first node in the list, or nil if the list is empty.
  #
  # @return [Object, nil] The value of the head node.
  def head
    @head&.value
  end

  # Returns the actual head Node object, or nil if empty.
  #
  # @return [Node, nil] The head node.
  def head_node
    @head
  end

  # Returns the value of the final node in the list, or nil if the list is empty.
  #
  # @return [Object, nil] The value of the tail node.
  def tail
    @tail&.value
  end

  # Returns the actual tail Node object, or nil if empty.
  #
  # @return [Node, nil] The tail node.
  def tail_node
    @tail
  end

  # Returns the value of the node at the given index (0-indexed).
  # If there is no node at the given index, returns nil.
  #
  # @param index [Integer] 0-based index.
  # @return [Object, nil] The value of the node at index.
  def at(index)
    node_at(index)&.value
  end

  # Returns the Node object at the given index (0-indexed), or nil if out of bounds.
  #
  # @param index [Integer] 0-based index.
  # @return [Node, nil] The node at index.
  def node_at(index)
    return nil if index.negative? || index >= @size

    current = @head
    index.times { current = current.next_node }
    current
  end

  # Removes the head node from the list and returns that node's value.
  # If called on an empty list, returns nil.
  #
  # @return [Object, nil] The value of the removed head node.
  def pop
    return nil if @head.nil?

    popped_node = @head
    @head = @head.next_node
    @size -= 1
    @tail = nil if @head.nil?
    popped_node.value
  end

  # Returns true if the passed in value is in the list and otherwise returns false.
  #
  # @param value [Object] Value to search for.
  # @return [Boolean] True if value is present, false otherwise.
  def contains?(value)
    current = @head
    while current
      return true if current.value == value

      current = current.next_node
    end
    false
  end

  alias include? contains?

  # Returns the index of the first node containing the matching value.
  # If the value isn't found, returns nil.
  #
  # @param value [Object] Value to find index for.
  # @return [Integer, nil] The 0-based index of the matching node, or nil.
  def index(value)
    current = @head
    idx = 0
    while current
      return idx if current.value == value

      idx += 1
      current = current.next_node
    end
    nil
  end

  alias find_index index

  # Returns true if the list contains no elements.
  #
  # @return [Boolean]
  def empty?
    @head.nil?
  end

  # Represents LinkedList objects as formatted strings.
  # Format: ( value ) -> ( value ) -> ( value ) -> nil
  # Returns an empty string if the list is empty.
  #
  # @return [String] Formatted string representation.
  def to_s
    return '' if @head.nil?

    parts = []
    current = @head
    while current
      parts << "( #{current.value} )"
      current = current.next_node
    end
    parts << 'nil'
    parts.join(' -> ')
  end

  # Extra Credit:
  # Inserts new nodes with the given values at the specified index.
  # Raises IndexError if index is out of bounds (below 0 or above list size).
  #
  # @param index [Integer] 0-based insertion point (0..size).
  # @param values [Array<Object>] One or more values to insert.
  # @return [LinkedList] Returns self to allow chaining.
  def insert_at(index, *values)
    raise IndexError, "Index #{index} out of bounds for list of size #{@size}" if index.negative? || index > @size

    return self if values.empty?

    # Construct the chain of new nodes
    first_new_node = Node.new(values.first)
    last_new_node = first_new_node
    values[1..].each do |val|
      new_node = Node.new(val)
      last_new_node.next_node = new_node
      last_new_node = new_node
    end

    if index.zero?
      last_new_node.next_node = @head
      @head = first_new_node
      @tail = last_new_node if @tail.nil?
    elsif index == @size
      @tail.next_node = first_new_node
      @tail = last_new_node
    else
      prev_node = node_at(index - 1)
      last_new_node.next_node = prev_node.next_node
      prev_node.next_node = first_new_node
    end

    @size += values.size
    self
  end

  # Extra Credit:
  # Removes the node at the given index and returns its value.
  # Raises IndexError if index is out of bounds (below 0 or >= list size).
  #
  # @param index [Integer] 0-based index of the node to remove (0...size).
  # @return [Object] The value of the removed node.
  def remove_at(index)
    raise IndexError, "Index #{index} out of bounds for list of size #{@size}" if index.negative? || index >= @size

    if index.zero?
      target_node = @head
      @head = @head.next_node
      @tail = nil if @head.nil?
    else
      prev_node = node_at(index - 1)
      target_node = prev_node.next_node
      prev_node.next_node = target_node.next_node
      @tail = prev_node if target_node == @tail
    end

    @size -= 1
    target_node.value
  end

  # Yields the value of each node in the list.
  # Enables Enumerable module methods (map, select, reject, any?, all?, etc.).
  #
  # @yield [Object] The value of each node.
  # @return [LinkedList, Enumerator]
  def each
    return to_enum(:each) unless block_given?

    current = @head
    while current
      yield current.value
      current = current.next_node
    end
    self
  end
end
