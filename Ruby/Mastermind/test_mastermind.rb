# Test Suite for Mastermind
require_relative "mastermind"
require "stringio"

def assert(condition, message)
  if condition
    print "."
  else
    puts "\n❌ FAILED: #{message}"
    caller.each { |line| puts "   #{line}" }
    exit(1)
  end
end

puts "\nRunning Mastermind tests..."

# 1. Code Class & Parsing Tests
c1 = Code.new(%w[Red Green Blue Yellow])
assert(c1.pegs == %w[Red Green Blue Yellow], "Code initializes pegs correctly")
assert(c1.to_s == "[Red] [Green] [Blue] [Yellow]", "Code to_s outputs formatted pegs")

# Equality
c2 = Code.new(%w[Red Green Blue Yellow])
c3 = Code.new(%w[Red Green Blue Orange])
assert(c1 == c2, "Code equality works for identical pegs")
assert(c1 != c3, "Code inequality works for differing pegs")

# Random Code
rnd = Code.random
assert(rnd.pegs.length == 4, "Random code has length 4")
assert(rnd.pegs.all? { |p| Code::COLORS.include?(p) }, "Random code colors are valid")

# Parsing: Space-separated numbers
parsed1 = Code.parse("1 2 3 4")
assert(parsed1 == Code.new(%w[Red Green Blue Yellow]), "Parses '1 2 3 4'")

# Parsing: Contiguous numbers
parsed2 = Code.parse("1234")
assert(parsed2 == Code.new(%w[Red Green Blue Yellow]), "Parses '1234'")

# Parsing: Letters
parsed3 = Code.parse("r g b y")
assert(parsed3 == Code.new(%w[Red Green Blue Yellow]), "Parses 'r g b y'")

parsed4 = Code.parse("rgby")
assert(parsed4 == Code.new(%w[Red Green Blue Yellow]), "Parses 'rgby'")

# Parsing: Full names
parsed5 = Code.parse("Red Green Blue Yellow")
assert(parsed5 == Code.new(%w[Red Green Blue Yellow]), "Parses full color names")

# Parsing: Case insensitivity
parsed6 = Code.parse("p u r p l e  o r a n g e  r e d  b l u e") rescue nil
parsed6_clean = Code.parse("purple orange red blue")
assert(parsed6_clean == Code.new(%w[Purple Orange Red Blue]), "Parses lowercase full names")

# Parsing: Invalid inputs
assert(Code.parse("1 2 3").nil?, "Rejects code with fewer than 4 items")
assert(Code.parse("1 2 3 4 5").nil?, "Rejects code with more than 4 items")
assert(Code.parse("1 2 3 9").nil?, "Rejects out-of-range number '9'")
assert(Code.parse("r g b z").nil?, "Rejects invalid letter 'z'")
assert(Code.parse("").nil?, "Rejects empty string")
assert(Code.parse(nil).nil?, "Rejects nil")

# 2. Feedback / Comparison Scoring Tests
# Test 4 exact matches
fb = Code.compare(Code.parse("1234"), Code.parse("1234"))
assert(fb == { exact: 4, color: 0 }, "4 exact matches returns { exact: 4, color: 0 }")

# Test 0 exact, 4 color matches (complete transposition)
fb = Code.compare(Code.parse("1234"), Code.parse("4321"))
assert(fb == { exact: 0, color: 4 }, "Complete reversal returns { exact: 0, color: 4 }")

# Test duplicate colors in secret
# Secret: [Red, Red, Blue, Yellow] (1, 1, 3, 4)
# Guess:  [Red, Blue, Green, Purple] (1, 3, 2, 5)
# Exact: pos 0 (Red == Red) -> 1
# Color: Blue in guess matches Blue in secret -> 1
fb = Code.compare(Code.parse("1 1 3 4"), Code.parse("1 3 2 5"))
assert(fb == { exact: 1, color: 1 }, "Duplicate in secret with partial match returns exact: 1, color: 1")

# Secret: [Red, Red, Green, Green] (1, 1, 2, 2)
# Guess:  [Red, Green, Red, Green] (1, 2, 1, 2)
# Exact: pos 0 (Red), pos 3 (Green) -> 2
# Color: pos 1 (Green), pos 2 (Red) -> 2
fb = Code.compare(Code.parse("1 1 2 2"), Code.parse("1 2 1 2"))
assert(fb == { exact: 2, color: 2 }, "2 exact and 2 transposed returns exact: 2, color: 2")

