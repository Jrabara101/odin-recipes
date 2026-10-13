# frozen_string_literal: true

require_relative 'node'

# HashSet implementation storing unique keys without values.
# Part of The Odin Project Extra Credit:
# - Enforces identical boundary restrictions and load factor resizing as HashMap
# - Employs separate chaining to handle collisions
class HashSet
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

  # Adds a key to the hash set.
  # If key already exists, returns the key without incrementing length.
  # If key is new, prepends to bucket chain and resizes if load factor is exceeded.
  def set(key)
    index = hash(key)
    check_index(index)

    current_node = @buckets[index]
    while current_node
      return key if current_node.key == key

      current_node = current_node.next_node
    end

    new_node = Node.new(key, nil, @buckets[index])
    @buckets[index] = new_node
    @size += 1

    resize if @size > @capacity * @load_factor

    key
  end
  alias add set

  # Returns true if key exists in the hash set, false otherwise.
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
  alias include? has?

  # Removes the key from the hash set.
  # Returns the removed key if found, or nil if absent.
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
        return current_node.key
      end
      previous_node = current_node
      current_node = current_node.next_node
    end

    nil
  end
  alias delete remove

  # Returns the number of keys stored in the hash set.
  def length
    @size
  end
  alias size length

  # Removes all elements from the hash set.
  def clear
    @buckets = Array.new(@capacity)
    @size = 0
  end

  # Returns an array containing all keys in the hash set.
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
  alias entries keys

  # Returns the current load level (size / capacity ratio).
  def load_level
    @size.to_f / @capacity
  end

  # Returns true if the set is empty.
  def empty?
    @size.zero?
  end

  def to_s
    "#<#{self.class.name} {#{keys.map(&:inspect).join(', ')}}>"
  end

  def inspect
    "#<#{self.class.name} size=#{length} capacity=#{@capacity} load_factor=#{@load_factor} keys=#{keys.inspect}>"
  end

  private

  # Doubles capacity and rehashes all keys into expanded buckets.
  def resize
    old_buckets = @buckets
    @capacity *= 2
    @buckets = Array.new(@capacity)
    @size = 0

    old_buckets.each do |head_node|
      current_node = head_node
      while current_node
        set(current_node.key)
        current_node = current_node.next_node
      end
    end
  end
end
