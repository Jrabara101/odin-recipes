# Tic Tac Toe - The Odin Project
# A command-line Tic Tac Toe game built using Object-Oriented Programming (OOP) in Ruby.

# Represents the 3x3 game board and handles board state, display, and win/tie checks.
class Board
  WINNING_COMBINATIONS = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], # Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], # Columns
    [0, 4, 8], [2, 4, 6]             # Diagonals
  ].freeze

  attr_reader :cells

  def initialize
    reset
  end

  # Resets the board back to numbered spots 1 through 9
  def reset
    @cells = (1..9).to_a
  end

  # Renders the current state of the board in a clean terminal layout
  def display(output = $stdout)
    output.puts ""
    output.puts "  #{format_cell(cells[0])} | #{format_cell(cells[1])} | #{format_cell(cells[2])}"
    output.puts " ---+---+---"
    output.puts "  #{format_cell(cells[3])} | #{format_cell(cells[4])} | #{format_cell(cells[5])}"
    output.puts " ---+---+---"
    output.puts "  #{format_cell(cells[6])} | #{format_cell(cells[7])} | #{format_cell(cells[8])}"
    output.puts ""
  end

  # Validates whether a move is within bounds (1-9) and spot is unoccupied
  def valid_move?(position)
    position.is_a?(Integer) &&
      position.between?(1, 9) &&
      cells[position - 1] != "X" &&
      cells[position - 1] != "O"
  end

  # Places the player's marker on the specified cell (1-9)
  def update(position, marker)
    return false unless valid_move?(position)

    cells[position - 1] = marker
    true
  end

  # Checks if a marker has formed any 3-in-a-row winning combination
  def winning_combination?(marker)
    WINNING_COMBINATIONS.any? do |combo|
      combo.all? { |idx| cells[idx] == marker }
    end
  end

  # Returns the winning combination indices if one exists, or nil
  def winning_line(marker)
    WINNING_COMBINATIONS.find do |combo|
      combo.all? { |idx| cells[idx] == marker }
    end
  end

  # Checks if all spots are filled with 'X' or 'O'
  def full?
    cells.none? { |cell| cell.is_a?(Integer) }
  end

  # Checks if the game ended in a draw (board is full with no winner)
  def tie?
    full? && !winning_combination?("X") && !winning_combination?("O")
  end

  private

  # Cell color/formatting: unselected numbers are dimmed/neutral, markers are distinct
  def format_cell(cell)
    cell.to_s
  end
end

# Represents a human player with a name and game marker ('X' or 'O').
class Player
  attr_reader :name, :marker

  def initialize(name, marker)
    @name = name
    @marker = marker
  end

  def to_s
    "#{name} (#{marker})"
  end
end

# Coordinates the game loop, user interactions, player turns, and replay logic.
class Game
  attr_reader :board, :player1, :player2, :current_player, :input, :output

  def initialize(board: Board.new, player1: nil, player2: nil, input: $stdin, output: $stdout)
    @board = board
    @player1 = player1
    @player2 = player2
    @current_player = @player1
    @input = input
    @output = output
  end

  # Starts the Tic Tac Toe interactive session
  def play
    welcome_banner
    setup_players unless @player1 && @player2
    @current_player = @player1

    loop do
      play_round
      announce_result
      break unless play_again?

      reset_round
    end

    goodbye_message
  end

  # Manages the flow of a single round until win or tie
  def play_round
    output.puts "\nStarting round! #{@player1.name} (X) vs #{@player2.name} (O)"
    board.display(output)

    until round_over?
      take_turn(current_player)
      board.display(output)
      break if round_over?

      switch_player
    end
  end

  # Prompts the current player for a move, validates input, and applies it to the board
  def take_turn(player)
    output.print "#{player.name} (#{player.marker}), choose an available spot (1-9): "

    loop do
      raw_input = input.gets
      if raw_input.nil? # Handle EOF gracefully
        output.puts "\nInput ended. Exiting turn."
        return
      end

      choice = raw_input.strip

      if choice =~ /\A[1-9]\z/
        pos = choice.to_i
        if board.valid_move?(pos)
          board.update(pos, player.marker)
          break
        else
          output.print "Spot #{pos} is already taken! Please choose an available spot: "
        end
      else
        output.print "Invalid input! Please enter a number between 1 and 9: "
      end
    end
  end

  # Alternates turn between player 1 and player 2
  def switch_player
    @current_player = (@current_player == @player1 ? @player2 : @player1)
  end

  # Returns true if someone won or the board is full
  def round_over?
    winner? || draw?
  end

  # Checks if the current player has won
  def winner?
    board.winning_combination?(current_player.marker)
  end

  # Checks if the round ended in a draw
  def draw?
    board.tie?
  end

  private

  def welcome_banner
    output.puts "=" * 45
    output.puts "        WELCOME TO TIC TAC TOE!"
    output.puts "  Two players take turns placing X and O."
    output.puts "  Get 3 in a row, column, or diagonal to win!"
    output.puts "=" * 45
  end

  def setup_players
    output.print "\nEnter name for Player 1 (X) [Default: Player 1]: "
    p1_name = input.gets&.strip
    p1_name = "Player 1" if p1_name.nil? || p1_name.empty?
    @player1 = Player.new(p1_name, "X")

    output.print "Enter name for Player 2 (O) [Default: Player 2]: "
    p2_name = input.gets&.strip
    p2_name = "Player 2" if p2_name.nil? || p2_name.empty?
    @player2 = Player.new(p2_name, "O")

    @current_player = @player1
  end

  def announce_result
    if winner?
      output.puts "🎉 Congratulations #{current_player.name}! You won the game!"
    elsif draw?
      output.puts "🤝 It's a draw! Well played by both players!"
    end
  end

  def play_again?
    output.print "\nWould you like to play another round? (y/n): "
    loop do
      raw_answer = input.gets
      return false if raw_answer.nil?

      answer = raw_answer.strip.downcase
      if %w[y yes].include?(answer)
        return true
      elsif %w[n no].include?(answer)
        return false
      else
        output.print "Please enter 'y' for yes or 'n' for no: "
      end
    end
  end

  def reset_round
    board.reset
    # Alternate who goes first in subsequent rounds
    @current_player = @player1
  end

  def goodbye_message
    output.puts "\nThanks for playing Tic Tac Toe! See you next time! 👋\n"
  end
end

# Run the interactive game when executed directly from the command line
if __FILE__ == $PROGRAM_NAME
  Game.new.play
end
