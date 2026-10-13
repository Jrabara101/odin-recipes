# frozen_string_literal: true

# Base class representing a generic chess piece.
class Piece
  attr_reader :color
  attr_accessor :position, :moved

  def initialize(color, position = nil)
    @color = color.to_sym
    @position = position
    @moved = false
  end

  def white?
    @color == :white
  end

  def black?
    @color == :black
  end

  def enemy?(other)
    return false if other.nil?

    @color != other.color
  end

  def friendly?(other)
    return false if other.nil?

    @color == other.color
  end

  def moved?
    @moved
  end

  # Returns array of [row, col] coordinates where this piece can move/attack geometrically.
  def pseudolegal_moves(_board)
    raise NotImplementedError, "#{self.class} must implement #pseudolegal_moves"
  end

  # Returns squares attacked by this piece (for check detection).
  # By default, for most pieces, attack squares equal pseudolegal moves.
  # (Pawn overrides this because forward moves are not attacks, and diagonal moves attack even if empty).
  def attacks(board)
    pseudolegal_moves(board)
  end

  # Relative piece value for AI evaluation and heuristics
  def value
    0
  end

  def symbol
    "?"
  end

  def to_s
    symbol
  end

  def to_h
    {
      type: self.class.name.downcase,
      color: @color.to_s,
      position: @position,
      moved: @moved
    }
  end

  # Helper for sliding pieces (Rook, Bishop, Queen)
  def sliding_moves(board, directions)
    moves = []
    r, c = @position

    directions.each do |dr, dc|
      curr_r = r + dr
      curr_c = c + dc

      while board.valid_pos?([curr_r, curr_c])
        target = board.piece_at([curr_r, curr_c])
        if target.nil?
          moves << [curr_r, curr_c]
        elsif enemy?(target)
          moves << [curr_r, curr_c]
          break
        else
          break
        end

        curr_r += dr
        curr_c += dc
      end
    end

    moves
  end

  # Helper for stepping pieces (Knight, King)
  def stepping_moves(board, offsets)
    moves = []
    r, c = @position

    offsets.each do |dr, dc|
      target_pos = [r + dr, c + dc]
      next unless board.valid_pos?(target_pos)

      target = board.piece_at(target_pos)
      moves << target_pos if target.nil? || enemy?(target)
    end

    moves
  end
end
