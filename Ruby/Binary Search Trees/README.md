# Binary Search Trees (Ruby)

An implementation of a self-balancing **Binary Search Tree (BST)** in Ruby, completed as part of [The Odin Project's Ruby Curriculum](https://www.theodinproject.com/lessons/ruby-binary-search-trees).

---

## Table of Contents
- [Overview](#overview)
- [Class Architecture](#class-architecture)
  - [Node](#node)
  - [Tree](#tree)
- [API Reference](#api-reference)
  - [Tree Construction & Visualization](#tree-construction--visualization)
  - [Search & Querying](#search--querying)
  - [Insertion & Deletion](#insertion--deletion)
  - [Tree Traversals](#tree-traversals)
  - [Tree Metrics & Balance](#tree-metrics--balance)
- [Complexity Analysis](#complexity-analysis)
- [Project Structure](#project-structure)
- [Running the Code](#running-the-code)
  - [Driver Script](#driver-script)
  - [Unit Tests](#unit-tests)

---

## Overview

A **Binary Search Tree** is a hierarchical node-based data structure where each node satisfies the BST invariant:
- All values in the node's **left** subtree are **strictly less** than the node's value.
- All values in the node's **right** subtree are **strictly greater** than the node's value.
- Duplicate values are disallowed.

A **Balanced BST** guarantees that the depth of the tree remains logarithmic with respect to the number of nodes ($O(\log n)$), ensuring fast lookups, insertions, and deletions.

---

## Class Architecture

### Node (`node.rb`)
Represents an individual tree node.

- **Attributes**:
  - `data`: Stored value.
  - `left`: Pointer to the left child `Node` (or `nil`).
  - `right`: Pointer to the right child `Node` (or `nil`).
- **Comparable**: Includes Ruby's `Comparable` module, comparing nodes based on `data`.
- **Helpers**:
  - `leaf?`: Returns `true` if node has no children.
  - `one_child?`: Returns `true` if node has exactly one child.
  - `two_children?`: Returns `true` if node has both left and right children.
  - `only_child`: Returns the single child node if present.

### Tree (`tree.rb`)
Manages the root node and overall tree structure.

- Initialized with an array of values: `Tree.new(array)`.
- Automatically sorts and removes duplicates to build a balanced level-0 root node.

---

## API Reference

### Tree Construction & Visualization

| Method | Description |
|---|---|
| `Tree.new(array)` | Initializes tree by passing `array` to `#build_tree`. |
| `build_tree(array)` | Cleans, sorts, and recursively creates a balanced BST. Returns root `Node`. |
| `pretty_print(node = @root)` | Visually outputs the tree in the terminal using ASCII connectors. |

#### Visual Representation Example
```
│               ┌── 185
│           ┌── 160
│       ┌── 140
│       │   │   ┌── 120
│       │   └── 105
│   ┌── 93
│   │   │       ┌── 83
│   │   │   ┌── 72
│   │   └── 69
│   │       └── 60
└── 59
    │           ┌── 54
    │       ┌── 49
    │   ┌── 46
    │   │   └── 44
    └── 41
        │       ┌── 25
        │   ┌── 24
        └── 17
            └── 10
```

---

### Search & Querying

| Method | Return Type | Description |
|---|---|---|
| `include?(value)` | `Boolean` | Returns `true` if `value` exists in the tree, otherwise `false`. |
| `find(value)` | `Node` / `nil` | Traverses down the tree and returns the node matching `value`. |
| `min` | `Object` / `nil` | Returns the minimum value in the tree ($O(\log n)$). |
| `max` | `Object` / `nil` | Returns the maximum value in the tree ($O(\log n)$). |
| `size` | `Integer` | Returns total number of nodes in the tree. |
| `empty?` | `Boolean` | Returns `true` if the tree has no nodes. |

---

### Insertion & Deletion

#### `insert(value)`
- Traverses the tree and inserts a new `Node` at the appropriate leaf position.
- If `value` already exists, no operation is performed (duplicates ignored).
- Modifies tree pointers directly without reallocating arrays.

#### `delete(value)`
Removes the node containing `value` while preserving the BST property:
1. **Case 1: Leaf Node** (0 children) &rarr; Simply remove node by setting parent's reference to `nil`.
2. **Case 2: One Child** &rarr; Replaces the node with its non-nil child.
3. **Case 3: Two Children** &rarr; Finds the node's **in-order successor** (smallest node in right subtree), replaces node's data with successor's data, and deletes successor from right subtree.

---

### Tree Traversals

All traversal methods support both **block iteration** (returning `self`) and **external enumeration** (returning an `Enumerator` when no block is provided):

```ruby
# Yield each value to a block:
tree.inorder { |val| puts val }

# Or retrieve an array using the Enumerator:
sorted = tree.inorder.to_a
```

| Traversal | Order | Description |
|---|---|---|
| `level_order` | Breadth-First | Traverses level-by-level from top to bottom using a FIFO queue. |
| `level_order_recursive` | Breadth-First | Alternative recursive implementation of level-order traversal. |
| `inorder` | Depth-First ($L \rightarrow Root \rightarrow R$) | Visits elements in ascending sorted order. |
| `preorder` | Depth-First ($Root \rightarrow L \rightarrow R$) | Visits root first, useful for cloning/serializing trees. |
| `postorder` | Depth-First ($L \rightarrow R \rightarrow Root$) | Visits children before root, useful for bottom-up operations. |

---

### Tree Metrics & Balance

#### `height(value_or_node = @root)`
- Returns the height of the node containing `value` (number of edges on longest downward path to a leaf).
- Leaf nodes have a height of `0`.
- Returns `nil` if the value is not present in the tree.

#### `depth(value_or_node)`
- Returns the depth of the node containing `value` (number of edges from the tree's root to that node).
- Root node has a depth of `0`.
- Returns `nil` if the value is not present in the tree.

#### `balanced?`
- Checks whether the tree satisfies the balanced condition:
  - For **every** node in the tree, the height difference between left and right subtrees is at most 1: $|h_{left} - h_{right}| \le 1$.
  - Both left and right subtrees must also be balanced.

#### `rebalance`
- Traverses the existing tree in-order to obtain sorted unique values.
- Reconstructs a balanced tree using `#build_tree` and updates `@root`.

---

## Complexity Analysis

| Operation | Balanced Tree (Average) | Degenerate Tree (Worst-Case) |
|---|---|---|
| Search (`#find`, `#include?`) | $O(\log n)$ | $O(n)$ |
| Insertion (`#insert`) | $O(\log n)$ | $O(n)$ |
| Deletion (`#delete`) | $O(\log n)$ | $O(n)$ |
| Height / Depth Calculation | $O(n)$ / $O(\log n)$ | $O(n)$ |
| Traversals (`#inorder`, etc.) | $O(n)$ | $O(n)$ |
| Rebalancing (`#rebalance`) | $O(n)$ | $O(n)$ |

---

## Project Structure

```
Ruby/Binary Search Trees/
├── node.rb         # Node class definition with Comparable & helper methods
├── tree.rb         # Tree class with build_tree, traversals, modifications, balance
├── main.rb         # Driver script demonstrating all required TOP steps
├── test_tree.rb    # Comprehensive unit tests using Minitest
└── README.md       # Project documentation
```

---

## Running the Code

### Driver Script
Executes the assignment's complete scenario (builds random tree, checks balance, prints traversals, unbalances, rebalances, and re-checks):

```bash
ruby main.rb
```

### Unit Tests
Executes the full automated test suite:

```bash
ruby test_tree.rb
```
