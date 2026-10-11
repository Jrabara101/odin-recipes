# frozen_string_literal: true

# The Odin Project - Project: Recursion
# Part 2: Merge Sort

# Recursively sorts an array of comparable elements using the merge sort algorithm.
# Time Complexity: O(n log n)
# Space Complexity: O(n)
def merge_sort(array)
  return [] if array.nil?
  return array.dup if array.length <= 1

  # Divide: Find midpoint and recursively sort both halves
  mid = array.length / 2
  left_sorted = merge_sort(array[0...mid])
  right_sorted = merge_sort(array[mid..])

  # Conquer / Combine: Merge sorted halves
  merge(left_sorted, right_sorted)
end

# Merges two sorted arrays into a single sorted array in O(n) time.
def merge(left, right)
  merged = []
  left_idx = 0
  right_idx = 0

  while left_idx < left.length && right_idx < right.length
    if left[left_idx] <= right[right_idx]
      merged << left[left_idx]
      left_idx += 1
    else
      merged << right[right_idx]
      right_idx += 1
    end
  end

  # Append any remaining elements
  merged.concat(left[left_idx..]) if left_idx < left.length
  merged.concat(right[right_idx..]) if right_idx < right.length

  merged
end

# Demonstrations and test cases from The Odin Project
if __FILE__ == $PROGRAM_NAME
  puts '=== Merge Sort Demonstration ==='
  puts

  test_cases = [
    { input: [], expected: [] },
    { input: [73], expected: [73] },
    { input: [1, 2, 3, 4, 5], expected: [1, 2, 3, 4, 5] },
    { input: [3, 2, 1, 13, 8, 5, 0, 1], expected: [0, 1, 1, 2, 3, 5, 8, 13] },
    { input: [105, 79, 100, 110], expected: [79, 100, 105, 110] },
    { input: [-5, 20, 0, -100, 42, -5], expected: [-100, -5, -5, 0, 20, 42] }
  ]

  all_passed = true

  test_cases.each_with_index do |test, index|
    input_copy = test[:input].dup
    result = merge_sort(test[:input])
    passed = (result == test[:expected])
    all_passed &&= passed

    puts "Test #{index + 1}:"
    puts "  Input:    #{test[:input].inspect}"
    puts "  Result:   #{result.inspect}"
    puts "  Expected: #{test[:expected].inspect}"
    puts "  Passed?   #{passed}"
    puts "  Preserved original array? #{test[:input] == input_copy}"
    puts
  end

  puts '--- Random Array Stress Test (1000 elements) ---'
  random_array = Array.new(1000) { rand(-10_000..10_000) }
  expected_sorted = random_array.sort
  merge_sorted = merge_sort(random_array)
  stress_passed = (merge_sorted == expected_sorted)
  puts "Random test (1000 elements) matches Ruby's #sort: #{stress_passed}"
  all_passed &&= stress_passed
  puts

  puts "Overall Status: #{all_passed ? 'ALL TESTS PASSED' : 'SOME TESTS FAILED'}"
end
