# Mastermind - The Odin Project
# A command-line Mastermind game built using Object-Oriented Programming (OOP) in Ruby.
# Allows the player to play either as the Codebreaker or the Codemaker.

# Represents a 4-peg color code and handles parsing, comparison, and feedback calculation.
class Code
  COLORS = %w[Red Green Blue Yellow Purple Orange].freeze
  
  # Aliases for convenient input: numbers 1-6, single letters, and full color names
  COLOR_MAP = {
    "1" => "Red",    "r" => "Red",    "red" => "Red",
    "2" => "Green",  "g" => "Green",  "green" => "Green",
    "3" => "Blue",   "b" => "Blue",   "blue" => "Blue",
    "4" => "Yellow", "y" => "Yellow", "yellow" => "Yellow",
    "5" => "Purple", "p" => "Purple", "purple" => "Purple",
    "6" => "Orange", "o" => "Orange", "orange" => "Orange"
  }.freeze

  attr_reader :pegs

  def initialize(pegs)
    @pegs = pegs.map(&:to_s).freeze
  end

  # Generates a random 4-peg code from the 6 colors
  def self.random
    new(Array.new(4) { COLORS.sample })
  end

  # Returns all 1,296 possible 4-color combinations
  def self.all_combinations
    COLORS.repeated_permutation(4).map { |combo| new(combo) }
  end

  # Parses user input (e.g. "1 2 3 4", "1234", "r g b y", "Red Green Blue Yellow")
  # Returns a Code instance if valid, or nil if invalid
  def self.parse(input)
    return nil if input.nil?

    trimmed = input.strip.downcase
    tokens = if trimmed.include?(" ")
               trimmed.split(/\s+/)
             elsif trimmed.length == 4 && trimmed =~ /\A[1-6]{4}\z/
               trimmed.chars
             elsif trimmed.length == 4 && trimmed =~ /\A[rgbyop]{4}\z/
               trimmed.chars
             else
               trimmed.split(/\s+/)
             end

    return nil unless tokens.length == 4

    resolved_pegs = tokens.map { |token| COLOR_MAP[token] }
    return nil if resolved_pegs.any?(&:nil?)

    new(resolved_pegs)
  end

  # Compares a secret code against a guess and returns feedback:
  # - exact: correct color in correct position (Red/Black key peg)
  # - color: correct color in wrong position (White key peg)
  def self.compare(secret, guess)
    s_pegs = secret.is_a?(Code) ? secret.pegs : secret
    g_pegs = guess.is_a?(Code) ? guess.pegs : guess

    exact = 0
    unmatched_secret = []
    unmatched_guess = []

    s_pegs.each_with_index do |color, i|
      if color == g_pegs[i]
        exact += 1
      else
        unmatched_secret << color
        unmatched_guess << g_pegs[i]
      end
    end

    color_matches = 0
    unmatched_guess.each do |color|
      if (idx = unmatched_secret.index(color))
        color_matches += 1
        unmatched_secret.delete_at(idx)
      end
    end

    { exact: exact, color: color_matches }
  end

  def ==(other)
    other.is_a?(Code) && pegs == other.pegs
  end

  alias eql? ==

  def hash
    pegs.hash
  end

  def to_s
    pegs.map { |color| "[#{color}]" }.join(" ")
  end
end

