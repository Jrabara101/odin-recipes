# frozen_string_literal: true

require_relative '../piece'

class King < Piece
  OFFSETS = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1],           [0, 1],
    [1, -1],  [1, 0],  [1, 1]
  ].freeze

  def value
    20_000
  end

  def symbol
    white? ? "♔" : "♚"
  end

  # Attacks for the king are strictly the 8 adjacent squares
  def attacks(board)
    stepping_moves(board, OFFSETS)
  end

  def pseudolegal_moves(board)
    stepping_moves(board, OFFSETS) + castling_moves(board)
  end

  def castling_moves(board)
    moves = []
    return moves if moved? || @position.nil?

    # King cannot castle while in check
    return moves if board.in_check?(@color)

    row = white? ? 7 : 0
    opponent = white? ? :black : :white

    # Ensure king is on its home square
    return moves unless @position == [row, 4]

    # Kingside Castling (O-O)
    kingside_rook = board.piece_at([row, 7])
    if kingside_rook.is_a?(Rook) && kingside_rook.friendly?(self) && !kingside_rook.moved?
      # Squares between king and rook must be empty: row,5 and row,6
      if board.piece_at([row, 5]).nil? && board.piece_at([row, 6]).nil?
        # Squares king passes through and lands on must not be under attack
        unless board.square_attacked?([row, 5], opponent) || board.square_attacked?([row, 6], opponent)
          moves << [row, 6]
        end
      end
    end

    # Queenside Castling (O-O-O)
    queenside_rook = board.piece_at([row, 0])
    if queenside_rook.is_a?(Rook) && queenside_rook.friendly?(self) && !queenside_rook.moved?
      # Squares between king and rook must be empty: row,1, row,2, row,3
      if board.piece_at([row, 1]).nil? && board.piece_at([row, 2]).nil? && board.piece_at([row, 3]).nil?
        # King moves across row,3 and lands on row,2. Neither may be attacked.
        unless board.square_attacked?([row, 3], opponent) || board.square_attacked?([row, 2], opponent)
          moves << [row, 2]
        end
      end
    end

    moves
  end
end
