# frozen_string_literal: true

# Test Suite for Hangman
require_relative "hangman"
require "tmpdir"
require "fileutils"

def assert(condition, message)
  if condition
    print "."
  else
    puts "\n❌ FAILED: #{message}"
    caller.each { |line| puts "   #{line}" }
    exit(1)
  end
end

puts "\nRunning Hangman test suite..."

# ==============================================================================
# 1. Dictionary Tests
# ==============================================================================
dict = Hangman::Dictionary.new
assert(!dict.words.empty?, "Dictionary loaded words")
assert(dict.words.all? { |w| w.length.between?(5, 12) }, "All dictionary words are between 5 and 12 characters")
assert(dict.words.all? { |w| w.match?(/\A[a-z]+\z/) }, "All dictionary words are lowercase alphabetic")

sample_word = dict.random_word
assert(sample_word.is_a?(String), "Random word is a String")
assert(sample_word.length.between?(5, 12), "Random word length is between 5 and 12 characters")

# Fallback dictionary test
fallback_dict = Hangman::Dictionary.new("non_existent_dictionary_file.txt")
assert(!fallback_dict.words.empty?, "Fallback dictionary provides words when file is missing")
assert(fallback_dict.words.all? { |w| w.length.between?(5, 12) }, "Fallback words obey 5-12 length constraint")

# ==============================================================================
# 2. Game Core Logic Tests
# ==============================================================================
game = Hangman::Game.new(secret_word: "programming")

# Initial state
assert(game.secret_word == "programming", "Secret word stored correctly")
assert(game.max_mistakes == 7, "Default max mistakes is 7")
assert(game.remaining_mistakes == 7, "Initial remaining mistakes is 7")
assert(game.mistakes_made == 0, "Initial mistakes made is 0")
assert(game.guessed_letters.empty?, "Initial guessed letters is empty")
assert(!game.won?, "Game is not won initially")
assert(!game.lost?, "Game is not lost initially")
assert(!game.game_over?, "Game is not over initially")
assert(game.word_display == "_ _ _ _ _ _ _ _ _ _ _", "Initial word display has all underscores")

# Valid correct guess
res1 = game.guess("p")
assert(res1[:status] == :correct, "Correct guess returns :correct status")
assert(game.guessed_letters == ["p"], "Guessed letters includes 'p'")
assert(game.correct_guesses == ["p"], "Correct guesses includes 'p'")
assert(game.remaining_mistakes == 7, "Correct guess does not reduce lives")
assert(game.word_display == "p _ _ _ _ _ _ _ _ _ _", "Word display reveals 'p'")

# Multiple occurrences in secret word: 'r' appears at index 1 and 4
res2 = game.guess("r")
assert(res2[:status] == :correct, "Correct guess for 'r'")
assert(game.word_display == "p r _ _ r _ _ _ _ _ _", "Reveals all instances of 'r'")

# Case insensitivity
res3 = game.guess("O")
assert(res3[:status] == :correct, "Uppercase guess handled case-insensitively")
assert(game.guessed_letters.include?("o"), "Guessed letters stores lowercase 'o'")
assert(game.word_display == "p r o _ r _ _ _ _ _ _", "Word display reveals 'o'")

# Incorrect guess
res4 = game.guess("z")
assert(res4[:status] == :incorrect, "Incorrect guess returns :incorrect status")
assert(game.incorrect_guesses == ["z"], "Incorrect guesses contains 'z'")
assert(game.remaining_mistakes == 6, "Incorrect guess decrements remaining mistakes")
assert(game.mistakes_made == 1, "Mistakes made increments to 1")

# Duplicate guess
res5 = game.guess("p")
assert(res5[:status] == :duplicate, "Duplicate guess returns :duplicate status")
assert(game.remaining_mistakes == 6, "Duplicate guess does not penalize lives")

# Duplicate incorrect guess
res6 = game.guess("z")
assert(res6[:status] == :duplicate, "Duplicate incorrect guess returns :duplicate status")
assert(game.remaining_mistakes == 6, "Duplicate incorrect guess does not penalize lives")

# Invalid input: multi-character
res_invalid1 = game.guess("abc")
assert(res_invalid1[:status] == :invalid, "Multi-character input returns :invalid status")
assert(game.remaining_mistakes == 6, "Invalid input does not penalize lives")

