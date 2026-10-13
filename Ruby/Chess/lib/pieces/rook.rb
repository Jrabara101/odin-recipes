# frozen_string_literal: true

require_relative '../piece'

class Rook < Piece
  DIRECTIONS = [
    [-1, 0], [1, 0],
    [0, -1], [0, 1]
  ].freeze

  def value
    500
  end

  def symbol
    white? ? "♖" : "♜"
  end

  def pseudolegal_moves(board)
    sliding_moves(board, DIRECTIONS)
  end
end
