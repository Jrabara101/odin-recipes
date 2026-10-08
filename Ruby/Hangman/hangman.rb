# frozen_string_literal: true

# Hangman - The Odin Project
# A command-line Hangman game built using Object-Oriented Programming (OOP) in Ruby.
# Features:
# - Dictionary loading and word filtering (5-12 letters)
# - Interactive ASCII art gallows display
# - Case-insensitive guessing and input validation
# - Save & Load game functionality via JSON serialization
# - Comprehensive save manager and game menu

require "json"
require "fileutils"
require "time"

module Hangman
  # Color styling module for terminal output
  module Color
    RESET   = "\e[0m"
    BOLD    = "\e[1m"
    DIM     = "\e[2m"
    RED     = "\e[31m"
    GREEN   = "\e[32m"
    YELLOW  = "\e[33m"
    BLUE    = "\e[34m"
    MAGENTA = "\e[35m"
    CYAN    = "\e[36m"
    WHITE   = "\e[37m"

    def self.colorize(text, color_code)
      # Check if color is supported or disabled
      return text unless $stdout.tty? || ENV["FORCE_COLOR"] == "true"

      "#{color_code}#{text}#{RESET}"
    end

    def self.red(text); colorize(text, RED); end
    def self.green(text); colorize(text, GREEN); end
    def self.yellow(text); colorize(text, YELLOW); end
    def self.blue(text); colorize(text, BLUE); end
    def self.magenta(text); colorize(text, MAGENTA); end
    def self.cyan(text); colorize(text, CYAN); end
    def self.white(text); colorize(text, WHITE); end
    def self.bold(text); colorize(text, BOLD); end
    def self.dim(text); colorize(text, DIM); end
  end

  # Loads and filters words from the dictionary
  class Dictionary
    DEFAULT_PATH = File.expand_path("google-10000-english-no-swears.txt", __dir__)
    MIN_LENGTH = 5
    MAX_LENGTH = 12

    # Fallback words if dictionary file is not present
    FALLBACK_WORDS = %w[
      programming developer keyboard computer terminal
      algorithm variable database function internet
      software hardware sequence execution
    ].freeze

    attr_reader :file_path, :words

    def initialize(file_path = DEFAULT_PATH)
      @file_path = file_path
      @words = load_words
    end

    # Loads and filters words between MIN_LENGTH and MAX_LENGTH
    def load_words
      if File.exist?(@file_path)
        valid_words = File.readlines(@file_path, chomp: true).map(&:strip).map(&:downcase).select do |w|
          w.length.between?(MIN_LENGTH, MAX_LENGTH) && w.match?(/\A[a-z]+\z/)
        end
        return valid_words unless valid_words.empty?
      end

      FALLBACK_WORDS.select { |w| w.length.between?(MIN_LENGTH, MAX_LENGTH) }
    end

    # Selects a random secret word from the filtered dictionary
    def random_word
      @words.sample
    end
  end

  # Represents the core Hangman game state and business logic
  class Game
    DEFAULT_MAX_MISTAKES = 7

    attr_reader :secret_word, :guessed_letters, :max_mistakes

    def initialize(secret_word:, guessed_letters: [], max_mistakes: DEFAULT_MAX_MISTAKES)
      @secret_word = secret_word.to_s.strip.downcase
      @guessed_letters = guessed_letters.map { |l| l.to_s.downcase }.uniq
      @max_mistakes = max_mistakes
    end

    # Makes a letter guess
    # Returns a hash: { status: Symbol, letter: String, message: String }
    def guess(input)
      letter = input.to_s.strip.downcase

      unless letter.match?(/\A[a-z]\z/)
        return {
          status: :invalid,
          letter: letter,
          message: "Invalid input. Please enter a single letter (a-z)."
        }
      end

      if @guessed_letters.include?(letter)
        return {
          status: :duplicate,
          letter: letter,
          message: "You've already guessed '#{letter.upcase}'. Try another letter!"
        }
      end

      @guessed_letters << letter

      if @secret_word.include?(letter)
        count = @secret_word.count(letter)
        times = count == 1 ? "once" : "#{count} times"
        {
          status: :correct,
          letter: letter,
          message: "Great guess! '#{letter.upcase}' appears #{times} in the word."
        }
      else
        {
          status: :incorrect,
          letter: letter,
          message: "Sorry, '#{letter.upcase}' is not in the secret word."
        }
      end
    end

    # Correct letter guesses made so far
    def correct_guesses
      @guessed_letters.select { |l| @secret_word.include?(l) }
    end

    # Incorrect letter guesses made so far
    def incorrect_guesses
      @guessed_letters.reject { |l| @secret_word.include?(l) }
    end

    # Number of remaining mistake lives
    def remaining_mistakes
      [@max_mistakes - incorrect_guesses.length, 0].max
    end

    # Number of mistakes made so far
    def mistakes_made
      [@max_mistakes - remaining_mistakes, @max_mistakes].min
    end

    # Player has guessed every unique letter in the secret word
    def won?
      @secret_word.chars.all? { |ch| @guessed_letters.include?(ch) }
    end

    # Player has exhausted all mistakes without guessing the word
    def lost?
      remaining_mistakes.zero? && !won?
    end

    # Whether the game has reached an end state
    def game_over?
      won? || lost?
    end

    # Returns the word masked with underscores for unguessed characters
    # e.g. "_ r o g r a _ _ i n g"
    def word_display
      @secret_word.chars.map do |char|
        @guessed_letters.include?(char) ? char : "_"
      end.join(" ")
    end

    # Compact representation without spaces (e.g. "_rogra__ing")
    def compact_display
      @secret_word.chars.map do |char|
        @guessed_letters.include?(char) ? char : "_"
      end.join
    end

    # Serializes the game to a hash
    def to_h
      {
        "secret_word" => @secret_word,
        "guessed_letters" => @guessed_letters,
        "max_mistakes" => @max_mistakes
      }
    end

    # Constructs a Game instance from a hash
    def self.from_h(data)
      raise ArgumentError, "Missing secret word in save data" unless data["secret_word"]

      new(
        secret_word: data["secret_word"],
        guessed_letters: data["guessed_letters"] || [],
        max_mistakes: data["max_mistakes"] || DEFAULT_MAX_MISTAKES
      )
    end
  end

  # Handles saving, listing, loading, and deleting save files using JSON
  class SaveManager
    DEFAULT_SAVES_DIR = File.expand_path("saves", __dir__)

    attr_reader :saves_dir

    def initialize(saves_dir = DEFAULT_SAVES_DIR)
      @saves_dir = saves_dir
      FileUtils.mkdir_p(@saves_dir)
    end

    # Saves a game instance with an optional custom name
    def save_game(game, slot_name = nil)
      clean_name = sanitize_filename(slot_name)
      clean_name = "save_#{Time.now.strftime('%Y%m%d_%H%M%S')}" if clean_name.empty?

      file_name = clean_name.end_with?(".json") ? clean_name : "#{clean_name}.json"
      file_path = File.join(@saves_dir, file_name)

      save_data = {
        "version" => 1,
        "saved_at" => Time.now.iso8601,
        "game" => game.to_h
      }

      File.write(file_path, JSON.pretty_generate(save_data))
      file_path
    end

    # Returns a list of available saves with metadata
    def list_saves
      return [] unless Dir.exist?(@saves_dir)

      files = Dir.glob(File.join(@saves_dir, "*.json")).sort_by { |f| File.mtime(f) }.reverse
      files.map do |path|
        content = JSON.parse(File.read(path))
        game_data = content["game"] || {}
        game = Game.from_h(game_data)

        {
          filename: File.basename(path),
          path: path,
          saved_at: content["saved_at"] ? Time.parse(content["saved_at"]) : File.mtime(path),
          word_display: game.word_display,
          word_length: game.secret_word.length,
          remaining_mistakes: game.remaining_mistakes,
          max_mistakes: game.max_mistakes,
          guesses_count: game.guessed_letters.length
        }
      rescue StandardError
        # In case of corrupted files, still show filename with error
        {
          filename: File.basename(path),
          path: path,
          saved_at: File.mtime(path),
          corrupted: true
        }
      end
    end

    # Loads a game instance from a filename or path
    def load_game(filename_or_path)
      path = if File.exist?(filename_or_path)
               filename_or_path
             else
               File.join(@saves_dir, filename_or_path.end_with?(".json") ? filename_or_path : "#{filename_or_path}.json")
             end

      raise ArgumentError, "Save file not found: #{File.basename(path)}" unless File.exist?(path)

      data = JSON.parse(File.read(path))
      game_data = data["game"] || data
      Game.from_h(game_data)
    end

    # Deletes a save file
    def delete_save(filename)
      target = File.join(@saves_dir, filename.end_with?(".json") ? filename : "#{filename}.json")
      if File.exist?(target)
        File.delete(target)
        true
      else
        false
      end
    end

    private

    def sanitize_filename(name)
      return "" if name.nil?

      name.to_s.strip.gsub(/[^a-zA-Z0-9_\-]/, "_").gsub(/_{2,}/, "_").sub(/\A_+/, "").sub(/_+\z/, "")
    end
  end

  # Handles UI rendering, ASCII gallows, and game screens
  class Display
    # ASCII art stages corresponding to mistakes made (0..7)
    GALLOWS = [
      # 0 mistakes
      <<~ART,
         +---+
         |   |
             |
             |
             |
             |
       =========
      ART
      # 1 mistake: Head
      <<~ART,
         +---+
         |   |
         O   |
             |
             |
             |
       =========
      ART
      # 2 mistakes: Torso
      <<~ART,
         +---+
         |   |
         O   |
         |   |
             |
             |
       =========
      ART
      # 3 mistakes: Left Arm
      <<~ART,
         +---+
         |   |
         O   |
        /|   |
             |
             |
       =========
      ART
      # 4 mistakes: Right Arm
      <<~ART,
         +---+
         |   |
         O   |
        /|\\  |
             |
             |
       =========
      ART
      # 5 mistakes: Left Leg
      <<~ART,
         +---+
         |   |
         O   |
        /|\\  |
        /    |
             |
       =========
      ART
      # 6 mistakes: Right Leg (1 life left!)
      <<~ART,
         +---+
         |   |
         O   |
        /|\\  |
        / \\  |
             |
       =========
      ART
      # 7 mistakes: Hanged (Game Over)
      <<~ART,
         +---+
         |   |
         X   |
        /|\\  |
        / \\  |
             |
       =========
      ART
    ].freeze

    def self.clear_screen
      print "\e[2J\e[H" if $stdout.tty?
    end

    def self.banner
      <<~BANNER
        #{Color.cyan('================================================================')}
        #{Color.bold(Color.cyan('             H A N G M A N  -  T H E   G A M E                  '))}
        #{Color.cyan('================================================================')}
      BANNER
    end

    # Renders the current game board
    def self.render_board(game, feedback_message = nil)
      mistakes = [game.mistakes_made, GALLOWS.length - 1].min
      gallows_art = GALLOWS[mistakes]

      output = []
      output << banner
      output << ""

      # Split gallows lines and pair with game details
      gallows_lines = gallows_art.lines.map(&:chomp)

      info_lines = [
        "  Word Length:      #{Color.bold("#{game.secret_word.length} letters")}",
        "  Remaining Lives:  #{lives_display(game.remaining_mistakes, game.max_mistakes)}",
        "  Incorrect Guesses: #{incorrect_display(game.incorrect_guesses)}",
        "",
        "  Letter Bank:      #{alphabet_bank(game.guessed_letters)}",
        "",
        ""
      ]

      max_lines = [gallows_lines.length, info_lines.length].max
      max_lines.times do |i|
        g_line = (gallows_lines[i] || "").ljust(16)
        i_line = info_lines[i] || ""
        output << "  #{Color.yellow(g_line)} #{i_line}"
      end

      output << ""
      output << "  " + Color.cyan("------------------------------------------------------------")
      output << "  Secret Word:  #{Color.bold(Color.white(game.word_display))}"
      output << "  " + Color.cyan("------------------------------------------------------------")
      output << ""

      if feedback_message
        output << "  >> #{feedback_message}"
        output << ""
      end

      puts output.join("\n")
    end

    def self.lives_display(remaining, max)
      hearts = "● " * remaining + "○ " * (max - remaining)
      color = if remaining > 3
                Color.green("#{remaining} / #{max}  [#{hearts.strip}]")
              elsif remaining > 1
                Color.yellow("#{remaining} / #{max}  [#{hearts.strip}]")
              else
                Color.red("#{remaining} / #{max}  [#{hearts.strip}] (DANGER!)")
              end
      color
    end

    def self.incorrect_display(incorrect_guesses)
      if incorrect_guesses.empty?
        Color.dim("(none yet)")
      else
        Color.red(incorrect_guesses.map(&:upcase).sort.join(", "))
      end
    end

    def self.alphabet_bank(guessed_letters)
      ("A".."Z").map do |char|
        if guessed_letters.include?(char.downcase)
          Color.dim("#{char}")
        else
          Color.bold(Color.cyan("#{char}"))
        end
      end.join(" ")
    end

    def self.victory_screen(game)
      puts ""
      puts Color.green("  ============================================================")
      puts Color.bold(Color.green("   🎉 CONGRATULATIONS! YOU SAVED THE HANGMAN! 🎉"))
      puts Color.green("  ============================================================")
      puts "  The secret word was indeed: #{Color.bold(Color.green(game.secret_word.upcase))}"
      puts "  Total guesses: #{game.guessed_letters.length} | Mistakes made: #{game.mistakes_made}"
      puts ""
    end

    def self.game_over_screen(game)
      puts ""
      puts Color.red("  ============================================================")
      puts Color.bold(Color.red("   💀 GAME OVER! THE HANGMAN HAS FALLEN! 💀"))
      puts Color.red("  ============================================================")
      puts "  The secret word was: #{Color.bold(Color.yellow(game.secret_word.upcase))}"
      puts "  Better luck next time!"
      puts ""
    end

    def self.instructions
      puts <<~TEXT
        #{banner}
        #{Color.bold('HOW TO PLAY HANGMAN:')}
        1. The computer selects a secret English word (5 to 12 letters long).
        2. Guess one letter at a time to reveal where it appears in the word.
        3. For every incorrect guess, a part of the hangman stick figure is drawn!
        4. You have #{Game::DEFAULT_MAX_MISTAKES} incorrect guesses before the hangman is hanged.
        5. If you uncover all the letters in the secret word, you WIN!
        
        #{Color.bold('COMMANDS DURING YOUR TURN:')}
        - Enter any single letter (A-Z) to guess.
        - Type #{Color.yellow('save')} (or #{Color.yellow('s')}) to save your game and resume later.
        - Type #{Color.yellow('menu')} (or #{Color.yellow('quit')}) to return to the main menu.

        Press Enter to return to the main menu...
      TEXT
    end
  end

  # Main application controller
  class HangmanApp
    def initialize(dictionary = nil, save_manager = nil)
      @dictionary = dictionary || Dictionary.new
      @save_manager = save_manager || SaveManager.new
    end

    def run
      loop do
        Display.clear_screen
        puts Display.banner
        puts "  1. Start a New Game"
        puts "  2. Load a Saved Game"
        puts "  3. How to Play (Instructions)"
        puts "  4. Exit"
        puts ""
        print "  Choose an option (1-4): "

        choice = gets&.strip

        case choice
        when "1"
          start_new_game
        when "2"
          load_game_menu
        when "3"
          show_instructions
        when "4", "exit", "quit", "q"
          puts "\n  Thanks for playing Hangman! Goodbye!\n\n"
          break
        else
          puts "\n  Invalid selection. Please choose 1, 2, 3, or 4."
          sleep_pause(1)
        end
      end
    end

    def start_new_game
      word = @dictionary.random_word
      if word.nil?
        puts "\n  #{Color.red('Error:')} Could not load words from dictionary."
        puts "  Press Enter to return to the main menu..."
        gets
        return
      end

      game = Game.new(secret_word: word)
      play_loop(game)
    end

    def play_loop(game)
      feedback = nil

      loop do
        Display.clear_screen
        Display.render_board(game, feedback)
        feedback = nil

        if game.won?
          Display.victory_screen(game)
          if prompt_play_again
            game = Game.new(secret_word: @dictionary.random_word)
            next
          else
            break
          end
        elsif game.lost?
          Display.game_over_screen(game)
          if prompt_play_again
            game = Game.new(secret_word: @dictionary.random_word)
            next
          else
            break
          end
        end

        print "  Enter your guess [a-z] (or 'save' / 'menu'): "
        input = gets&.strip

        return if input.nil? # EOF / Ctrl+D

        case input.downcase
        when "save", "s"
          action = save_current_game(game)
          break if action == :exit_to_menu
        when "menu", "quit", "exit", "q"
          print "  Do you want to save before leaving? (y/n): "
          if gets&.strip&.downcase&.start_with?("y")
            save_current_game(game)
          end
          break
        else
          result = game.guess(input)
          case result[:status]
          when :correct
            feedback = Color.green("✓ #{result[:message]}")
          when :incorrect
            feedback = Color.red("✗ #{result[:message]}")
          when :duplicate
            feedback = Color.yellow("! #{result[:message]}")
          when :invalid
            feedback = Color.magenta("! #{result[:message]}")
          end
        end
      end
    end

    def save_current_game(game)
      puts ""
      print "  Enter a name for this save (press Enter for timestamped name): "
      name = gets&.strip
      name = nil if name && name.empty?

      begin
        path = @save_manager.save_game(game, name)
        filename = File.basename(path)
        puts "  #{Color.green("✓ Game successfully saved as '#{filename}'!")}"
      rescue StandardError => e
        puts "  #{Color.red("✗ Failed to save game: #{e.message}")}"
      end

      print "  Continue playing this game? (y/n): "
      continue_choice = gets&.strip&.downcase
      if continue_choice.nil? || !continue_choice.start_with?("y")
        :exit_to_menu
      else
        :continue
      end
    end

    def load_game_menu
      loop do
        Display.clear_screen
        puts Display.banner
        puts "  " + Color.bold("LOAD A SAVED GAME")
        puts "  " + Color.cyan("------------------------------------------------------------")
        saves = @save_manager.list_saves

        if saves.empty?
          puts "  No saved games found."
          puts ""
          puts "  Press Enter to return to main menu..."
          gets
          break
        end

        saves.each_with_index do |s, idx|
          if s[:corrupted]
            puts "  #{idx + 1}. #{Color.red(s[:filename])} (Corrupted)"
          else
            time_str = s[:saved_at].strftime("%Y-%m-%d %H:%M")
            lives_str = "#{s[:remaining_mistakes]}/#{s[:max_mistakes]} lives"
            puts "  #{idx + 1}. #{Color.bold(s[:filename])}  [#{time_str}]"
            puts "     Word: #{s[:word_display]} | #{lives_str} | Guesses: #{s[:guesses_count]}"
          end
        end

        puts "  " + Color.cyan("------------------------------------------------------------")
        puts "  Options: Enter number (1-#{saves.length}) to load, 'd #' to delete, 'b' for back"
        print "  Choice: "

        input = gets&.strip
        break if input.nil? || input.downcase == "b" || input.downcase == "back"

        if input.downcase.start_with?("d ")
          # Delete save command
          num_str = input[2..].strip
          idx = num_str.to_i - 1
          if idx >= 0 && idx < saves.length
            target = saves[idx][:filename]
            print "  Are you sure you want to delete '#{target}'? (y/n): "
            if gets&.strip&.downcase&.start_with?("y")
              @save_manager.delete_save(target)
              puts "  Deleted '#{target}'."
              sleep_pause(1)
            end
          else
            puts "  Invalid save number."
            sleep_pause(1)
          end
          next
        end

        idx = input.to_i - 1
        if idx >= 0 && idx < saves.length
          selected = saves[idx]
          if selected[:corrupted]
            puts "  Cannot load corrupted save file."
            sleep_pause(1)
            next
          end

          begin
            game = @save_manager.load_game(selected[:path])
            puts "  Loaded game successfully! Resuming..."
            sleep_pause(1)
            play_loop(game)
            break
          rescue StandardError => e
            puts "  #{Color.red("Error loading game: #{e.message}")}"
            sleep_pause(1.5)
          end
        else
          puts "  Invalid selection."
          sleep_pause(1)
        end
      end
    end

    def show_instructions
      Display.clear_screen
      Display.instructions
      gets
    end

    def prompt_play_again
      print "  Would you like to play another game? (y/n): "
      response = gets&.strip&.downcase
      response&.start_with?("y")
    end

    private

    def sleep_pause(seconds)
      sleep(seconds) if $stdout.tty?
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  Hangman::HangmanApp.new.run
end
