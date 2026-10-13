# frozen_string_literal: true

require_relative 'board'

# Utility to convert between Board state and Forsyth-Edwards Notation (FEN).
class FEN
  STARTING_FEN = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

  PIECE_MAP = {
    'p' => Pawn,
    'n' => Knight,
    'b' => Bishop,
    'r' => Rook,
    'q' => Queen,
    'k' => King
  }.freeze

  REVERSE_PIECE_MAP = {
    Pawn => 'p',
    Knight => 'n',
    Bishop => 'b',
    Rook => 'r',
    Queen => 'q',
    King => 'k'
  }.freeze

  # Loads a FEN string into a Board instance.
  # Returns a Hash: { board: Board, turn: :white/:black }
  def self.load(fen_string)
    parts = fen_string.strip.split(/\s+/)
    placement = parts[0]
    active_color = parts[1] == 'b' ? :black : :white
    castling = parts[2] || '-'
    ep_str = parts[3] || '-'
    halfmove = (parts[4] || 0).to_i
    fullmove = (parts[5] || 1).to_i

    board = Board.new(setup: false)
    ranks = placement.split('/')

    ranks.each_with_index do |rank_str, r|
      c = 0
      rank_str.each_char do |ch|
        if ch =~ /[1-8]/
          c += ch.to_i
        else
          color = (ch == ch.upcase ? :white : :black)
          piece_class = PIECE_MAP[ch.downcase]
          if piece_class
            piece = piece_class.new(color, [r, c])
            # By default set moved to true, then reset based on castling rights
            piece.moved = true
            board[[r, c]] = piece
          end
          c += 1
        end
      end
    end

    # Adjust castling pieces' moved flags
    w_king = board.find_king(:white)
    b_king = board.find_king(:black)

    if castling.include?('K') || castling.include?('Q')
      w_king&.moved = false
    end
    board.piece_at([7, 7])&.moved = false if castling.include?('K')
    board.piece_at([7, 0])&.moved = false if castling.include?('Q')

    if castling.include?('k') || castling.include?('q')
      b_king&.moved = false
    end
    board.piece_at([0, 7])&.moved = false if castling.include?('k')
    board.piece_at([0, 0])&.moved = false if castling.include?('q')

    # En passant target
    board.en_passant_target = ep_str == '-' ? nil : Move.coord_to_pos(ep_str)
    board.halfmove_clock = halfmove
    board.fullmove_number = fullmove

    { board: board, turn: active_color }
  end

  # Exports a Board instance and active turn to a FEN string
  def self.to_fen(board, active_turn = :white)
    # 1. Piece placement
    rank_strings = []
    8.times do |r|
      rank_str = ""
      empty_count = 0
      8.times do |c|
        piece = board.piece_at([r, c])
        if piece.nil?
          empty_count += 1
        else
          if empty_count > 0
            rank_str += empty_count.to_s
            empty_count = 0
          end
          char = REVERSE_PIECE_MAP[piece.class] || '?'
          rank_str += piece.white? ? char.upcase : char.downcase
        end
      end
      rank_str += empty_count.to_s if empty_count > 0
      rank_strings << rank_str
    end
    placement = rank_strings.join('/')

    # 2. Active turn
    turn_str = active_turn == :white ? 'w' : 'b'

    # 3. Castling rights
    castling = ""
    w_king = board.find_king(:white)
    if w_king && !w_king.moved? && w_king.position == [7, 4]
      castling += 'K' if board.piece_at([7, 7]).is_a?(Rook) && !board.piece_at([7, 7]).moved?
      castling += 'Q' if board.piece_at([7, 0]).is_a?(Rook) && !board.piece_at([7, 0]).moved?
    end

    b_king = board.find_king(:black)
    if b_king && !b_king.moved? && b_king.position == [0, 4]
      castling += 'k' if board.piece_at([0, 7]).is_a?(Rook) && !board.piece_at([0, 7]).moved?
      castling += 'q' if board.piece_at([0, 0]).is_a?(Rook) && !board.piece_at([0, 0]).moved?
    end
    castling = '-' if castling.empty?

    # 4. En passant
    ep_str = board.en_passant_target ? Move.pos_to_coord(board.en_passant_target) : '-'

    # 5. Halfmove clock
    halfmove = board.halfmove_clock

    # 6. Fullmove number
    fullmove = board.fullmove_number

    "#{placement} #{turn_str} #{castling} #{ep_str} #{halfmove} #{fullmove}"
  end
end
