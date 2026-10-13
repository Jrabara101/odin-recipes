# frozen_string_literal: true

# Node represents an individual entry in a bucket chain for separate chaining collision resolution.
class Node
  attr_accessor :key, :value, :next_node

  def initialize(key, value = nil, next_node = nil)
    @key = key
    @value = value
    @next_node = next_node
  end
end
