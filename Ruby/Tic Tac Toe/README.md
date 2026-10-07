# Tic Tac Toe (Ruby OOP)

An implementation of the command-line Tic Tac Toe game from [The Odin Project's Ruby Course](https://www.theodinproject.com/lessons/ruby-tic-tac-toe).

## Features
- **Object-Oriented Design**: Cleanly separated into `Board`, `Player`, and `Game` classes with encapsulated responsibilities.
- **Interactive CLI**: Prompts player names, displays an intuitive 1–9 grid layout after each turn, validates moves, and prevents overwriting occupied cells.
- **Robust Input Handling**: Re-prompts gracefully on invalid numbers, non-numeric input, or already-taken spots.
- **Complete Win & Draw Detection**: Automatically checks all 8 winning combinations (3 rows, 3 columns, 2 diagonals) and full board draws.
- **Replayability**: Prompts players to play another round with automatic board reset.

## How to Play

Run the game directly with Ruby:

```bash
ruby tic_tac_toe.rb
```

### Grid Layout
The board uses numbers `1` through `9` corresponding to each cell:

```text
  1 | 2 | 3
 ---+---+---
  4 | 5 | 6
 ---+---+---
  7 | 8 | 9
```

When it is your turn, enter the number of the cell where you want to place your marker (`X` or `O`).

## Running the Automated Tests

An automated test suite is provided to verify board states, win/draw detection, and simulated games:

```bash
ruby test_tic_tac_toe.rb
```
