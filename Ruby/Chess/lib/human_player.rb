# frozen_string_literal: true

require_relative 'player'
require_relative 'move'

# Human player that interacts via terminal standard input.
class HumanPlayer < Player
  def human?
    true
  end

  # Returns either a Move object or a Symbol command (:save, :quit, :resign, :draw, :load, :help)
  def get_move(board, game = nil)
    loop do
      print "\n#{name} (#{@color.capitalize}), enter your move (e.g. 'e2e4', 'e2 e4', 'O-O') or command: "
      input = gets&.strip
      return :quit if input.nil? || input.downcase == 'exit' || input.downcase == 'quit'

      parsed = parse_input(input, board)
      case parsed[:type]
      when :command
        return parsed[:command]
      when :move
        move = validate_and_build(board, parsed[:from], parsed[:to], parsed[:promotion])
        return move if move
      when :piece_selected
        # Two-step selection: player chose a square, show moves and ask for destination
        dest_move = handle_destination_prompt(board, parsed[:pos])
        return dest_move if dest_move
      else
        puts "Invalid move format or command. Type 'help' for instructions."
      end
    end
  end

  def prompt_promotion
    loop do
      print "Promote pawn to (Q)ueen, (R)ook, (B)ishop, or k(N)ight? [Q]: "
      choice = gets&.strip&.upcase
      case choice
      when 'R', 'ROOK'   then return :rook
      when 'B', 'BISHOP' then return :bishop
      when 'N', 'KNIGHT' then return :knight
      when 'Q', 'QUEEN', '' then return :queen
      else
        puts "Invalid choice. Please enter Q, R, B, or N."
      end
    end
  end

  private

  def parse_input(raw, board)
    str = raw.to_s.strip.downcase

    # Commands
    if %w[save load help resign draw].include?(str)
      return { type: :command, command: str.to_sym }
    end

    # Castling
    if ['o-o', '0-0'].include?(str)
      from = white? ? [7, 4] : [0, 4]
      to = white? ? [7, 6] : [0, 6]
      return { type: :move, from: from, to: to, promotion: nil }
    elsif ['o-o-o', '0-0-0'].include?(str)
      from = white? ? [7, 4] : [0, 4]
      to = white? ? [7, 2] : [0, 2]
      return { type: :move, from: from, to: to, promotion: nil }
    end

    # Match standard coordinate moves like e2e4, e2 e4, e2-e4, e7e8q, e7e8=q
    cleaned = str.gsub(/\s+|-|to/, '')
    if cleaned =~ /\A([a-h][1-8])([a-h][1-8])(=?([qrbn]))?\z/
      from_coord = Regexp.last_match(1)
      to_coord = Regexp.last_match(2)
      promo_char = Regexp.last_match(4)

      promo = case promo_char
              when 'q' then :queen
              when 'r' then :rook
              when 'b' then :bishop
              when 'n' then :knight
              else nil
              end

      return {
        type: :move,
        from: Move.coord_to_pos(from_coord),
        to: Move.coord_to_pos(to_coord),
        promotion: promo
      }
    end

    # Single coordinate input (e.g. "e2") to inspect legal moves
    if cleaned =~ /\A[a-h][1-8]\z/
      pos = Move.coord_to_pos(cleaned)
      piece = board.piece_at(pos)
      if piece && piece.color == @color
        return { type: :piece_selected, pos: pos }
      else
        puts "No friendly piece found at #{cleaned}."
        return { type: :invalid }
      end
    end

    { type: :invalid }
  end

  def validate_and_build(board, from, to, promotion)
    piece = board.piece_at(from)
    if piece.nil?
      puts "No piece at #{Move.pos_to_coord(from)}."
      return nil
    end

    if piece.color != @color
      puts "That is not your piece to move!"
      return nil
    end

    legal_dests = board.legal_moves(from)
    unless legal_dests.include?(to)
      if board.move_leaves_king_in_check?(from, to)
        puts "Illegal move: that would leave your King in check!"
      else
        puts "Illegal move for #{piece.class.name}."
      end
      return nil
    end

    # If pawn promotion reached and promo was not in input, prompt user
    if piece.is_a?(Pawn) && to[0] == piece.promotion_row && promotion.nil?
      promotion = prompt_promotion
    end

    board.build_move(from, to, promotion)
  end

  def handle_destination_prompt(board, from_pos)
    piece = board.piece_at(from_pos)
    legal_dests = board.legal_moves(from_pos)
    from_coord = Move.pos_to_coord(from_pos)

    if legal_dests.empty?
      puts "#{piece.class.name} at #{from_coord} has no legal moves."
      return nil
    end

    dest_coords = legal_dests.map { |dest| Move.pos_to_coord(dest) }.join(', ')
    puts "Legal moves for #{piece.symbol} (#{piece.class.name}) at #{from_coord}: [ #{dest_coords} ]"

    print "Enter destination square (or press Enter to cancel): "
    dest_input = gets&.strip&.downcase
    return nil if dest_input.nil? || dest_input.empty?

    to_pos = Move.coord_to_pos(dest_input)
    unless to_pos && legal_dests.include?(to_pos)
      puts "Invalid destination square."
      return nil
    end

    promo = nil
    if piece.is_a?(Pawn) && to_pos[0] == piece.promotion_row
      promo = prompt_promotion
    end

    board.build_move(from_pos, to_pos, promo)
  end
end
