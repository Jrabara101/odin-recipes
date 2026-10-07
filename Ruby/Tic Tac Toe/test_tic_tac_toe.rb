# Test Suite for Tic Tac Toe
require_relative "tic_tac_toe"
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

puts "\nRunning Tic Tac Toe tests..."

# 1. Board Tests
board = Board.new
assert(board.cells == (1..9).to_a, "Initial board has numbers 1 through 9")

# Valid move validation
assert(board.valid_move?(1), "Spot 1 is valid initially")
assert(board.valid_move?(9), "Spot 9 is valid initially")
assert(!board.valid_move?(0), "Spot 0 is out of bounds")
assert(!board.valid_move?(10), "Spot 10 is out of bounds")
assert(!board.valid_move?("5"), "String move is invalid")
assert(!board.valid_move?(-1), "Negative spot is invalid")

# Updating cells
assert(board.update(5, "X") == true, "Update spot 5 with X returns true")
assert(board.cells[4] == "X", "Spot 5 is now X")
assert(!board.valid_move?(5), "Spot 5 is no longer a valid move")
assert(board.update(5, "O") == false, "Cannot overwrite spot 5")

# Win Conditions - Rows
[
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9]
].each_with_index do |row, idx|
  b = Board.new
  row.each { |pos| b.update(pos, "X") }
  assert(b.winning_combination?("X"), "Detects win on row #{idx + 1}")
  assert(!b.winning_combination?("O"), "Does not falsely award win to O")
end

# Win Conditions - Columns
[
  [1, 4, 7],
  [2, 5, 8],
  [3, 6, 9]
].each_with_index do |col, idx|
  b = Board.new
  col.each { |pos| b.update(pos, "O") }
  assert(b.winning_combination?("O"), "Detects win on column #{idx + 1}")
  assert(!b.winning_combination?("X"), "Does not falsely award win to X")
end

# Win Conditions - Diagonals
b_diag1 = Board.new
[1, 5, 9].each { |pos| b_diag1.update(pos, "X") }
assert(b_diag1.winning_combination?("X"), "Detects main diagonal win [1, 5, 9]")

b_diag2 = Board.new
[3, 5, 7].each { |pos| b_diag2.update(pos, "O") }
assert(b_diag2.winning_combination?("O"), "Detects anti-diagonal win [3, 5, 7]")

# Non-winning states
b_incomplete = Board.new
b_incomplete.update(1, "X")
b_incomplete.update(2, "X")
assert(!b_incomplete.winning_combination?("X"), "2-in-a-row is not a win")

# Tie / Full Board
# X O X
# X X O
# O X O
b_tie = Board.new
moves = [
  [1, "X"], [2, "O"], [3, "X"],
  [4, "X"], [5, "X"], [6, "O"],
  [7, "O"], [8, "X"], [9, "O"]
]
moves.each { |pos, marker| b_tie.update(pos, marker) }
assert(b_tie.full?, "Detects full board")
assert(!b_tie.winning_combination?("X"), "Tie board has no X win")
assert(!b_tie.winning_combination?("O"), "Tie board has no O win")
assert(b_tie.tie?, "Detects tie game")

# Board Reset
b_tie.reset
assert(b_tie.cells == (1..9).to_a, "Board reset restores 1 through 9")
assert(!b_tie.full?, "Board is no longer full after reset")

# 2. Player Tests
p1 = Player.new("Alice", "X")
p2 = Player.new("Bob", "O")
assert(p1.name == "Alice", "Player 1 has correct name")
assert(p1.marker == "X", "Player 1 has correct marker")
assert(p1.to_s == "Alice (X)", "Player to_s formats as expected")
assert(p2.to_s == "Bob (O)", "Player 2 to_s formats as expected")

# 3. Game Simulation: Player 1 Wins
# Moves:
# X: 1, 2, 3
# O: 4, 5
# Game sequence:
# P1: 1
# P2: 4
# P1: 2
# P2: 5
# P1: 3 (Wins!)
# Replay? n
sim_input = StringIO.new("1\n4\n2\n5\n3\nn\n")
sim_output = StringIO.new
game = Game.new(player1: p1, player2: p2, input: sim_input, output: sim_output)
game.play

output_text = sim_output.string
assert(output_text.include?("Congratulations Alice! You won the game!"), "Simulated game recognizes Alice win")
assert(game.winner?, "Game winner? returns true")

# 4. Game Simulation: Tie Game
# Board:
# 1(X) 2(O) 3(X)
# 4(X) 5(O) 6(O)
# 7(O) 8(X) 9(X)
# Sequence:
# P1: 1
# P2: 2
# P1: 3
# P2: 5
# P1: 4
# P2: 6
# P1: 8
# P2: 7
# P1: 9
# Replay? n
sim_tie_input = StringIO.new("1\n2\n3\n5\n4\n6\n8\n7\n9\nn\n")
sim_tie_output = StringIO.new
tie_game = Game.new(player1: p1, player2: p2, input: sim_tie_input, output: sim_tie_output)
tie_game.play

tie_output = sim_tie_output.string
assert(tie_output.include?("It's a draw! Well played by both players!"), "Simulated game recognizes Draw")
assert(tie_game.draw?, "Tie game draw? returns true")

# 5. Game Simulation: Invalid Inputs Handled Gracefully
# Sequence:
# P1 tries "invalid", "99", then "1"
# P2 tries "1" (already taken), then "2"
# P1: 4
# P2: 5
# P1: 7 (Wins column 1-4-7)
# Replay? n
sim_invalid_input = StringIO.new("invalid\n99\n1\n1\n2\n4\n5\n7\nn\n")
sim_invalid_output = StringIO.new
invalid_test_game = Game.new(player1: p1, player2: p2, input: sim_invalid_input, output: sim_invalid_output)
invalid_test_game.play

invalid_output = invalid_test_game.output.string
assert(invalid_output.include?("Invalid input! Please enter a number between 1 and 9"), "Handles non-numeric/out-of-range input")
assert(invalid_output.include?("Spot 1 is already taken!"), "Handles already occupied spot input")
assert(invalid_output.include?("Congratulations Alice! You won the game!"), "Continues game properly after handling errors")

puts "\n\nAll tests passed successfully! 🎉\n"
