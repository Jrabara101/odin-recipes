# lib/board.rb

class Board
  ROWS = 6
  COLUMNS = 7
  EMPTY = ' '

  attr_reader :grid

  def initialize
    @grid = Array.new(ROWS) { Array.new(COLUMNS, EMPTY) }
  end

  def valid_column?(column)
    return false unless column.is_a?(Integer)
    return false unless column.between?(1, COLUMNS)

    !column_full?(column)
  end

  def column_full?(column)
    return false unless column.is_a?(Integer) && column.between?(1, COLUMNS)

    @grid[0][column - 1] != EMPTY
  end

  def drop_piece(column, symbol)
    return false unless valid_column?(column)

    col_index = column - 1
    (ROWS - 1).downto(0) do |row|
      if @grid[row][col_index] == EMPTY
        @grid[row][col_index] = symbol
        return true
      end
    end

    false
  end

  def full?
    @grid.flatten.none? { |cell| cell == EMPTY }
  end

  def win?(symbol)
    horizontal_win?(symbol) ||
      vertical_win?(symbol) ||
      diagonal_ascending_win?(symbol) ||
      diagonal_descending_win?(symbol)
  end

  def render
    lines = []
    lines << "\n  1   2   3   4   5   6   7"
    lines << "+---+---+---+---+---+---+---+"

    @grid.each do |row|
      formatted_cells = row.map do |cell|
        cell == EMPTY ? ' ' : cell
      end
      lines << "| #{formatted_cells.join(' | ')} |"
      lines << "+---+---+---+---+---+---+---+"
    end

    lines << "  1   2   3   4   5   6   7\n"
    lines.join("\n")
  end

  private

  def horizontal_win?(symbol)
    (0...ROWS).any? do |row|
      (0..(COLUMNS - 4)).any? do |col|
        (0..3).all? { |i| @grid[row][col + i] == symbol }
      end
    end
  end

  def vertical_win?(symbol)
    (0..(ROWS - 4)).any? do |row|
      (0...COLUMNS).any? do |col|
        (0..3).all? { |i| @grid[row + i][col] == symbol }
      end
    end
  end

  def diagonal_ascending_win?(symbol)
    # Ascending diagonal (/): starts at row 3..5, col 0..3
    (3...ROWS).any? do |row|
      (0..(COLUMNS - 4)).any? do |col|
        (0..3).all? { |i| @grid[row - i][col + i] == symbol }
      end
    end
  end

  def diagonal_descending_win?(symbol)
    # Descending diagonal (\): starts at row 0..2, col 0..3
    (0..(ROWS - 4)).any? do |row|
      (0..(COLUMNS - 4)).any? do |col|
        (0..3).all? { |i| @grid[row + i][col + i] == symbol }
      end
    end
  end
end
