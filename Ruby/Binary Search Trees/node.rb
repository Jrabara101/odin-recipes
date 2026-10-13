# frozen_string_literal: true

# Node represents a single element in a Binary Search Tree.
# Stores data along with references to left and right child nodes.
class Node
  include Comparable

  attr_accessor :data, :left, :right

  def initialize(data, left = nil, right = nil)
    @data = data
    @left = left
    @right = right
  end

  # Compare nodes based on their stored data
  def <=>(other)
    return nil unless other.is_a?(Node)

    data <=> other.data
  end

  def leaf?
    left.nil? && right.nil?
  end

  def one_child?
    (left.nil? && !right.nil?) || (!left.nil? && right.nil?)
  end

  def two_children?
    !left.nil? && !right.nil?
  end

  def only_child
    left || right
  end

  def to_s
    data.to_s
  end

  def inspect
    "Node(data: #{data.inspect}, left: #{left&.data.inspect}, right: #{right&.data.inspect})"
  end
end