# Secret: [Red, Blue, Blue, Blue] (1, 3, 3, 3)
# Guess:  [Red, Red, Red, Red] (1, 1, 1, 1)
# Exact: pos 0 (Red) -> 1
# Color: remaining guesses are Red, but secret has no more Red -> 0
fb = Code.compare(Code.parse("1 3 3 3"), Code.parse("1 1 1 1"))
assert(fb == { exact: 1, color: 0 }, "Excess guess duplicates do not create phantom color matches")

# No matches
fb = Code.compare(Code.parse("1 2 3 4"), Code.parse("5 6 5 6"))
assert(fb == { exact: 0, color: 0 }, "No matching colors returns exact: 0, color: 0")

# 3. Board Tests
board = Board.new
assert(board.turns_used == 0, "Board starts with 0 turns used")
assert(board.turns_remaining == 12, "Board starts with 12 turns remaining")
assert(!board.full?, "Board is not full initially")

board.add_turn(Code.parse("1234"), { exact: 1, color: 2 })
assert(board.turns_used == 1, "Board records turns")
assert(board.turns_remaining == 11, "Turns remaining decrements")

11.times { board.add_turn(Code.parse("1234"), { exact: 0, color: 0 }) }
assert(board.full?, "Board is full after 12 turns")

# 4. ComputerSolver Tests
# Test that ComputerSolver solves arbitrary secret codes within <= 6 turns
test_secrets = [
  Code.parse("1 2 3 4"), # all distinct
  Code.parse("1 1 2 2"), # pairs
  Code.parse("5 5 5 5"), # all identical
  Code.parse("6 3 2 6"), # outer pair
  Code.parse("4 1 5 2")  # mixed
]

test_secrets.each do |secret|
  solver = ComputerSolver.new
  last_fb = nil
  turns = 0

  loop do
    turns += 1
    guess = solver.choose_guess(last_fb)
    fb = Code.compare(secret, guess)
    break if fb[:exact] == 4

    last_fb = fb
    assert(turns < 12, "Solver must not exceed 12 turns")
  end

  assert(turns <= 6, "Solver solved #{secret} in #{turns} turns (<= 6 turns)")
end

# 5. Game Simulation: Codebreaker Mode (Human guesses secret code)
# Secret is mocked / known by piping the winning guess
sim_input = StringIO.new("1\n1234\nn\n") # Option 1: Codebreaker, Guess: 1234, Replay: n
sim_output = StringIO.new

game = Game.new(input: sim_input, output: sim_output, delay_enabled: false)
# Intercept random code to make test deterministic
def Code.random
  Code.new(%w[Red Green Blue Yellow]) # 1 2 3 4
end

game.play

out_str = sim_output.string
assert(out_str.include?("cracked the secret code in 1 turns!"), "Codebreaker human win announced")

# Restore original Code.random
class << Code
  remove_method :random
  def random
    new(Array.new(4) { COLORS.sample })
  end
end

# 6. Game Simulation: Codemaker Mode (Human creates code, computer solves)
# Option 2: Codemaker, Secret Code: 3 4 5 6, Replay: n
sim_cm_input = StringIO.new("2\n3 4 5 6\nn\n")
sim_cm_output = StringIO.new

cm_game = Game.new(input: sim_cm_input, output: sim_cm_output, delay_enabled: false)
cm_game.play

cm_out_str = cm_output = sim_cm_output.string
assert(cm_out_str.include?("The computer cracked your secret code"), "Codemaker mode successfully completes")

# 7. Rules View & Quit Simulation
sim_menu_input = StringIO.new("3\n4\n") # View rules (3), then Quit (4)
sim_menu_output = StringIO.new

menu_game = Game.new(input: sim_menu_input, output: sim_menu_output, delay_enabled: false)
menu_game.play

assert(sim_menu_output.string.include?("--- MASTERMIND RULES ---"), "Displays rules menu correctly")
assert(sim_menu_output.string.include?("Thanks for playing Mastermind!"), "Quits gracefully")

puts "\n\nAll Mastermind tests passed successfully! 🎉\n"
