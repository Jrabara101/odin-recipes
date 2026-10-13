# Knights Travails (Ruby)

An implementation of the **Knights Travails** shortest-path graph search problem in Ruby, completed as part of [The Odin Project's Ruby Curriculum](https://www.theodinproject.com/lessons/ruby-knights-travails).

---

## Table of Contents
- [Problem Description](#problem-description)
- [Graph Representation](#graph-representation)
- [Search Algorithm: BFS vs. DFS](#search-algorithm-bfs-vs-dfs)
- [Class Architecture](#class-architecture)
  - [KnightNode](#knightnode-noderb)
  - [Board](#board-boardrb)
  - [KnightTravails](#knighttravails-knight_travailsrb)
- [API Reference](#api-reference)
- [Complexity & Board Statistics](#complexity--board-statistics)
- [Project Structure](#project-structure)
- [Running the Code](#running-the-code)
  - [Driver Script](#driver-script)
  - [Unit Tests](#unit-tests)
- [Example Output](#example-output)

---

## Problem Description

Given an 8x8 chessboard, a knight can move from any square to any other square. The knight moves in an "L" shape:
- Two squares along one axis and one square along the perpendicular axis, or
- One square along one axis and two squares along the perpendicular axis.

The goal is to implement `knight_moves(start, target)` that finds and outputs the **shortest possible path** a knight can take to travel from a starting square to an ending square on a standard chessboard.

```ruby
knight_moves([0, 0], [1, 2])
# => You made it in 1 move!  Here's your path:
#   [0, 0]
#   [1, 2]
# returns [[0, 0], [1, 2]]

knight_moves([3, 3], [4, 3])
# => You made it in 3 moves!  Here's your path:
#   [3, 3]
#   [4, 5]
#   [6, 4]
#   [4, 3]
# returns [[3, 3], [4, 5], [6, 4], [4, 3]]
```

---

## Graph Representation

In this problem, the chessboard is modeled as an **implicit, unweighted, undirected graph**:
- **Vertices ($V$):** The 64 squares on an 8x8 chessboard, represented as 2D coordinate pairs `[x, y]` where `0 <= x <= 7` and `0 <= y <= 7`.
- **Edges ($E$):** The valid L-shaped knight moves connecting adjacent reachable squares. From any given square, a knight has between 2 (in corners) and 8 (in center) possible moves that stay within the board boundary.

Because the graph is implicit, we do not need to pre-allocate an adjacency matrix or list of all 64 squares. Moves are dynamically evaluated on demand as the search expands outwards.

---

## Search Algorithm: BFS vs. DFS

| Feature | Breadth-First Search (BFS) | Depth-First Search (DFS) |
|---|---|---|
| **Shortest Path Guarantee** | **Yes** (explores uniformly by move distance) | No (may wander deep into suboptimal paths) |
| **Exploration Order** | Level-by-level (all 1-move squares, then 2-move, etc.) | Branch-first (plunges to terminal leaves) |
| **Cycle Handling** | Handled easily via a `Set` of visited squares | Requires cycle detection & backtracking |
| **Suitability for This Problem** | **Optimal choice** | Inefficient for shortest paths |

### Why Breadth-First Search (BFS)?
Because every knight move has an equal step cost of 1, finding the shortest path between any two vertices is a classic unweighted shortest-path problem. 
- BFS visits all reachable vertices at distance $d$ before any vertex at distance $d + 1$.
- The first time the queue dequeues or inspects the destination square, it is guaranteed to have found a shortest route.
- A `Set` of visited coordinates guarantees that each square is enqueued at most once, preventing cycles and infinite loops.

---

## Class Architecture

### `KnightNode` (`node.rb`)
Represents an individual vertex reached during the search.
- **Attributes**:
  - `position`: The `[x, y]` coordinate pair.
  - `parent`: Reference to the preceding `KnightNode` from which this square was reached.
  - `depth`: Integer move count from the starting square (`parent.depth + 1`).
- **Methods**:
  - `#path`: Reconstructs the complete trajectory from the root node to the current node by tracing parent references and reversing the chain.
  - `#x` and `#y`: Convenience coordinate accessors.
  - `#==`, `#eql?`, `#hash`: Position-based equality.

### `Board` (`board.rb`)
Encapsulates chessboard rules, geometry, and visualization.
- **Constants**:
  - `BOARD_SIZE`: Default 8.
  - `KNIGHT_OFFSETS`: All 8 possible move vectors `[[1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2]]`.
- **Methods**:
  - `#valid_position?(pos)`: Validates that `pos` is an Array of two integers within `(0...size)`.
  - `#possible_moves(pos)`: Calculates all legal destination squares from `pos`.
  - `#visualize_path(path)`: Renders a clean ASCII chessboard with ranks (7..0), files (0..7), start `[S]`, destination `[E]`, and numbered intermediate path squares.

### `KnightTravails` (`knight_travails.rb`)
Manages the BFS traversal algorithm and presentation.
- **Methods**:
  - `#find_path(start_pos, target_pos)`: Executes BFS with a queue and visited set. Returns the coordinate array.
  - `#knight_moves(start_pos, target_pos, display: true, visualize: false)`: Orchestrates pathfinding, prints the formatted move count and path squares, and returns the path.
  - Top-level `knight_moves` helper method for direct top-level calls.

---

## API Reference

### `knight_moves(start_pos, target_pos, display: true, visualize: false)`

Finds and displays the shortest path between two squares.

#### Arguments:
- `start_pos` (`Array<Integer>`): `[x, y]` starting square (e.g., `[0, 0]`).
- `target_pos` (`Array<Integer>`): `[x, y]` target square (e.g., `[7, 7]`).
- `display` (`Boolean`, default: `true`): Whether to print formatted move details to stdout.
- `visualize` (`Boolean`, default: `false`): Whether to print the ASCII board diagram showing the path taken.

#### Returns:
- `Array<Array<Integer>>`: An ordered array of coordinates starting at `start_pos` and ending at `target_pos`.

---

## Complexity & Board Statistics

### Computational Complexity
- **Time Complexity:** $\mathcal{O}(V + E)$ where $V = 64$ squares and $E = 336$ directed knight edges. Because the state space is bounded by an 8x8 chessboard, BFS computes any shortest path in under a fraction of a millisecond.
- **Space Complexity:** $\mathcal{O}(V)$ to store the visited set and the BFS queue (at most 64 nodes).

### 8x8 Board Graph Metrics
Analyzing all $64 \times 64 = 4,096$ possible start-to-finish square pairs reveals:
- **Graph Diameter:** **6 moves** (the maximum distance between any two squares on an 8x8 board). Only 4 pairs require 6 moves: the diagonally opposite corners `[0, 0]` $\leftrightarrow$ `[7, 7]` and `[0, 7]` $\leftrightarrow$ `[7, 0]`.
- **Average Distance:** **2.83 moves** between two randomly chosen squares.
- **Distance Distribution**:
  - 0 moves: 64 pairs (1.6%)
  - 1 move: 336 pairs (8.2%)
  - 2 moves: 1,080 pairs (26.4%)
  - 3 moves: 1,536 pairs (37.5%)
  - 4 moves: 900 pairs (22.0%)
  - 5 moves: 176 pairs (4.3%)
  - 6 moves: 4 pairs (0.1%)

---

## Project Structure

```
Knight Travails/
├── README.md               # Project documentation and specifications
├── node.rb                 # KnightNode class with parent tracking and path reconstruction
├── board.rb                # Board class with boundary checks and ASCII visualizer
├── knight_travails.rb      # BFS search algorithm and top-level helper
├── main.rb                 # Driver script showcasing all Odin Project examples and board stats
└── test_knight_travails.rb # Comprehensive Minitest test suite (30 test runs, 1,244 assertions)
```

---

## Running the Code

### Driver Script
Run the driver script to see the path demonstrations, ASCII visualizations, random routes, and graph metrics:
```bash
ruby main.rb
```

### Unit Tests
Run the automated test suite using Ruby's built-in `minitest`:
```bash
ruby test_knight_travails.rb
```

---

## Example Output

```text
>> knight_moves([3, 3], [4, 3], visualize: true)
You made it in 3 moves!  Here's your path:
  [3, 3]
  [4, 5]
  [6, 4]
  [4, 3]

   y (rank)
 7 |  .   .   .   .   .   .   .   .  |
 6 |  .   .   .   .   .   .   .   .  |
 5 |  .   .   .   .   1   .   .   .  |
 4 |  .   .   .   .   .   .   2   .  |
 3 |  .   .   .  [S] [3]  .   .   .  |
 2 |  .   .   .   .   .   .   .   .  |
 1 |  .   .   .   .   .   .   .   .  |
 0 |  .   .   .   .   .   .   .   .  |
   +---------------------------------+
       0   1   2   3   4   5   6   7    x (file)

   Legend: [S] = Start ([3, 3]), [3] = Target ([4, 3]), numbers = intermediate steps
```