# Represents the game board tracking past guesses and feedback
class Board
  MAX_TURNS = 12

  TurnRecord = Struct.new(:turn_number, :guess, :feedback)

  attr_reader :records

  def initialize
    @records = []
  end

  def add_turn(guess, feedback)
    @records << TurnRecord.new(@records.size + 1, guess, feedback)
  end

  def turns_used
    @records.size
  end

  def turns_remaining
    MAX_TURNS - turns_used
  end

  def full?
    turns_used >= MAX_TURNS
  end

  def display(output = $stdout)
    output.puts "\n" + ("=" * 64)
    output.puts " Turn | Guess                           | Feedback"
    output.puts "------+---------------------------------+------------------------"

    if @records.empty?
      output.puts "      | (No guesses made yet)           | "
    else
      @records.each do |rec|
        turn_str = rec.turn_number.to_s.rjust(2, "0")
        guess_str = rec.guess.to_s.ljust(31)
        feedback_str = format_feedback(rec.feedback)
        output.puts "  #{turn_str}  | #{guess_str} | #{feedback_str}"
      end
    end

    output.puts ("=" * 64) + "\n"
  end

  private

  # Formats feedback pegs: ● for Exact, ○ for Color match
  def format_feedback(feedback)
    exact = feedback[:exact]
    color = feedback[:color]
    empty = 4 - exact - color

    pegs = ("● " * exact) + ("○ " * color) + ("- " * empty)
    "#{pegs.strip}  (#{exact} Exact, #{color} Near)"
  end
end

# An AI solver implementing a Consistent-Candidate Elimination strategy.
# Prunes impossible secret codes after each feedback round to solve in 4-6 turns.
class ComputerSolver
  attr_reader :candidates, :last_guess

  def initialize
    @candidates = Code.all_combinations
    @last_guess = nil
  end

  # Returns the initial opening guess or the next pruned candidate
  def choose_guess(last_feedback = nil)
    if @last_guess.nil?
      # Knuth's classic optimal opening: two of one color, two of another
      @last_guess = Code.new(%w[Red Red Green Green])
      return @last_guess
    end

    # Eliminate candidates that would not yield the same feedback against the last guess
    @candidates.select! do |candidate|
      Code.compare(candidate, @last_guess) == last_feedback
    end

    # Select the first candidate remaining in the consistent set
    @last_guess = @candidates.first
    @last_guess
  end

  def remaining_candidates_count
    @candidates.size
  end
end

