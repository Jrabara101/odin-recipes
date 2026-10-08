# Hangman (Ruby OOP)

A feature-rich command-line implementation of the classic word-guessing game **Hangman** from [The Odin Project's Ruby Course](https://www.theodinproject.com/lessons/ruby-hangman).

---

## Features

- **Dictionary Word Selection**:
  - Automatically loads and filters over 9,800 English words from `google-10000-english-no-swears.txt`.
  - Filters secret words to between 5 and 12 characters long.
  - Graceful fallback words built-in if the dictionary file is missing.
- **Dynamic ASCII Gallows & Visual Status**:
  - 8-stage visual stick figure gallows (from empty gallows at 0 mistakes to game over at 7 mistakes).
  - Clear lives counter with visual heart indicators (`● ● ● ● ○ ○ ○`) and danger warnings.
  - Word display showing revealed letters in their exact positions (e.g. `_ r o g r a _ _ i n g`).
  - Alphabet bank (`A` through `Z`) highlighting available vs. already guessed letters.
  - List of incorrect letter guesses.
- **Save & Load Game System**:
  - Serializes and deserializes complete game state to and from JSON format.
  - Type `save` (or `s`) at the start of any turn to save your game.
  - Choose a custom save name or press Enter for an automatic timestamped save.
  - Choose to keep playing or return to the main menu after saving.
  - Load saved games directly from the main menu with rich preview metadata (word length, revealed letters, remaining lives, and timestamp).
  - Built-in save manager allows loading or deleting save files.
- **Robust Input Handling**:
  - Case-insensitive letter guesses (`A` is treated identical to `a`).
  - Validates single-letter alphabetic inputs (`[a-z]`).
  - Guards against duplicate guesses and invalid entries without deducting lives.

---

## Project Structure

```text
Ruby/Hangman/
├── google-10000-english-no-swears.txt  # 10,000 English word dictionary
├── hangman.rb                          # Core game logic, OOP classes & CLI app
├── test_hangman.rb                     # Automated test suite (50+ assertions)
├── saves/                              # Directory for JSON saved games
└── README.md                           # Documentation and guide
```

### Architecture & OOP Classes

- **`Hangman::Dictionary`**: Handles file reading, length filtering (5–12 characters), and secret word sampling.
- **`Hangman::Game`**: Encapsulates game state (secret word, guessed letters, mistakes allowed), word masking, and win/loss rules.
- **`Hangman::SaveManager`**: Handles serialization, file writing, directory listing, loading, and deletion using JSON.
- **`Hangman::Display`**: Renders ANSI-colored boards, ASCII art gallows, banners, and game over screens.
- **`Hangman::HangmanApp`**: Controller orchestrating the main menu, game loop, input parsing, and save/load workflows.

---

## How to Play

Run the game directly with Ruby:

```bash
cd Ruby/Hangman
ruby hangman.rb
```

### Main Menu Options

1. **Start a New Game**: Begin a fresh game with a random 5–12 letter secret word.
2. **Load a Saved Game**: Browse and resume a previously saved game.
3. **How to Play**: View gameplay rules and commands.
4. **Exit**: Quit the game.

### In-Game Turn Commands

- Enter any single letter (`a`–`z`) to make a guess.
- Type `save` (or `s`) to save your game and optionally exit.
- Type `menu` (or `quit`) to return to the main menu (with an option to save before leaving).

---

## Running the Automated Tests

An automated test suite verifies dictionary filtering, game mechanics, case insensitivity, duplicate handling, win/loss conditions, JSON serialization round-tripping, file system save/load operations, and end-to-end interactive CLI simulations:

```bash
ruby test_hangman.rb
```
