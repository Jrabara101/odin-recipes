# frozen_string_literal: true

require_relative '../piece'

class Queen < Piece
  DIRECTIONS = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1],           [0, 1],
    [1, -1],  [1, 0],  [1, 1]
  ].freeze

  def value
    900
  end

  def symbol
    white? ? "♕" : "♛"
  end

  def pseudolegal_moves(board)
    sliding_moves(board, DIRECTIONS)
  end
end