# Coordinates the overall game session, player interactions, and game modes.
class Game
  attr_reader :board, :input, :output, :delay_enabled

  def initialize(input: $stdin, output: $stdout, delay_enabled: true)
    @input = input
    @output = output
    @board = Board.new
    @delay_enabled = delay_enabled
  end

  # Main application entry point
  def play
    welcome_banner

    loop do
      mode = choose_game_mode
      case mode
      when :codebreaker
        play_as_codebreaker
      when :codemaker
        play_as_codemaker
      when :rules
        display_rules
        next
      when :quit
        break
      end

      break unless play_again?

      @board = Board.new
    end

    goodbye_message
  end

  # Mode 1: Human is Codebreaker, Computer is Codemaker
  def play_as_codebreaker
    secret_code = Code.random
    output.puts "\n🕹️  The computer has selected a 4-color secret code."
    output.puts "You have 12 turns to break it. Good luck!\n"

    until board.full?
      turn_num = board.turns_used + 1
      guess = prompt_human_guess(turn_num)
      return if guess.nil? # EOF

      feedback = Code.compare(secret_code, guess)
      board.add_turn(guess, feedback)
      board.display(output)

      if feedback[:exact] == 4
        output.puts "🎉 CONGRATULATIONS! You cracked the secret code in #{turn_num} turns!"
        return
      end

      output.puts "Turns remaining: #{board.turns_remaining}"
    end

    output.puts "💀 GAME OVER! You ran out of turns."
    output.puts "The secret code was: #{secret_code}\n"
  end

  # Mode 2: Human is Codemaker, Computer is Codebreaker
  def play_as_codemaker
    secret_code = prompt_secret_code
    return if secret_code.nil? # EOF

    output.puts "\nSecret code registered: #{secret_code}"
    output.puts "The computer will now attempt to guess your code within 12 turns!\n"

    solver = ComputerSolver.new
    last_feedback = nil

    until board.full?
      turn_num = board.turns_used + 1
      guess = solver.choose_guess(last_feedback)

      sleep(0.6) if @delay_enabled

      output.puts "\n🤖 Turn #{turn_num}: Computer guesses #{guess}"
      feedback = Code.compare(secret_code, guess)
      board.add_turn(guess, feedback)
      board.display(output)

      if feedback[:exact] == 4
        output.puts "🤖 The computer cracked your secret code in #{turn_num} turns!"
        return
      end

      output.puts "Remaining possibilities: #{solver.remaining_candidates_count}"
      last_feedback = feedback
    end

    output.puts "🏆 INCREDIBLE! You stumped the computer! It failed to crack your code within 12 turns."
  end

  private

  def welcome_banner
    output.puts "=" * 64
    output.puts "                     MASTERMIND"
    output.puts "           The Classic Code-Breaking Game"
    output.puts "=" * 64
    output.puts "Available Colors:"
    output.puts "  1: Red (R)     2: Green (G)    3: Blue (B)"
    output.puts "  4: Yellow (Y)  5: Purple (P)   6: Orange (O)"
    output.puts "Feedback Pegs:"
    output.puts "  ● Exact match: Correct color in correct spot"
    output.puts "  ○ Near match:  Correct color in wrong spot"
    output.puts "=" * 64
  end

  def display_rules
    output.puts "\n--- MASTERMIND RULES ---"
    output.puts "1. A secret code consists of 4 pegs chosen from 6 colors."
    output.puts "2. Colors may be repeated (e.g. Red Red Blue Yellow)."
    output.puts "3. The Codebreaker has 12 turns to guess the code."
    output.puts "4. After each guess, feedback is provided:"
    output.puts "   - ● (Exact): A peg has the correct color and is in the correct position."
    output.puts "   - ○ (Near):  A peg has the correct color, but is in the wrong position."
    output.puts "5. Entering guesses: You can type numbers (e.g. 1 2 3 4 or 1234),"
    output.puts "   letters (e.g. r g b y or rgby), or full names.\n"
  end

  def choose_game_mode
    output.puts "\nSelect Game Mode:"
    output.puts "  1. Play as Codebreaker (Guess the computer's code)"
    output.puts "  2. Play as Codemaker   (Create a code for the computer to guess)"
    output.puts "  3. View Game Rules"
    output.puts "  4. Quit"
    output.print "Enter your choice (1-4): "

    loop do
      raw_choice = input.gets
      return :quit if raw_choice.nil?

      case raw_choice.strip
      when "1" then return :codebreaker
      when "2" then return :codemaker
      when "3" then return :rules
      when "4" then return :quit
      else
        output.print "Invalid choice. Please enter 1, 2, 3, or 4: "
      end
    end
  end

  def prompt_human_guess(turn_num)
    output.print "Turn #{turn_num}/12 - Enter 4 colors (e.g., '1 2 3 4' or 'R G B Y'): "

    loop do
      raw = input.gets
      return nil if raw.nil?

      code = Code.parse(raw)
      return code if code

      output.print "Invalid code! Enter 4 colors using 1-6 or R, G, B, Y, P, O: "
    end
  end

  def prompt_secret_code
    output.print "\nEnter your 4-color secret code (e.g., '1 2 3 4' or 'R G B Y'): "

    loop do
      raw = input.gets
      return nil if raw.nil?

      code = Code.parse(raw)
      return code if code

      output.print "Invalid code! Enter 4 valid colors (1-6 or R, G, B, Y, P, O): "
    end
  end

  def play_again?
    output.print "\nWould you like to play another game? (y/n): "
    loop do
      raw = input.gets
      return false if raw.nil?

      case raw.strip.downcase
      when "y", "yes" then return true
      when "n", "no"  then return false
      else
        output.print "Please enter 'y' for yes or 'n' for no: "
      end
    end
  end

  def goodbye_message
    output.puts "\nThanks for playing Mastermind! Goodbye! 👋\n"
  end
end

# Run the game when executed directly from the terminal
if __FILE__ == $PROGRAM_NAME
  Game.new.play
end
