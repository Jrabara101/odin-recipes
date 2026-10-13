# frozen_string_literal: true

require_relative 'node'

# HashMap implementation using separate chaining for collision resolution.
# Follows The Odin Project specifications:
# - Enforces strict boundary checks on bucket access
# - Supports dynamic resizing based on capacity and load factor
# - Implements key-value operations with O(1) average time complexity
class HashMap
  DEFAULT_CAPACITY = 16
  DEFAULT_LOAD_FACTOR = 0.75

  attr_reader :capacity, :load_factor

  def initialize(capacity = DEFAULT_CAPACITY, load_factor = DEFAULT_LOAD_FACTOR)
    @capacity = capacity
    @load_factor = load_factor
    @buckets = Array.new(@capacity)
    @size = 0
  end

  # Calculates raw hash code using polynomial rolling hash with prime number 31.
  def raw_hash(key)
    hash_code = 0
    prime_number = 31
    key.to_s.each_char { |char| hash_code = prime_number * hash_code + char.ord }
    hash_code
  end

  # Produces a hash code mapped to the current capacity via modulo arithmetic.
  def hash(key)
    raw_hash(key) % @capacity
  end

  # Enforces boundary restriction on bucket indexes.
  def check_index(index)
    raise IndexError, "Index #{index} out of bounds for bucket size #{@buckets.length}" if index.negative? || index >= @buckets.length
  end

  # Retrieves the head node of a bucket by index with boundary checking.
  def bucket(index)
    check_index(index)
    @buckets[index]
  end

  # Sets or updates a key-value pair in the hash map.
  # If key already exists, updates the value without altering map length.
  # If key is new, prepends to bucket chain and resizes if load factor is exceeded.
  def set(key, value)
    index = hash(key)
    check_index(index)

    current_node = @buckets[index]
    while current_node
      if current_node.key == key
        current_node.value = value
        return value
      end
      current_node = current_node.next_node
    end

    # Key does not exist; prepend new node to the bucket chain
    new_node = Node.new(key, value, @buckets[index])
    @buckets[index] = new_node
    @size += 1

    resize if @size > @capacity * @load_factor

    value
  end

  # Returns the value associated with key, or nil if key is not found.
  def get(key)
    index = hash(key)
    check_index(index)

    current_node = @buckets[index]
    while current_node
      return current_node.value if current_node.key == key

      current_node = current_node.next_node
    end

    nil
  end

  # Returns true if key exists in the hash map, false otherwise.
  def has?(key)
    index = hash(key)
    check_index(index)

    current_node = @buckets[index]
    while current_node
      return true if current_node.key == key

      current_node = current_node.next_node
    end

    false
  end

  # Removes the entry with key from the hash map and returns its value.
  # Returns nil if the key is not found.
  def remove(key)
    index = hash(key)
    check_index(index)

    current_node = @buckets[index]
    previous_node = nil

    while current_node
      if current_node.key == key
        if previous_node.nil?
          @buckets[index] = current_node.next_node
        else
          previous_node.next_node = current_node.next_node
        end
        @size -= 1
        return current_node.value
      end
      previous_node = current_node
      current_node = current_node.next_node
    end

    nil
  end

  # Returns the number of stored keys in the hash map.
  def length
    @size
  end
  alias size length

  # Removes all entries from the hash map.
  def clear
    @buckets = Array.new(@capacity)
    @size = 0
  end

  # Returns an array containing all keys in the hash map.
  def keys
    all_keys = []
    @buckets.each do |head_node|
      current_node = head_node
      while current_node
        all_keys << current_node.key
        current_node = current_node.next_node
      end
    end
    all_keys
  end

  # Returns an array containing all values in the hash map.
  def values
    all_values = []
    @buckets.each do |head_node|
      current_node = head_node
      while current_node
        all_values << current_node.value
        current_node = current_node.next_node
      end
    end
    all_values
  end

  # Returns an array of [key, value] pairs.
  def entries
    all_entries = []
    @buckets.each do |head_node|
      current_node = head_node
      while current_node
        all_entries << [current_node.key, current_node.value]
        current_node = current_node.next_node
      end
    end
    all_entries
  end

  # Returns the current load level (size / capacity ratio).
  def load_level
    @size.to_f / @capacity
  end

  # Returns true if the hash map is empty.
  def empty?
    @size.zero?
  end

  def to_s
    entries_str = entries.map { |k, v| "#{k.inspect} => #{v.inspect}" }.join(', ')
    "{#{entries_str}}"
  end

  def inspect
    "#<#{self.class.name} size=#{length} capacity=#{@capacity} load_factor=#{@load_factor} entries=#{to_s}>"
  end

  private

  # Doubles the capacity and rehashes all existing entries into the expanded bucket array.
  def resize
    old_buckets = @buckets
    @capacity *= 2
    @buckets = Array.new(@capacity)
    @size = 0

    old_buckets.each do |head_node|
      current_node = head_node
      while current_node
        set(current_node.key, current_node.value)
        current_node = current_node.next_node
      end
    end
  end
end
