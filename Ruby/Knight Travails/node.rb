# frozen_string_literal: true

# KnightNode represents a vertex in the knight's traversal graph.
# It holds a square coordinate [x, y], a reference to the parent node
# from which it was reached, and the step depth from the start position.
class KnightNode
  attr_reader :position, :parent, :depth

  def initialize(position, parent = nil)
    @position = position
    @parent = parent
    @depth = parent ? parent.depth + 1 : 0
  end

  # Returns the x-coordinate (file / column index)
  def x
    @position[0]
  end

  # Returns the y-coordinate (rank / row index)
  def y
    @position[1]
  end

  # Reconstructs the complete path from the root node to this node
  # by walking backwards along parent references and reversing the chain.
  #
  # @return [Array<Array<Integer>>] An ordered array of [x, y] coordinates
  def path
    current = self
    result = []

    while current
      result.unshift(current.position)
      current = current.parent
    end

    result
  end

  # Compares two nodes based on their position coordinates
  def ==(other)
    other.is_a?(KnightNode) && position == other.position
  end
  alias eql? ==

  def hash
    position.hash
  end

  def to_s
    position.inspect
  end

  def inspect
    "KnightNode(pos: #{position.inspect}, depth: #{depth})"
  end
end
