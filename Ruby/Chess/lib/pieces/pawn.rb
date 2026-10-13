# frozen_string_literal: true

require_relative '../piece'

class Pawn < Piece
  def direction
    white? ? -1 : 1
  end

  def start_row
    white? ? 6 : 1
  end

  def promotion_row
    white? ? 0 : 7
  end

  def value
    100
  end

  def symbol
    white? ? "♙" : "♟"
  end

  def pseudolegal_moves(board)
    moves = []
    r, c = @position
    dir = direction

    # 1. Single step forward
    one_step = [r + dir, c]
    if board.valid_pos?(one_step) && board.piece_at(one_step).nil?
      moves << one_step

      # 2. Double step forward from starting rank
      two_step = [r + (2 * dir), c]
      if (r == start_row || !moved?) && board.valid_pos?(two_step) && board.piece_at(two_step).nil?
        moves << two_step
      end
    end

    # 3. Diagonal captures & En Passant
    [-1, 1].each do |dc|
      diag_pos = [r + dir, c + dc]
      next unless board.valid_pos?(diag_pos)

      target = board.piece_at(diag_pos)
      if enemy?(target)
        moves << diag_pos
      elsif board.en_passant_target == diag_pos
        moves << diag_pos
      end
    end

    moves
  end

  # Attacks for pawns are only diagonal squares
  def attacks(board)
    attack_squares = []
    r, c = @position
    dir = direction

    [-1, 1].each do |dc|
      diag_pos = [r + dir, c + dc]
      attack_squares << diag_pos if board.valid_pos?(diag_pos)
    end

    attack_squares
  end
end
