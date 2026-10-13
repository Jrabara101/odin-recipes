# frozen_string_literal: true

# Board encapsulates the chessboard dimensions, coordinate validation,
# valid knight move generation, and ASCII board path visualization.
class Board
  BOARD_SIZE = 8

  # The 8 possible L-shaped move offsets for a knight in chess
  KNIGHT_OFFSETS = [
    [1, 2], [2, 1], [2, -1], [1, -2],
    [-1, -2], [-2, -1], [-2, 1], [-1, 2]
  ].freeze

  attr_reader :size

  def initialize(size = BOARD_SIZE)
    @size = size
    @range = 0...@size
  end

  # Checks whether a given coordinate pair falls within the board boundaries
  #
  # @param pos [Array<Integer>] [x, y] coordinates
  # @return [Boolean] true if valid, false otherwise
  def valid_position?(pos)
    pos.is_a?(Array) &&
      pos.length == 2 &&
      pos[0].is_a?(Integer) &&
      pos[1].is_a?(Integer) &&
      @range.cover?(pos[0]) &&
      @range.cover?(pos[1])
  end

  # Returns all valid squares a knight can move to from the given square
  #
  # @param pos [Array<Integer>] Starting [x, y] position
  # @return [Array<Array<Integer>>] Array of legal destination coordinates
  def possible_moves(pos)
    raise ArgumentError, "Invalid board position: #{pos.inspect}" unless valid_position?(pos)

    x, y = pos
    KNIGHT_OFFSETS.each_with_object([]) do |(dx, dy), moves|
      candidate = [x + dx, y + dy]
      moves << candidate if valid_position?(candidate)
    end
  end

  # Generates an ASCII representation of the chessboard marking the path taken.
  # Ranks (y: 7..0) are displayed vertically and files (x: 0..7) horizontally.
  #
  # @param path [Array<Array<Integer>>] Ordered array of coordinates
  # @return [String] Formatted ASCII board
  def visualize_path(path)
    return 'Empty path' if path.nil? || path.empty?

    # Map positions to their step number
    step_map = {}
    path.each_with_index do |pos, index|
      step_map[pos] = index
    end

    total_steps = path.length - 1
    lines = []
    lines << "   y (rank)"

    # Render from top rank (@size - 1) down to rank 0
    (@size - 1).downto(0) do |y|
      row_cells = []
      (0...@size).each do |x|
        cell_pos = [x, y]
        if step_map.key?(cell_pos)
          step = step_map[cell_pos]
          if step == 0
            row_cells << '[S]'
          elsif step == total_steps
            row_cells << (total_steps < 10 ? "[#{step}]" : "[E]")
          else
            row_cells << format(' %d ', step)
          end
        else
          row_cells << ' . '
        end
      end
      lines << format(' %d | %s |', y, row_cells.join(' '))
    end

    separator_width = (@size * 4) + 1
    lines << "   +#{'-' * separator_width}+"

    file_numbers = (0...@size).map { |x| format(' %d ', x) }.join(' ')
    lines << "      #{file_numbers}   x (file)"
    lines << ''
    lines << "   Legend: [S] = Start (#{path.first.inspect}), [#{total_steps}] = Target (#{path.last.inspect}), numbers = intermediate steps"

    lines.join("\n")
  end
end