# Invalid input: numbers & punctuation
res_invalid2 = game.guess("9")
assert(res_invalid2[:status] == :invalid, "Numeric input returns :invalid status")
res_invalid3 = game.guess("!")
assert(res_invalid3[:status] == :invalid, "Punctuation input returns :invalid status")
res_invalid4 = game.guess("")
assert(res_invalid4[:status] == :invalid, "Empty input returns :invalid status")

# ==============================================================================
# 3. Game Win & Loss Conditions
# ==============================================================================
# Win Scenario
win_game = Hangman::Game.new(secret_word: "ruby")
%w[r u b].each { |l| win_game.guess(l) }
assert(!win_game.won?, "Not won until the last letter is guessed")
win_game.guess("y")
assert(win_game.won?, "Game is won when all letters are guessed")
assert(!win_game.lost?, "Won game is not lost")
assert(win_game.game_over?, "Game is over when won")
assert(win_game.word_display == "r u b y", "Word display fully revealed on win")

# Loss Scenario (7 mistakes)
loss_game = Hangman::Game.new(secret_word: "ruby")
wrong_letters = %w[a c d e f g h]
wrong_letters.each_with_index do |letter, i|
  assert(loss_game.remaining_mistakes == 7 - i, "Mistakes track correctly step #{i}")
  loss_game.guess(letter)
end
assert(loss_game.remaining_mistakes == 0, "0 mistakes remaining after 7 wrong guesses")
assert(loss_game.mistakes_made == 7, "7 mistakes made")
assert(loss_game.lost?, "Game is lost when lives reach 0")
assert(!loss_game.won?, "Lost game is not won")
assert(loss_game.game_over?, "Game is over when lost")

# ==============================================================================
# 4. Serialization (to_h and from_h)
# ==============================================================================
mid_game = Hangman::Game.new(secret_word: "algorithm", guessed_letters: %w[a l x z], max_mistakes: 7)
hash_data = mid_game.to_h
assert(hash_data["secret_word"] == "algorithm", "Serialized secret word matches")
assert(hash_data["guessed_letters"] == %w[a l x z], "Serialized guessed letters match")
assert(hash_data["max_mistakes"] == 7, "Serialized max mistakes matches")

restored_game = Hangman::Game.from_h(hash_data)
assert(restored_game.secret_word == "algorithm", "Restored secret word matches")
assert(restored_game.guessed_letters == %w[a l x z], "Restored guessed letters match")
assert(restored_game.word_display == "a l _ _ _ _ _ _ _", "Restored word display matches")
assert(restored_game.remaining_mistakes == 5, "Restored remaining mistakes matches (7 - 2 incorrect)")
assert(restored_game.incorrect_guesses == %w[x z], "Restored incorrect guesses match")

# Resuming gameplay on restored game works perfectly
restored_game.guess("g")
assert(restored_game.word_display == "a l g _ _ _ _ _ _", "Restored game continues play correctly")

# ==============================================================================
# 5. SaveManager Tests (File System & JSON Persistence)
# ==============================================================================
Dir.mktmpdir do |tmp_dir|
  save_mgr = Hangman::SaveManager.new(tmp_dir)

  assert(save_mgr.list_saves.empty?, "Initially no saves in empty directory")

  # Save game with custom name
  save_path1 = save_mgr.save_game(mid_game, "test_slot_1")
  assert(File.exist?(save_path1), "Save file created on disk")
  assert(File.basename(save_path1) == "test_slot_1.json", "Filename formatted with .json extension")

  # Save game with automatic timestamp name
  save_path2 = save_mgr.save_game(win_game, nil)
  assert(File.exist?(save_path2), "Timestamped save file created on disk")

  # Listing saves
  saves = save_mgr.list_saves
  assert(saves.length == 2, "Lists both saved games")
  slot1_meta = saves.find { |s| s[:filename] == "test_slot_1.json" }
  assert(!slot1_meta.nil?, "Found slot 1 in listed saves")
  assert(slot1_meta[:word_length] == 9, "Save metadata contains correct word length")
  assert(slot1_meta[:remaining_mistakes] == 5, "Save metadata contains correct remaining mistakes")
  assert(slot1_meta[:guesses_count] == 4, "Save metadata contains correct guesses count")

  # Loading saved game
  loaded_game = save_mgr.load_game("test_slot_1")
  assert(loaded_game.secret_word == "algorithm", "Loaded game has identical secret word")
  assert(loaded_game.guessed_letters == %w[a l x z], "Loaded game has identical guesses")
  assert(loaded_game.remaining_mistakes == 5, "Loaded game has identical remaining mistakes")

  # Loading by full path
  loaded_by_path = save_mgr.load_game(save_path1)
  assert(loaded_by_path.secret_word == "algorithm", "Loading by full path succeeds")

  # Deleting save
  deleted = save_mgr.delete_save("test_slot_1")
  assert(deleted, "Delete save returns true")
  assert(!File.exist?(save_path1), "Save file was removed from disk")
  assert(save_mgr.list_saves.length == 1, "Save list decremented after deletion")

  # Filename sanitization
  safe_path = save_mgr.save_game(win_game, "../../hacked_save")
  assert(File.dirname(safe_path) == tmp_dir, "Sanitization prevents directory traversal")
