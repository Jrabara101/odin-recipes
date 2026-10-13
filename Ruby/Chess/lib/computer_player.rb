# frozen_string_literal: true

require_relative 'player'

# Computer AI player that evaluates legal moves with heuristics.
class ComputerPlayer < Player
  attr_reader :difficulty

  def initialize(color, name = nil, difficulty: :smart)
    super(color, name || "ChessBot (#{@color.to_s.capitalize})")
    @difficulty = difficulty
  end

  def human?
    false
  end

  def get_move(board, _game = nil)
    legal_moves = board.all_legal_moves(@color)
    return nil if legal_moves.empty?

    if @difficulty == :random
      legal_moves.sample
    else
      choose_best_move(board, legal_moves)
    end
  end

  private

  def choose_best_move(board, legal_moves)
    opponent_color = (@color == :white ? :black : :white)
    scored_moves = legal_moves.map do |move|
      score = evaluate_move(board, move, opponent_color)
      [move, score]
    end

    max_score = scored_moves.map(&:last).max
    best_candidates = scored_moves.select { |_, s| s == max_score }.map(&:first)

    # Pick randomly among top moves for variety
    best_candidates.sample
  end

  def evaluate_move(board, move, opponent_color)
    score = 0

    # 1. Simulate the move
    temp_board = board.duplicate
    temp_move = temp_board.build_move(move.from, move.to, move.promotion)
    temp_board.execute_move!(temp_move)

    # Immediate win checkmate
    return 100_000 if temp_board.checkmate?(opponent_color)

    # 2. Capture evaluation
    if move.captured
      # Material gain: value of captured piece minus potential loss
      score += move.captured.value * 10
      # MVV-LVA bonus: prefer capturing with smaller piece
      score += (1000 - move.piece.value) / 10
    end

    # 3. Pawn promotion
    score += 900 if move.promotion?

    # 4. Castling king safety bonus
    score += 60 if move.castling?

    # 5. Check bonus
    score += 45 if temp_board.in_check?(opponent_color)

    # 6. Center control bonus (d4, e4, d5, e5)
    r, c = move.to
    if (r == 3 || r == 4) && (c == 3 || c == 4)
      score += 25
    elsif (r >= 2 && r <= 5) && (c >= 2 && c <= 5)
      score += 10
    end

    # 7. Check if destination is attacked by opponent
    if temp_board.square_attacked?(move.to, opponent_color)
      # Penalty for putting piece in danger
      score -= move.piece.value * 8
    end

    # 8. Minor random jitter (-3..3) to prevent repetitive play in equal positions
    score += rand(-3..3)

    score
  end
end
