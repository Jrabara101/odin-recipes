# frozen_string_literal: true

require_relative 'lib/chess'

def clear_terminal
  print "\e[H\e[2J"
end

def welcome_banner
  puts <<~BANNER

    =============================================================================
      ♚ ♛ ♜ ♝ ♞ ♟   THE ODIN PROJECT — RUBY CHESS CLI   ♟ ♞ ♝ ♜ ♛ ♚
    =============================================================================
      A fully featured, rule-enforced command line chess game in Ruby.
      Features:
        • Full move validation & king safety
        • Castling (O-O, O-O-O), En Passant, and Pawn Promotion
        • Check, Checkmate, and Stalemate detection
        • Game save & load with JSON serialization
        • Play against AI (smart heuristics or random) or human opponent
    =============================================================================

  BANNER
end

def start_menu
  loop do
    welcome_banner
    puts "  [1] Player vs Player (2 Human Players)"
    puts "  [2] Player vs Computer (Play as White)"
    puts "  [3] Player vs Computer (Play as Black)"
    puts "  [4] Computer vs Computer (Spectator Mode)"
    puts "  [5] Load Saved Game"
    puts "  [6] View Rules & Instructions"
    puts "  [7] Exit"
    print "\nEnter your choice (1-7): "

    choice = gets&.strip

    case choice
    when '1'
      game = Game.new(
        white_player: HumanPlayer.new(:white, "Player 1 (White)"),
        black_player: HumanPlayer.new(:black, "Player 2 (Black)")
      )
      game.play
    when '2'
      game = Game.new(
        white_player: HumanPlayer.new(:white, "You (White)"),
        black_player: ComputerPlayer.new(:black, "ChessBot (Black)")
      )
      game.play
    when '3'
      game = Game.new(
        white_player: ComputerPlayer.new(:white, "ChessBot (White)"),
        black_player: HumanPlayer.new(:black, "You (Black)")
      )
      game.play
    when '4'
      game = Game.new(
        white_player: ComputerPlayer.new(:white, "AlphaBot (White)"),
        black_player: ComputerPlayer.new(:black, "BetaBot (Black)")
      )
      game.play
    when '5'
      saves = Serializer.list_saves
      if saves.empty?
        puts "\nNo saved games found. Press Enter to return..."
        gets
        next
      end

      puts "\nAvailable Saves:"
      saves.each_with_index do |path, idx|
        puts "  [#{idx + 1}] #{File.basename(path)} (#{File.mtime(path).strftime('%Y-%m-%d %H:%M')})"
      end
      print "\nSelect save number (or press Enter to cancel): "
      sel = gets&.strip
      next if sel.nil? || sel.empty?

      idx = sel.to_i - 1
      if idx.between?(0, saves.size - 1)
        data = Serializer.load_game(saves[idx])
        game = Game.new(
          board: data[:board],
          current_turn: data[:current_turn],
          white_player: data[:white_player],
          black_player: data[:black_player]
        )
        game.play
      else
        puts "Invalid choice."
      end
    when '6'
      Display.show_help
      puts "Press Enter to return to main menu..."
      gets
    when '7', 'exit', 'quit', 'q'
      puts "\nThank you for playing Ruby Chess. Farewell!"
      break
    else
      puts "\nInvalid selection. Please choose an option between 1 and 7."
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  start_menu
end
