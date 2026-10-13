# ♚ Ruby Chess CLI (The Odin Project — Ruby Capstone)

A comprehensive, object-oriented, fully rule-enforced command-line implementation of classic **Chess** in Ruby.

This is the final capstone project of [The Odin Project's Ruby Curriculum](https://www.theodinproject.com/lessons/ruby-chess), demonstrating advanced object-oriented design, deep board state simulation, algorithmic move generation, FEN notation compatibility, save/load serialization, heuristic AI, and thorough test coverage using **RSpec**.

---

## 🌟 Key Features

- **Full Chess Rule Enforcement**:
  - **All piece movement mechanics**: Pawns, Knights, Bishops, Rooks, Queens, and Kings.
  - **King Safety & Pins**: Pieces pinned to the King cannot move off the pin line; King cannot move into or through attacked squares.
  - **Castling**: Kingside (`O-O`) and Queenside (`O-O-O`) with checks for moved pieces, unobstructed paths, and square attack safety.
  - **En Passant**: Accurate one-turn window for diagonal capture of an opposing pawn that advanced two squares.
  - **Pawn Promotion**: Choice of Queen, Rook, Bishop, or Knight upon reaching the 8th rank (White) or 1st rank (Black).
  - **Endgame Detection**:
    - **Checkmate**: King is in check and has zero legal moves (victory declared).
    - **Stalemate**: King is not in check and has zero legal moves (draw declared).
    - **Insufficient Material**: Automatic draw for King vs King, King + Bishop vs King, King + Knight vs King, and King + Bishop vs King + Bishop on same-color squares.
    - **50-Move Rule**: Draw declared if 50 consecutive moves (100 half-moves) occur without a pawn advance or piece capture.
- **Save & Load (JSON Serialization)**:
  - Save game at any turn using the `save` command.
  - Resumes exact board configuration, piece moved statuses, en passant targets, move counts, and player types.
- **FEN Import & Export**:
  - Full compatibility with [Forsyth–Edwards Notation (FEN)](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation) for rapid position setup and testing with tools like [Lichess Analysis Board](https://lichess.org/analysis).
- **Intelligent AI Opponent (Extra Credit)**:
  - Play as White or Black against `ChessBot`, which evaluates legal moves using tactical heuristics (immediate checkmate, material capture gain, MVV-LVA, center control, and defensive safety).
  - Spectator mode: Watch two AI bots play against each other!
- **Rich Terminal UI**:
  - High-contrast board with coordinates (`a-h`, `1-8`), alternating light/dark square backgrounds, and solid Unicode pieces (`♚`, `♛`, `♜`, `♝`, `♞`, `♟`).
  - Active highlights for the last move and in-check King.
  - Captured pieces graveyard display with real-time material advantage tally.

---

## 🏗️ Architecture & OOP Design

The project is structured modularly with clear separation of concerns:

```
Ruby/Chess/
├── lib/
│   ├── chess.rb             # Main library aggregator
│   ├── piece.rb             # Base Piece class (colors, geometry, values)
│   ├── pieces/
│   │   ├── pawn.rb          # Pawn (1/2-step, diagonal, en passant, promotion)
│   │   ├── knight.rb        # Knight (L-shaped jumps)
│   │   ├── bishop.rb        # Bishop (diagonal sliding rays)
│   │   ├── rook.rb          # Rook (orthogonal sliding rays)
│   │   ├── queen.rb         # Queen (8 sliding rays)
│   │   └── king.rb          # King (single steps, castling checks)
│   ├── move.rb              # Encapsulates move coordinates, pieces, and special flags
│   ├── board.rb             # 8x8 grid, check/mate/draw logic, deep duplication
│   ├── display.rb           # ANSI terminal graphics and alert rendering
│   ├── fen.rb               # FEN reader & exporter
│   ├── player.rb            # Base Player class
│   ├── human_player.rb      # Interactive input parsing and CLI prompts
│   ├── computer_player.rb   # Heuristic AI decision engine
│   ├── serializer.rb        # JSON file persistence (saves/ directory)
│   └── game.rb              # Master game loop and turn orchestrator
├── saves/                   # Directory where games are saved
├── spec/                    # Comprehensive RSpec test suite
│   ├── piece_spec.rb        # Piece movement & attack coverage
│   ├── board_spec.rb        # Setup, pinning, and check detection
│   ├── special_moves_spec.rb# Castling, en passant, and promotion
│   ├── check_and_mate_spec.rb# Checkmate, stalemate, draws, check evasion
│   ├── serializer_spec.rb   # JSON persistence tests
│   ├── fen_spec.rb          # FEN export and import tests
│   ├── human_player_spec.rb # Input parser & command handling
│   ├── computer_player_spec.rb # AI tactical decision tests
│   ├── game_spec.rb         # Game loop & win condition integration
│   └── spec_helper.rb       # RSpec configuration
├── main.rb                  # Interactive CLI entrypoint
├── Gemfile                  # Dependencies (rspec)
└── README.md                # Project documentation
```

---

## 🎮 How to Play

### Starting the Game

Run the main script with Ruby:

```bash
ruby main.rb
```

You will be greeted by the start menu:
```
  [1] Player vs Player (2 Human Players)
  [2] Player vs Computer (Play as White)
  [3] Player vs Computer (Play as Black)
  [4] Computer vs Computer (Spectator Mode)
  [5] Load Saved Game
  [6] View Rules & Instructions
  [7] Exit
```

### Entering Moves

Moves can be entered in several flexible ways:

1. **Standard Coordinates**:
   - `e2e4` or `e2 e4`
   - `g1f3` or `g1 f3`
2. **Castling**:
   - Kingside: `O-O` or `0-0`
   - Queenside: `O-O-O` or `0-0-0`
3. **Pawn Promotion**:
   - Optionally append the target piece letter: `e7e8q` (Queen), `e7e8r` (Rook), `e7e8b` (Bishop), or `e7e8n` (Knight).
   - If omitted, an interactive prompt will ask you to choose.
4. **Square Inspection**:
   - Type a single coordinate like `e2` to see all legal moves for that piece, followed by a prompt for the destination square!

### In-Game Commands

At your turn, you can type any of the following commands:
- `save` : Save the current game to disk in `saves/`.
- `load` : Load and resume a previously saved game.
- `resign` : Forfeit the match to your opponent.
- `draw` : Offer a draw (opposing human is prompted to accept or decline; AI accepts if position is equal or worse).
- `help` : View command and move entry guidelines.
- `quit` : Exit the game.

---

## 🧪 Running the Test Suite

The test suite is built with **RSpec** and covers 61 specifications across all mechanics:

```bash
bundle exec rspec
```

Sample output:
```
Finished in 0.35 seconds
61 examples, 0 failures
```

---

## 📚 Resources & Credits

- [The Odin Project: Ruby Chess](https://www.theodinproject.com/lessons/ruby-chess)
- [FIDE Laws of Chess](https://www.fide.com/FIDE/handbook/LawsOfChess.pdf)
- [Lichess Analysis Board & FEN Tools](https://lichess.org/analysis)
