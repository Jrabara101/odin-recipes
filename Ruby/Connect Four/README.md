# Connect Four (The Odin Project)

An object-oriented, command-line implementation of the classic game **Connect Four** in Ruby, built strictly adhering to **Test-Driven Development (TDD)** using **RSpec**.

---

## 🎯 Game Overview & Rules

Connect Four is a two-player connection game played on a vertical grid of **6 rows** and **7 columns**:
1. Players take turns choosing a column (1–7) to drop their colored game piece (🔴 Red for Player 1, 🟡 Yellow for Player 2).
2. The piece falls down the chosen column, occupying the lowest available empty slot.
3. The first player to connect **4 consecutive pieces** horizontally, vertically, or diagonally wins the game.
4. If all 42 slots on the board are filled without any player connecting four pieces, the match ends in a **draw**.

---

## 🏗️ Architecture & Object-Oriented Design

The codebase separates concerns across three core classes:

1. **[`Player`](lib/player.rb)**:
   - Encapsulates player state: `name` and `symbol` (e.g. 🔴 or 🟡).
   - Provides defaults for quick start or custom player initialization.

2. **[`Board`](lib/board.rb)**:
   - Manages the 6×7 grid state (`grid`).
   - `#drop_piece(column, symbol)`: Accurately simulates gravity by placing pieces at the lowest available row index in the specified column.
   - `#valid_column?(column)`: Validates that column input is an integer between 1 and 7 and is not full.
   - `#column_full?(column)`: Checks if a specific column has reached its capacity (6 pieces).
   - `#full?`: Detects whether all 42 board cells are occupied.
   - `#win?(symbol)`: Evaluates all 4 win vectors:
     - Horizontal lines
     - Vertical columns
     - Ascending diagonals (`/`, bottom-left to top-right)
     - Descending diagonals (`\`, top-left to bottom-right)
   - `#render`: Generates a formatted ASCII/Unicode game board with column numbers and clean dividers.

3. **[`Game`](lib/game.rb)**:
   - Orchestrates gameplay loop and turn management via dependency injection (`board`, `player1`, `player2`).
   - `#solicit_move`: Prompts players, sanitizes input, provides descriptive feedback on full columns or out-of-bounds choices, and re-prompts until a valid column is selected.
   - `#take_turn`: Renders current board state and processes the move.
   - `#switch_players`: Alternates turns between Player 1 and Player 2.
   - `#game_over?`: Evaluates victory and draw conditions.
   - Fully isolated in unit tests using RSpec doubles and mocks for I/O and collaborator objects.

---

## 🧪 Test-Driven Development (TDD) with RSpec

This project was built following the Red-Green-Refactor TDD cycle. Every feature, edge case, and validation was driven by failing specs before implementation.

### Test Coverage Highlights
- **Initialization**: Board dimensions (6 rows × 7 columns) and empty cell state.
- **Gravity & Stacking**: First token lands on bottom row (row index 5); subsequent tokens stack directly on top (row index 4, 3, etc.).
- **Boundaries & Validation**:
  - Out-of-bounds column numbers (`0`, `8`, `-1`).
  - Non-numeric input (`'abc'`, empty input).
  - Attempting to drop into a full column (returns `false` and alerts the player).
- **Win Condition Matrix**:
  - Horizontal wins across bottom, middle, and top rows; left, middle, and right columns.
  - Vertical wins from column 1 to 7, including stacking on top of opponent tokens.
  - Ascending diagonal wins (`/`) across left and right edges.
  - Descending diagonal wins (`\`) across left and right edges.
  - False positives prevention: exactly 3 tokens, broken/blocked lines, alternating opponent pieces.
- **Draw Detection**: Full board (42 pieces) with no winner triggers a draw; partially full boards return `false`.
- **Game Orchestration & Test Doubles**: Uses `instance_double(Board)` and `instance_double(Player)` with message expectations (`receive(:render)`, `receive(:drop_piece)`) to verify game mechanics in complete isolation.

---

## 🚀 Running the Tests

To run the full test suite with documentation formatting:

```bash
# Run with RSpec directly
rspec

# Or with Bundler
bundle exec rspec
```

Example output:
```text
Board
  #render
    returns a formatted string displaying the grid and columns
  #win?
    horizontal wins
      detects 4 in a row at the bottom
      detects 4 in a row at the right edge
      detects 4 in a row in a higher row
      returns false when 4 tokens are interrupted by another player
      returns false for only 3 consecutive tokens
    vertical wins
      detects 4 consecutive tokens in column 1
      detects 4 consecutive tokens in column 7
      detects 4 consecutive tokens stacked on top of an opponent piece
      returns false for only 3 consecutive stacked tokens
    diagonal wins (ascending / bottom-left to top-right)
      detects the ascending diagonal win for red
      detects ascending diagonal on the right edge (cols 4 to 7)
      returns false for ascending diagonal with only 3 tokens
    diagonal wins (descending / top-left to bottom-right)
      detects the descending diagonal win for red
      detects descending diagonal on the right edge (cols 4 to 7)
      returns false when a diagonal is broken by an opponent token
...
Finished in 0.4 seconds
62 examples, 0 failures
```

---

## 🎮 How to Play

Start an interactive two-player game directly from your terminal:

```bash
ruby main.rb
# or
ruby lib/connect_four.rb
```

You will be prompted to enter player names (or press Enter for defaults) and take turns choosing columns 1 through 7.
