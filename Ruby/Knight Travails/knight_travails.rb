# frozen_string_literal: true

require 'set'
require_relative 'node'
require_relative 'board'

# KnightTravails solves the shortest-path problem for a knight piece on a chessboard
# using Breadth-First Search (BFS).
#
# Because all knight moves in this unweighted graph have equal cost (1 move),
# BFS guarantees discovering a shortest path first. Visited squares are tracked
# in a Set to prevent cycles and redundant state expansions.
class KnightTravails
  attr_reader :board

  def initialize(board = Board.new)
    @board = board
  end

  # Finds the shortest path between start_pos and target_pos using BFS.
  #
  # @param start_pos [Array<Integer>] [x, y] coordinates of the starting square
  # @param target_pos [Array<Integer>] [x, y] coordinates of the destination square
  # @return [Array<Array<Integer>>] Ordered array of coordinates from start to target
  def find_path(start_pos, target_pos)
    validate_coordinate!(start_pos, 'start')
    validate_coordinate!(target_pos, 'target')

    # Edge case: starting on the target square requires 0 moves
    return [start_pos] if start_pos == target_pos

    # Breadth-First Search queue initialized with root node
    root_node = KnightNode.new(start_pos)
    queue = [root_node]
    visited = Set.new([start_pos])

    until queue.empty?
      current_node = queue.shift

      @board.possible_moves(current_node.position).each do |next_pos|
        next if visited.include?(next_pos)

        child_node = KnightNode.new(next_pos, current_node)

        # Early return if destination is reached
        return child_node.path if next_pos == target_pos

        visited.add(next_pos)
        queue.push(child_node)
      end
    end

    nil
  end

  # Executes the path search, formats and displays the results as requested by
  # The Odin Project specifications, and returns the path array.
  #
  # @param start_pos [Array<Integer>] Starting square [x, y]
  # @param target_pos [Array<Integer>] Ending square [x, y]
  # @param display [Boolean] Whether to print the output text to stdout
  # @param visualize [Boolean] Whether to display an ASCII chessboard
  # @return [Array<Array<Integer>>] The shortest path
  def knight_moves(start_pos, target_pos, display: true, visualize: false)
    path = find_path(start_pos, target_pos)
    return nil unless path

    if display
      move_count = path.length - 1
      move_word = move_count == 1 ? 'move' : 'moves'
      puts "You made it in #{move_count} #{move_word}!  Here's your path:"
      path.each { |square| puts "  #{square.inspect}" }
      puts "\n#{@board.visualize_path(path)}\n" if visualize
    end

    path
  end

  private

  def validate_coordinate!(pos, label)
    return if @board.valid_position?(pos)

    max_idx = @board.size - 1
    raise ArgumentError,
          "Invalid #{label} position #{pos.inspect}. Coordinates must be [x, y] integers between 0 and #{max_idx}."
  end
end

# Top-level helper function satisfying The Odin Project assignment interface:
#   knight_moves([0,0],[1,2]) # returns [[0,0],[1,2]]
def knight_moves(start_pos, target_pos, display: true, visualize: false)
  KnightTravails.new.knight_moves(start_pos, target_pos, display: display, visualize: visualize)
end
