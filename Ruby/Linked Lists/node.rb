# frozen_string_literal: true

# The Odin Project - Project: Linked Lists
# Node class representing a single link in the LinkedList.
class Node
  attr_accessor :value, :next_node

  # Initializes a node with optional value and next_node reference.
  # Both default to nil as per the project specification.
  #
  # @param value [Object, nil] The value stored in this node.
  # @param next_node [Node, nil] The pointer to the subsequent node.
  def initialize(value = nil, next_node = nil)
    @value = value
    @next_node = next_node
  end
end
