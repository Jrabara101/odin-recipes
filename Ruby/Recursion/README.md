# Project: Recursion (The Odin Project)

This repository contains solutions for the **Project: Recursion** from [The Odin Project's Ruby Curriculum](https://www.theodinproject.com/lessons/ruby-recursion).

---

## 1. Fibonacci Sequence (`fibonacci.rb`)

The Fibonacci sequence is defined such that each number is the sum of the two preceding numbers:  
`0, 1, 1, 2, 3, 5, 8, 13, 21, ...`

### Implementations

1. **Iterative (`#fibs`)**:
   - Takes an integer `n` and returns an array containing the first `n` numbers of the Fibonacci sequence.
   - Computes each subsequent number iteratively in a loop.
   - Time Complexity: $O(n)$, Space Complexity: $O(n)$.

2. **Recursive (`#fibs_rec`)**:
   - Computes the sequence recursively by delegating subproblems (`n - 1`) until reaching the base cases (`n <= 0`, `n == 1`, `n == 2`).
   - Appends the next Fibonacci number (`seq[-1] + seq[-2]`) on unwinding the call stack.
   - Includes `puts 'This was printed recursively'` at the start to demonstrate the recursive call stack.

### Running Fibonacci

```bash
ruby fibonacci.rb
```

---

## 2. Merge Sort (`merge_sort.rb`)

Merge Sort is a classic divide-and-conquer sorting algorithm.

### How it Works

1. **Base Case**: An array with `0` or `1` element is already sorted.
2. **Divide**: Split the array into two halves at the midpoint.
3. **Conquer**: Recursively call `merge_sort` on each half.
4. **Combine**: Merge the two sorted halves back together into a single sorted array.

### Complexity

- **Time Complexity**: $O(n \log n)$ in worst, average, and best cases.
- **Space Complexity**: $O(n)$ auxiliary space.

### Test Cases Covered

- Empty array: `[]` $\rightarrow$ `[]`
- Single element: `[73]` $\rightarrow$ `[73]`
- Already sorted: `[1, 2, 3, 4, 5]` $\rightarrow$ `[1, 2, 3, 4, 5]`
- Given example: `[3, 2, 1, 13, 8, 5, 0, 1]` $\rightarrow$ `[0, 1, 1, 2, 3, 5, 8, 13]`
- Given example: `[105, 79, 100, 110]` $\rightarrow$ `[79, 100, 105, 110]`
- Negative numbers and duplicates: `[-5, 20, 0, -100, 42, -5]` $\rightarrow$ `[-100, -5, -5, 0, 20, 42]`
- 1,000-element randomized stress test validated against Ruby's native `#sort`.

### Running Merge Sort

```bash
ruby merge_sort.rb
```
