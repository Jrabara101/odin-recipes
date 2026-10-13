# Project: Linked Lists (The Odin Project)

This repository contains the complete implementation of the **Project: Linked Lists** from [The Odin Project's Ruby Curriculum](https://www.theodinproject.com/lessons/ruby-linked-lists).

---

## Overview

A **Linked List** is a fundamental linear data structure consisting of nodes where each node contains a value and a reference (pointer) to the next node in sequence. Unlike arrays, nodes are not stored in contiguous memory locations, allowing dynamic insertions and deletions without reallocating or shifting elements in memory.

```text
[ NODE (head) ] -> [ NODE ] -> [ NODE (tail) ] -> nil
```

---

## Project Structure

```text
Ruby/Linked Lists/
├── node.rb              # Node class containing @value and @next_node
├── linked_list.rb       # LinkedList class implementing all list operations & Enumerable
├── main.rb              # Interactive demonstration script following TOP assignment specs
├── test_linked_list.rb  # Minitest test suite (25 test cases, 94 assertions)
└── README.md            # Documentation and method reference
```

---

## Classes & API Reference

### 1. `Node` (`node.rb`)

Represents an individual node in the list.

| Attribute | Default | Description |
|---|---|---|
| `@value` | `nil` | The payload or data stored in the node. |
| `@next_node` | `nil` | Reference to the subsequent node in the list. |

```ruby
node = Node.new('cat')
node.value      # => 'cat'
node.next_node  # => nil
```

---

### 2. `LinkedList` (`linked_list.rb`)

Represents the full list data structure. Includes Ruby's `Enumerable` module.

| Method | Time Complexity | Description |
|---|---|---|
| `#append(value)` | $O(1)$ | Appends a new node containing `value` to the end of the list. Returns `self` for chaining. |
| `#prepend(value)` | $O(1)$ | Adds a new node containing `value` to the start of the list. Returns `self` for chaining. |
| `#size` | $O(1)$ | Returns the total count of nodes in the list. |
| `#head` | $O(1)$ | Returns the value of the first node in the list, or `nil` if the list is empty. |
| `#tail` | $O(1)$ | Returns the value of the final node in the list, or `nil` if the list is empty. |
| `#head_node` | $O(1)$ | Returns the actual `Node` object at the head (or `nil`). |
| `#tail_node` | $O(1)$ | Returns the actual `Node` object at the tail (or `nil`). |
| `#at(index)` | $O(n)$ | Returns the value of the node at 0-based `index`. Returns `nil` if out of bounds. |
| `#node_at(index)` | $O(n)$ | Returns the `Node` object at 0-based `index`, or `nil` if out of bounds. |
| `#pop` | $O(1)$ | Removes the head node from the list and returns its value. Returns `nil` on an empty list. |
| `#contains?(value)` | $O(n)$ | Returns `true` if `value` exists in the list, otherwise `false`. (Aliased as `#include?`). |
| `#index(value)` | $O(n)$ | Returns the 0-based index of the first node matching `value`, or `nil` if not found. (Aliased as `#find_index`). |
| `#to_s` | $O(n)$ | Returns formatted string: `( value ) -> ( value ) -> nil`. Returns `""` if empty. |
| `#empty?` | $O(1)$ | Returns `true` if the list has zero elements. |

#### Extra Credit Methods

| Method | Time Complexity | Description |
|---|---|---|
| `#insert_at(index, *values)` | $O(k + n)$ | Inserts one or more nodes with the specified `values` at the given `index` (0-based). Raises `IndexError` if `index < 0` or `index > size`. |
| `#remove_at(index)` | $O(n)$ | Removes the node at the specified `index` (0-based) and returns its value. Raises `IndexError` if `index < 0` or `index >= size`. |

---

## Usage Examples

### Basic Setup & Display

```ruby
require_relative 'linked_list'

list = LinkedList.new
list.append('dog')
list.append('cat')
list.append('parrot')
list.append('hamster')
list.append('snake')
list.append('turtle')

puts list
# => ( dog ) -> ( cat ) -> ( parrot ) -> ( hamster ) -> ( snake ) -> ( turtle ) -> nil
```

### Insertion and Deletion

```ruby
# Prepend
list.prepend('wolf')
# => ( wolf ) -> ( dog ) -> ( cat ) -> ... -> nil

# Pop (removes head node)
popped = list.pop # => 'wolf'

# Extra Credit: insert_at
numbers = LinkedList.new.append(1).append(2).append(3)
numbers.insert_at(1, 10, 11)
puts numbers
# => ( 1 ) -> ( 10 ) -> ( 11 ) -> ( 2 ) -> ( 3 ) -> nil

# Extra Credit: remove_at
numbers.remove_at(1) # removes 10
puts numbers
# => ( 1 ) -> ( 11 ) -> ( 2 ) -> ( 3 ) -> nil
```

### Enumerable Integration

Because `LinkedList` includes `Enumerable` and implements `#each`, all standard iteration and collection methods are supported:

```ruby
names = LinkedList.new.append('alice').append('bob').append('charlie')

# Mapping
names.map(&:capitalize)
# => ["Alice", "Bob", "Charlie"]

# Filtering
names.select { |name| name.start_with?('b') }
# => ["bob"]
```

---

## Running the Code

### 1. Run the Demonstration (`main.rb`)

```bash
ruby main.rb
```

### 2. Run the Test Suite (`test_linked_list.rb`)

```bash
ruby test_linked_list.rb
```
