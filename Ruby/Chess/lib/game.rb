# frozen_string_literal: true

require_relative 'board'
require_relative 'display'
require_relative 'human_player'
require_relative 'computer_player'
require_relative 'serializer'

# Orchestrates the chess game flow, player turns, move execution, and game end states.
class Game
  attr_accessor :board, :current_turn, :white_player, :black_player, :last_move

  def initialize(board: nil, white_player: nil, black_player: nil, current_turn: :white)
    @board = board || Board.new
    @white_player = white_player || HumanPlayer.new(:white, "Player 1 (White)")
    @black_player = black_player || HumanPlayer.new(:black, "Player 2 (Black)")
    @current_turn = current_turn
    @last_move = nil
  end

  def current_player
    @current_turn == :white ? @white_player : @black_player
  end

  def other_player
    @current_turn == :white ? @black_player : @white_player
  end

  def play
    loop do
      Display.render(@board, @current_turn, last_move: @last_move)

      # 1. Check game over conditions
      if @board.checkmate?(@current_turn)
        winner = other_player
        puts "\n" + ("*" * 60)
        puts "  🏆 CHECKMATE! #{winner.name} (#{winner.color.to_s.capitalize}) WINS! 🏆"
        puts "*" * 60 + "\n"
        return winner
      elsif @board.stalemate?(@current_turn)
        puts "\n" + ("=" * 60)
        puts "  🤝 STALEMATE! The game ends in a draw. 🤝"
        puts "=" * 60 + "\n"
        return :draw
      elsif @board.insufficient_material?
        puts "\n" + ("=" * 60)
        puts "  🤝 DRAW by Insufficient Material! 🤝"
        puts "=" * 60 + "\n"
        return :draw
      elsif @board.fifty_move_rule?
        puts "\n" + ("=" * 60)
        puts "  🤝 DRAW by 50-Move Rule! 🤝"
        puts "=" * 60 + "\n"
        return :draw
      end

      # 2. Get move or command from active player
      player = current_player
      if player.human?
        action = player.get_move(@board, self)
        case action
        when :quit
          puts "\nGame ended. Thanks for playing!"
          return nil
        when :save
          handle_save
          next
        when :load
          handle_load
          next
        when :help
          Display.show_help
          puts "Press Enter to return to the board..."
          gets
          next
        when :resign
          winner = other_player
          puts "\n🏳️  #{player.name} has resigned. #{winner.name} wins!"
          return winner
        when :draw
          if prompt_draw_offer(other_player)
            puts "\n🤝 Draw offer accepted! The game is drawn."
            return :draw
          else
            puts "\n❌ Draw offer declined."
            next
          end
        when Move
          execute_player_move(action)
        end
      else
        # Computer AI turn
        puts "\n#{player.name} is thinking..."
        sleep 0.4 unless ENV['RSPEC_RUN']
        ai_move = player.get_move(@board, self)
        if ai_move
          execute_player_move(ai_move)
          puts "🤖 #{player.name} played: #{ai_move}"
        else
          puts "No legal moves available for AI."
        end
      end
    end
  end

  def execute_player_move(move)
    @board.make_move(move)
    @last_move = move
    @current_turn = (@current_turn == :white ? :black : :white)
  end

  def handle_save
    print "Enter filename for save (or press Enter for automatic timestamp): "
    name = gets&.strip
    name = nil if name.empty?

    saved_path = Serializer.save_game(@board, @current_turn, @white_player, @black_player, filename: name)
    puts "✅ Game successfully saved to #{File.basename(saved_path)}!"
    puts "Press Enter to continue playing..."
    gets
  end

  def handle_load
    saves = Serializer.list_saves
    if saves.empty?
      puts "No saved games found."
      return
    end

    puts "\nAvailable Saved Games:"
    saves.each_with_index do |path, idx|
      time_str = File.mtime(path).strftime("%Y-%m-%d %H:%M:%S")
      puts "  [#{idx + 1}] #{File.basename(path)} (#{time_str})"
    end

    print "\nSelect a save number (1-#{saves.size}) or press Enter to cancel: "
    choice = gets&.strip
    return if choice.nil? || choice.empty?

    idx = choice.to_i - 1
    if idx.between?(0, saves.size - 1)
      loaded_data = Serializer.load_game(saves[idx])
      @board = loaded_data[:board]
      @current_turn = loaded_data[:current_turn]
      @white_player = loaded_data[:white_player]
      @black_player = loaded_data[:black_player]
      @last_move = nil
      puts "✅ Game successfully loaded!"
    else
      puts "Invalid choice."
    end
  end

  def prompt_draw_offer(recipient)
    if recipient.human?
      print "\n#{recipient.name}, your opponent has offered a draw. Accept? (y/n): "
      ans = gets&.strip&.downcase
      ans == 'y' || ans == 'yes'
    else
      # AI evaluates if draw is acceptable (e.g. if position is roughly equal or losing)
      white_val = @board.all_pieces(:white).sum(&:value)
      black_val = @board.all_pieces(:black).sum(&:value)
      diff = recipient.white? ? (white_val - black_val) : (black_val - white_val)
      diff <= 0 # Accept draw if equal or behind in material
    end
  end
end