end

# ==============================================================================
# 6. Display & Gallows Verification
# ==============================================================================
assert(Hangman::Display::GALLOWS.length == 8, "Gallows stages count is 8 (0 to 7 mistakes)")
Hangman::Display::GALLOWS.each_with_index do |stage, i|
  assert(!stage.empty?, "Gallows stage #{i} is non-empty")
end

# ==============================================================================
# 7. End-to-End CLI Flow Tests (Simulated User Inputs)
# ==============================================================================
require "stringio"

# Scenario A: Play, Save, Return to Menu, Load Saved Game, and Win!
Dir.mktmpdir do |tmp_dir|
  save_mgr = Hangman::SaveManager.new(tmp_dir)
  mock_dict = Object.new
  def mock_dict.random_word; "ruby"; end

  app = Hangman::HangmanApp.new(mock_dict, save_mgr)

  inputs = [
    "1",         # 1. Start new game
    "r",         # Guess 'r'
    "u",         # Guess 'u'
    "save",      # Save game
    "test_save", # Save file name
    "n",         # Continue playing? 'n' -> return to menu
    "2",         # 2. Load game menu
    "1",         # Select 1st save (test_save.json)
    "b",         # Guess 'b'
    "y",         # Guess 'y' -> GAME WON!
    "n",         # Play again? 'n' -> returns to menu
    "4"          # 4. Exit
  ]

  orig_stdin = $stdin
  orig_stdout = $stdout
  $stdin = StringIO.new(inputs.join("\n") + "\n")
  $stdout = StringIO.new

  begin
    app.run
  ensure
    $stdin = orig_stdin
    output = $stdout.string
    $stdout = orig_stdout
  end

  assert(output.include?("CONGRATULATIONS"), "App output includes victory message")
  assert(output.include?("test_save.json"), "App output showed saved game file")
  assert(output.include?("RUBY"), "App output confirms secret word RUBY was solved")
end

# Scenario B: Instructions Menu & Exit
Dir.mktmpdir do |tmp_dir|
  save_mgr = Hangman::SaveManager.new(tmp_dir)
  mock_dict = Object.new
  def mock_dict.random_word; "testword"; end

  app = Hangman::HangmanApp.new(mock_dict, save_mgr)

  inputs = [
    "3", # Show instructions
    "",  # Press enter to return to menu
    "4"  # Exit
  ]

  orig_stdin = $stdin
  orig_stdout = $stdout
  $stdin = StringIO.new(inputs.join("\n") + "\n")
  $stdout = StringIO.new

  begin
    app.run
  ensure
    $stdin = orig_stdin
    output = $stdout.string
    $stdout = orig_stdout
  end

  assert(output.include?("HOW TO PLAY HANGMAN"), "Instructions displayed successfully")
  assert(output.include?("Thanks for playing Hangman"), "Exit goodbye message displayed")
end

# Scenario C: Loss Game Over Flow
Dir.mktmpdir do |tmp_dir|
  save_mgr = Hangman::SaveManager.new(tmp_dir)
  mock_dict = Object.new
  def mock_dict.random_word; "ruby"; end

  app = Hangman::HangmanApp.new(mock_dict, save_mgr)

  inputs = [
    "1", # Start game
    "a", "c", "d", "e", "f", "g", "h", # 7 incorrect guesses
    "n", # Play again? 'n'
    "4"  # Exit
  ]

  orig_stdin = $stdin
  orig_stdout = $stdout
  $stdin = StringIO.new(inputs.join("\n") + "\n")
  $stdout = StringIO.new

  begin
    app.run
  ensure
    $stdin = orig_stdin
    output = $stdout.string
    $stdout = orig_stdout
  end

  assert(output.include?("GAME OVER"), "App output shows GAME OVER screen on loss")
  assert(output.include?("RUBY"), "App output reveals secret word on loss")
end

puts "\n\nAll Hangman tests passed successfully! (50+ assertions verified)\n"

