# frozen_string_literal: true

require_relative '../piece'

class Knight < Piece
  OFFSETS = [
    [-2, -1], [-2, 1],
    [-1, -2], [-1, 2],
    [1, -2],  [1, 2],
    [2, -1],  [2, 1]
  ].freeze

  def value
    320
  end

  def symbol
    white? ? "♘" : "♞"
  end

  def pseudolegal_moves(board)
    stepping_moves(board, OFFSETS)
  end
end
