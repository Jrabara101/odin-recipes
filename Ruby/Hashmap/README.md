# Project: HashMap & HashSet (The Odin Project)

This repository contains the complete implementation of the **Project: HashMap** and the **Extra Credit: HashSet** from [The Odin Project's Ruby Curriculum](https://www.theodinproject.com/lessons/ruby-hashmap).

---

## Overview

A **Hash Map** (or Hash Table) is an associative data structure that stores key-value pairs, providing $O(1)$ average-time complexity for lookups, insertions, and deletions. 

### Key Concepts Implemented:
1. **Hashing Function**: Converts string keys into deterministic integer hash codes using a polynomial rolling hash with prime number 31.
2. **Modulo Arithmetic**: Constrains hash codes into valid bucket indexes within `0...@capacity`.
3. **Collision Handling via Separate Chaining**: Resolves hash collisions by maintaining linked nodes within each bucket index without overwriting colliding entries.
4. **Boundary Checking**: Strictly enforces that bucket access stays within bounds (`0...@buckets.length`), raising an `IndexError` upon invalid access.
5. **Dynamic Resizing**: Automatically doubles bucket capacity and rehashes all stored entries when the load level exceeds the specified load factor threshold (`@size > @capacity * @load_factor`).

```text
Buckets Array (Capacity: 16, 32, ...)
[ 0 ] -> nil
[ 1 ] -> [ "elephant": "gray" ] -> nil
...
[ 11] -> [ "hat": "black" ] -> [ "grape": "purple" ] -> nil (Separate Chaining)
...
[ 15] -> [ "kite": "pink" ] -> nil
```

---

## Project Structure

```text
Ruby/Hashmap/
├── node.rb           # Node class with key, value, and next_node pointer
├── hash_map.rb       # HashMap class with separate chaining & dynamic growth
├── hash_set.rb       # Extra Credit: HashSet class storing unique keys
├── main.rb           # Walkthrough demonstration matching TOP assignment specifications
├── test_hash_map.rb  # Comprehensive Minitest suite (22 test runs, 144 assertions)
└── README.md         # Documentation & API reference
```

---

## API Reference

### 1. `Node` (`node.rb`)

Represents an entry in a bucket chain.

| Attribute | Default | Description |
|---|---|---|
| `@key` | `nil` | The key identifier. |
| `@value` | `nil` | The associated value payload. |
| `@next_node` | `nil` | Pointer to the next `Node` in the bucket collision chain. |

---

### 2. `HashMap` (`hash_map.rb`)

| Method | Time Complexity | Description |
|---|---|---|
| `HashMap.new(capacity = 16, load_factor = 0.75)` | $O(1)$ | Initializes hash map with given capacity and load factor. |
| `#hash(key)` | $O(k)$ | Produces a bucket index using polynomial hashing and modulo capacity. |
| `#raw_hash(key)` | $O(k)$ | Returns the un-moduloed integer hash code for a given key. |
| `#set(key, value)` | $O(1)$ avg / $O(n)$ worst | Inserts or updates a key-value pair. Triggers dynamic resizing if load factor is exceeded. |
| `#get(key)` | $O(1)$ avg / $O(n)$ worst | Returns the value associated with key, or `nil` if key is not found. |
| `#has?(key)` | $O(1)$ avg / $O(n)$ worst | Returns `true` if key exists, `false` otherwise. |
| `#remove(key)` | $O(1)$ avg / $O(n)$ worst | Removes the entry with key and returns its value (or `nil` if not found). |
| `#length` / `#size` | $O(1)$ | Returns the count of stored keys in the hash map. |
| `#clear` | $O(1)$ | Clears all entries from the hash map, resetting length to 0. |
| `#keys` | $O(n + c)$ | Returns an array containing all stored keys. |
| `#values` | $O(n + c)$ | Returns an array containing all stored values. |
| `#entries` | $O(n + c)$ | Returns an array of `[key, value]` pairs. |
| `#load_level` | $O(1)$ | Returns the current load level ratio (`size / capacity`). |
| `#empty?` | $O(1)$ | Returns `true` if length is 0, `false` otherwise. |
| `#check_index(index)` | $O(1)$ | Raises `IndexError` if `index < 0` or `index >= @buckets.length`. |
| `#bucket(index)` | $O(1)$ | Accesses bucket head node by index with boundary safety. |

*$k$ is the length of the string key; $n$ is the number of entries; $c$ is capacity.*

---

### 3. `HashSet` (`hash_set.rb`) — *Extra Credit*

Implements a set data structure containing unique keys without values, maintaining identical boundary restrictions and load factor resizing.

| Method | Time Complexity | Description |
|---|---|---|
| `HashSet.new(capacity = 16, load_factor = 0.75)` | $O(1)$ | Initializes set with capacity and load factor. |
| `#set(key)` / `#add(key)` | $O(1)$ avg | Adds unique key; doubles capacity when exceeding load factor. |
| `#has?(key)` / `#include?(key)` | $O(1)$ avg | Returns `true` if key is present, `false` otherwise. |
| `#remove(key)` / `#delete(key)` | $O(1)$ avg | Removes key, returning the key if found or `nil` if absent. |
| `#length` / `#size` | $O(1)$ | Returns number of elements in the set. |
| `#clear` | $O(1)$ | Empties the set. |
| `#keys` / `#entries` | $O(n + c)$ | Returns array containing all elements in the set. |
| `#load_level` | $O(1)$ | Returns current load level ratio (`size / capacity`). |
| `#empty?` | $O(1)$ | Returns `true` if set is empty. |

---

## Boundary Restriction Snippet

Per The Odin Project requirements, all bucket accesses validate index boundaries:

```ruby
raise IndexError if index.negative? || index >= @buckets.length
```

---

## Running the Demo

Execute the step-by-step walkthrough script demonstrating population, collision handling, updates, capacity doubling, and queries:

```bash
cd "Ruby/Hashmap"
ruby main.rb
```

---

## Running Tests

Run the complete Minitest test suite:

```bash
cd "Ruby/Hashmap"
ruby test_hash_map.rb
```

Sample output:
```text
Run options: --seed 35307

# Running:

......................

Finished in 0.017691s, 1243.5632 runs/s, 8139.6861 assertions/s.

22 runs, 144 assertions, 0 failures, 0 errors, 0 skips
```
