# frozen_string_literal: true

# Handles terminal rendering of the chess board, pieces, alerts, and captured list.
class Display
  RESET       = "\e[0m"
  BOLD        = "\e[1m"
  DIM         = "\e[2m"

  # Colors for piece foregrounds
  WHITE_PIECE = "\e[1;97m"      # Bold Bright White
  BLACK_PIECE = "\e[1;30m"      # Bold Black / Dark Slate

  # Colors for board squares
  LIGHT_BG    = "\e[48;5;253m"  # Soft Light Grey / Cream
  DARK_BG     = "\e[48;5;242m"  # Soft Charcoal Grey
  LAST_MOVE_BG= "\e[48;5;179m"  # Warm Amber highlight
  CHECK_BG    = "\e[48;5;196m"  # Crimson Red highlight for king in check

  # UI accents
  CYAN_BOLD   = "\e[1;36m"
  GREEN_BOLD  = "\e[1;32m"
  YELLOW_BOLD = "\e[1;33m"
  RED_BOLD    = "\e[1;31m"

  # Solid Unicode glyphs for uniform visual sizing
  GLYPHS = {
    pawn:   '♟',
    knight: '♞',
    bishop: '♝',
    rook:   '♜',
    queen:  '♛',
    king:   '♚'
  }.freeze

  def self.clear_screen
    print "\e[H\e[2J"
  end

  def self.render(board, current_turn = :white, last_move: nil)
    output = []
    output << "\n" + header(current_turn)
    output << captured_summary(board)
    output << "       a    b    c    d    e    f    g    h"
    output << "     +----+----+----+----+----+----+----+----+"

    in_check_pos = board.in_check?(current_turn) ? board.find_king(current_turn)&.position : nil

    8.times do |r|
      rank_num = 8 - r
      row_str = "  #{rank_num}  |"

      8.times do |c|
        pos = [r, c]
        piece = board.piece_at(pos)

        # Background color selection
        bg = if pos == in_check_pos
               CHECK_BG
             elsif last_move && (pos == last_move.from || pos == last_move.to)
               LAST_MOVE_BG
             elsif (r + c).even?
               LIGHT_BG
             else
               DARK_BG
             end

        # Piece glyph & color
        cell_content = if piece.nil?
                         "    "
                       else
                         fg = piece.white? ? WHITE_PIECE : BLACK_PIECE
                         glyph = GLYPHS[piece.class.name.downcase.to_sym] || piece.symbol
                         " #{fg}#{glyph} #{RESET}#{bg} "
                       end

        row_str += "#{bg}#{cell_content}#{RESET}|"
      end

      row_str += "  #{rank_num}"
      output << row_str
      output << "     +----+----+----+----+----+----+----+----+"
    end

    output << "       a    b    c    d    e    f    g    h\n"

    # Status alerts
    if board.in_check?(current_turn)
      output << "#{RED_BOLD}  ⚠️  CHECK! #{current_turn.to_s.capitalize}'s King is under attack!#{RESET}"
    end

    if last_move
      output << "  Last Move: #{last_move} (#{last_move.piece.color.to_s.capitalize})"
    end

    puts output.join("\n")
  end

  def self.header(turn)
    turn_str = if turn == :white
                 "#{WHITE_PIECE} WHITE'S TURN #{RESET}"
               else
                 "#{CYAN_BOLD} BLACK'S TURN #{RESET}"
               end

    "  ====================[ #{turn_str} ]===================="
  end

  def self.captured_summary(board)
    white_captured = board.captured_pieces[:white].map { |p| GLYPHS[p.class.name.downcase.to_sym] }.join(' ')
    black_captured = board.captured_pieces[:black].map { |p| GLYPHS[p.class.name.downcase.to_sym] }.join(' ')

    white_val = board.captured_pieces[:white].sum(&:value)
    black_val = board.captured_pieces[:black].sum(&:value)
    diff = (white_val - black_val) / 100

    advantage_str = if diff > 0
                      "#{YELLOW_BOLD}(Black +#{diff})#{RESET}"
                    elsif diff < 0
                      "#{YELLOW_BOLD}(White +#{diff.abs})#{RESET}"
                    else
                      ""
                    end

    [
      "  White lost: [ #{white_captured} ]",
      "  Black lost: [ #{black_captured} ] #{advantage_str}"
    ].join("\n")
  end

  def self.show_help
    puts <<~HELP

      ============================= CHESS INSTRUCTIONS =============================
      HOW TO ENTER A MOVE:
        1. Coordinate notation:
           - Type source and destination coordinates together: 'e2e4' or 'e2 e4'
           - Standard format: 'g1f3', 'e7e5', 'b8c6'
        2. Castling:
           - Kingside castling:  'O-O' or '0-0'
           - Queenside castling: 'O-O-O' or '0-0-0'
        3. Pawn Promotion:
           - Optionally append piece letter: 'e7e8q' or 'e7e8=n'
           - If not appended, the game will ask you to choose Q, R, B, or N.
        4. Select square to inspect legal moves:
           - Enter a single coordinate like 'e2' to see all legal squares for that piece!

      COMMANDS:
        - save   : Save your current game to file
        - load   : Load a previously saved game
        - resign : Forfeit the match
        - draw   : Offer a draw to your opponent
        - help   : View these instructions
        - quit   : Exit the game
      =============================================================================

    HELP
  end
end
