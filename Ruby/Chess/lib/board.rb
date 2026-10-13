# frozen_string_literal: true

require_relative 'piece'
require_relative 'pieces/pawn'
require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/rook'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'move'

# Represents the 8x8 chess board, pieces, move execution, and state checks.
class Board
  attr_reader :grid, :move_history, :captured_pieces
  attr_accessor :en_passant_target, :halfmove_clock, :fullmove_number

  def initialize(setup: true)
    @grid = Array.new(8) { Array.new(8) }
    @en_passant_target = nil
    @halfmove_clock = 0
    @fullmove_number = 1
    @move_history = []
    @captured_pieces = { white: [], black: [] }
    setup_standard_board if setup
  end

  def [](pos)
    piece_at(pos)
  end

  def []=(pos, piece)
    r, c = pos
    @grid[r][c] = piece
    piece.position = pos if piece
  end

  def piece_at(pos)
    return nil unless valid_pos?(pos)

    r, c = pos
    @grid[r][c]
  end

  def valid_pos?(pos)
    return false if pos.nil? || !pos.is_a?(Array) || pos.size != 2

    r, c = pos
    r.between?(0, 7) && c.between?(0, 7)
  end

  def clear
    @grid = Array.new(8) { Array.new(8) }
  end

  def setup_standard_board
    clear
    # Setup Black pieces (ranks 8 and 7, rows 0 and 1)
    @grid[0][0] = Rook.new(:black, [0, 0])
    @grid[0][1] = Knight.new(:black, [0, 1])
    @grid[0][2] = Bishop.new(:black, [0, 2])
    @grid[0][3] = Queen.new(:black, [0, 3])
    @grid[0][4] = King.new(:black, [0, 4])
    @grid[0][5] = Bishop.new(:black, [0, 5])
    @grid[0][6] = Knight.new(:black, [0, 6])
    @grid[0][7] = Rook.new(:black, [0, 7])
    8.times { |c| @grid[1][c] = Pawn.new(:black, [1, c]) }

    # Setup White pieces (ranks 2 and 1, rows 6 and 7)
    8.times { |c| @grid[6][c] = Pawn.new(:white, [6, c]) }
    @grid[7][0] = Rook.new(:white, [7, 0])
    @grid[7][1] = Knight.new(:white, [7, 1])
    @grid[7][2] = Bishop.new(:white, [7, 2])
    @grid[7][3] = Queen.new(:white, [7, 3])
    @grid[7][4] = King.new(:white, [7, 4])
    @grid[7][5] = Bishop.new(:white, [7, 5])
    @grid[7][6] = Knight.new(:white, [7, 6])
    @grid[7][7] = Rook.new(:white, [7, 7])
  end

  def all_pieces(color = nil)
    pieces = @grid.flatten.compact
    color ? pieces.select { |p| p.color == color.to_sym } : pieces
  end

  def find_king(color)
    all_pieces(color).find { |p| p.is_a?(King) }
  end

  # Returns true if `pos` is attacked by any piece of `by_color`
  def square_attacked?(pos, by_color)
    all_pieces(by_color).any? do |piece|
      piece.attacks(self).include?(pos)
    end
  end

  def in_check?(color)
    king = find_king(color)
    return false unless king && king.position

    opponent_color = (color.to_sym == :white ? :black : :white)
    square_attacked?(king.position, opponent_color)
  end

  # Returns legal destination positions for the piece at `from_pos`
  def legal_moves(from_pos)
    piece = piece_at(from_pos)
    return [] unless piece

    pseudolegal = piece.pseudolegal_moves(self)
    pseudolegal.select do |to_pos|
      !move_leaves_king_in_check?(from_pos, to_pos)
    end
  end

  # Builds a Move object from `from` to `to`, detecting special moves
  def build_move(from, to, promotion = nil)
    piece = piece_at(from)
    return nil unless piece

    dest_piece = piece_at(to)
    is_ep = piece.is_a?(Pawn) && to == @en_passant_target && dest_piece.nil? && from[1] != to[1]

    captured = if is_ep
                 piece_at([from[0], to[1]])
               else
                 dest_piece
               end

    castling = nil
    if piece.is_a?(King) && (to[1] - from[1]).abs == 2
      castling = to[1] > from[1] ? :kingside : :queenside
    end

    promo = nil
    if piece.is_a?(Pawn) && to[0] == piece.promotion_row
      promo = promotion || :queen
    end

    Move.new(
      from: from,
      to: to,
      piece: piece,
      captured: captured,
      castling: castling,
      en_passant: is_ep,
      promotion: promo
    )
  end

  # Simulates move on a deep copy to ensure it doesn't leave friendly king in check
  def move_leaves_king_in_check?(from, to)
    temp_board = duplicate
    temp_move = temp_board.build_move(from, to)
    return true unless temp_move

    temp_board.execute_move!(temp_move)
    temp_board.in_check?(temp_move.piece.color)
  end

  # Executes move and updates board state, clocks, captures, and flags
  def make_move(move)
    execute_move!(move)
    @move_history << move
    move
  end

  # Internal move execution (used by both real moves and simulations)
  def execute_move!(move)
    from = move.from
    to = move.to
    piece = piece_at(from) || move.piece

    # 1. En Passant capture removal
    if move.en_passant?
      ep_pawn_pos = [from[0], to[1]]
      captured_pawn = piece_at(ep_pawn_pos)
      if captured_pawn
        @captured_pieces[captured_pawn.color] << captured_pawn
        self[ep_pawn_pos] = nil
      end
    elsif move.captured
      @captured_pieces[move.captured.color] << move.captured
    end

    # 2. Castling: move corresponding rook
    if move.castling?
      r = from[0]
      if move.castling == :kingside
        rook = piece_at([r, 7])
        self[[r, 7]] = nil
        self[[r, 5]] = rook
        rook.position = [r, 5]
        rook.moved = true
      elsif move.castling == :queenside
        rook = piece_at([r, 0])
        self[[r, 0]] = nil
        self[[r, 3]] = rook
        rook.position = [r, 3]
        rook.moved = true
      end
    end

    # 3. Move the piece
    self[from] = nil

    if move.promotion?
      promoted_piece = create_promoted_piece(move.promotion, piece.color, to)
      promoted_piece.moved = true
      self[to] = promoted_piece
    else
      piece.position = to
      piece.moved = true
      self[to] = piece
    end

    # 4. En Passant target update
    if piece.is_a?(Pawn) && (to[0] - from[0]).abs == 2
      @en_passant_target = [(from[0] + to[0]) / 2, from[1]]
    else
      @en_passant_target = nil
    end

    # 5. Halfmove clock update (50-move rule)
    if piece.is_a?(Pawn) || move.capture?
      @halfmove_clock = 0
    else
      @halfmove_clock += 1
    end

    # 6. Fullmove number update
    @fullmove_number += 1 if piece.black?
  end

  def create_promoted_piece(promo_type, color, pos)
    case promo_type.to_s.downcase.to_sym
    when :rook, :r
      Rook.new(color, pos)
    when :bishop, :b
      Bishop.new(color, pos)
    when :knight, :n
      Knight.new(color, pos)
    else # default Queen
      Queen.new(color, pos)
    end
  end

  # Returns all legal Move objects for the given color
  def all_legal_moves(color)
    moves = []
    all_pieces(color).each do |piece|
      from = piece.position
      legal_dests = legal_moves(from)
      legal_dests.each do |to|
        if piece.is_a?(Pawn) && to[0] == piece.promotion_row
          %i[queen rook bishop knight].each do |promo|
            moves << build_move(from, to, promo)
          end
        else
          moves << build_move(from, to)
        end
      end
    end
    moves.compact
  end

  def checkmate?(color)
    in_check?(color) && all_legal_moves(color).empty?
  end

  def stalemate?(color)
    !in_check?(color) && all_legal_moves(color).empty?
  end

  # FIDE Insufficient Material checks:
  # - King vs King
  # - King + Bishop vs King
  # - King + Knight vs King
  # - King + Bishop vs King + Bishop (same square color)
  def insufficient_material?
    pieces = all_pieces
    return false if pieces.any? { |p| p.is_a?(Pawn) || p.is_a?(Rook) || p.is_a?(Queen) }

    white_pieces = pieces.select(&:white?)
    black_pieces = pieces.select(&:black?)

    # King vs King
    return true if white_pieces.size == 1 && black_pieces.size == 1

    # King + (Bishop/Knight) vs King
    if white_pieces.size == 2 && black_pieces.size == 1
      minor = white_pieces.find { |p| !p.is_a?(King) }
      return true if minor.is_a?(Bishop) || minor.is_a?(Knight)
    elsif black_pieces.size == 2 && white_pieces.size == 1
      minor = black_pieces.find { |p| !p.is_a?(King) }
      return true if minor.is_a?(Bishop) || minor.is_a?(Knight)
    end

    # King + Bishop vs King + Bishop (bishops on same color squares)
    if white_pieces.size == 2 && black_pieces.size == 2
      w_bishop = white_pieces.find { |p| p.is_a?(Bishop) }
      b_bishop = black_pieces.find { |p| p.is_a?(Bishop) }
      if w_bishop && b_bishop
        w_square_color = (w_bishop.position[0] + w_bishop.position[1]) % 2
        b_square_color = (b_bishop.position[0] + b_bishop.position[1]) % 2
        return true if w_square_color == b_square_color
      end
    end

    false
  end

  def fifty_move_rule?
    @halfmove_clock >= 100
  end

  # Returns game status symbol or nil if game is ongoing
  def game_status(current_color)
    return :checkmate if checkmate?(current_color)
    return :stalemate if stalemate?(current_color)
    return :insufficient_material if insufficient_material?
    return :fifty_move_rule if fifty_move_rule?

    nil
  end

  def game_over?(current_color)
    !game_status(current_color).nil?
  end

  # Creates a deep copy of the board and all pieces
  def duplicate
    new_board = Board.new(setup: false)
    new_board.en_passant_target = @en_passant_target ? @en_passant_target.dup : nil
    new_board.halfmove_clock = @halfmove_clock
    new_board.fullmove_number = @fullmove_number

    8.times do |r|
      8.times do |c|
        piece = @grid[r][c]
        next unless piece

        cloned_piece = piece.class.new(piece.color, [r, c])
        cloned_piece.moved = piece.moved?
        new_board[[r, c]] = cloned_piece
      end
    end

    # Duplicate captured pieces
    new_board.instance_variable_set(
      :@captured_pieces,
      {
        white: @captured_pieces[:white].map { |p| p.class.new(p.color, nil) },
        black: @captured_pieces[:black].map { |p| p.class.new(p.color, nil) }
      }
    )

    new_board
  end
end
