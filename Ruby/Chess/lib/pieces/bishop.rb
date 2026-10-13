# frozen_string_literal: true

require_relative '../piece'

class Bishop < Piece
  DIRECTIONS = [
    [-1, -1], [-1, 1],
    [1, -1],  [1, 1]
  ].freeze

  def value
    330
  end

  def symbol
    white? ? "♗" : "♝"
  end

  def pseudolegal_moves(board)
    sliding_moves(board, DIRECTIONS)
  end
end
