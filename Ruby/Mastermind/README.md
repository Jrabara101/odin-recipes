# Mastermind (Ruby OOP)

A command-line implementation of the classic code-breaking game **Mastermind** from [The Odin Project's Ruby Course](https://www.theodinproject.com/lessons/ruby-mastermind).

## Features

- **Two Game Modes**:
  1. **Codebreaker (Guesser)**: The computer selects a random 4-color secret code and you have 12 turns to deduce it using feedback clues.
  2. **Codemaker (Creator)**: You create a secret 4-color code and watch an AI algorithm solve it turn-by-turn.
- **Intelligent AI Solver**:
  - Implements a Consistent-Candidate Elimination strategy inspired by Donald Knuth's Mastermind algorithm.
  - Starts with an information-rich opening move (`Red Red Green Green`), then evaluates feedback to systematically prune the 1,296 candidate pool down to the exact code in 4–6 turns.
- **Flexible Input System**:
  - Enter guesses using numbers (`1 2 3 4` or `1234`).
  - Enter guesses using color initials (`r g b y` or `rgby`).
  - Enter guesses using full names (`Red Green Blue Yellow`).
- **Standard Mastermind Scoring**:
  - Accurately tracks exact matches (`●`) and near/color matches (`○`) without double-counting duplicate pegs.

---

## Available Colors

| Number | Letter | Color Name |
| :---: | :---: | :--- |
| `1` | `R` | **Red** |
| `2` | `G` | **Green** |
| `3` | `B` | **Blue** |
| `4` | `Y` | **Yellow** |
| `5` | `P` | **Purple** |
| `6` | `O` | **Orange** |

---

## How to Play

Run the game directly with Ruby:

```bash
ruby mastermind.rb
```

### Feedback Pegs
- **`●` (Exact Match)**: A peg has both the correct color and is in the correct position.
- **`○` (Near Match)**: A peg has the correct color, but is in the wrong position.
- **`-` (No Match)**: The peg color does not correspond to any remaining unmatched peg in the code.

---

## Running the Automated Tests

An automated test suite verifies all color parsing methods, duplicate feedback scoring edge cases, AI solver convergence, and complete simulated games:

```bash
ruby test_mastermind.rb
```
