def bubble_sort(array)
  return [] if array.nil?
  return array.dup if array.length <= 1

  sorted_array = array.dup
  n = sorted_array.length

  # Outer loop for each pass
  (0...(n - 1)).each do |i|
    swapped = false

    # Inner loop compares adjacent elements;
    # with each pass, the largest remaining element bubbles up to the end
    (0...(n - 1 - i)).each do |j|
      if sorted_array[j] > sorted_array[j + 1]
        sorted_array[j], sorted_array[j + 1] = sorted_array[j + 1], sorted_array[j]
        swapped = true
      end
    end

    # If no elements were swapped on this pass, the array is already sorted
    break unless swapped
  end

  sorted_array
end

# Tests and examples from The Odin Project
if __FILE__ == $PROGRAM_NAME
  puts "--- Test 1: The Odin Project Example ---"
  input1 = [4, 3, 78, 2, 0, 2]
  result1 = bubble_sort(input1)
  puts "Input:    #{input1.inspect}"
  puts "Result:   #{result1.inspect}"
  puts "Expected: [0, 2, 2, 3, 4, 78]"
  puts "Matches:  #{result1 == [0, 2, 2, 3, 4, 78]}"
  puts "Original preserved: #{input1 == [4, 3, 78, 2, 0, 2]}"
  puts

  puts "--- Test 2: Already Sorted Array (Early Exit) ---"
  input2 = [1, 2, 3, 4, 5]
  result2 = bubble_sort(input2)
  puts "Input:    #{input2.inspect}"
  puts "Result:   #{result2.inspect}"
  puts "Expected: [1, 2, 3, 4, 5]"
  puts "Matches:  #{result2 == [1, 2, 3, 4, 5]}"
  puts

  puts "--- Test 3: Reverse Sorted Array ---"
  input3 = [9, 7, 5, 3, 1]
  result3 = bubble_sort(input3)
  puts "Input:    #{input3.inspect}"
  puts "Result:   #{result3.inspect}"
  puts "Expected: [1, 3, 5, 7, 9]"
  puts "Matches:  #{result3 == [1, 3, 5, 7, 9]}"
  puts

  puts "--- Test 4: Negative Numbers and Duplicates ---"
  input4 = [-2, 45, 0, 11, -9, 0, -2]
  result4 = bubble_sort(input4)
  puts "Input:    #{input4.inspect}"
  puts "Result:   #{result4.inspect}"
  puts "Expected: [-9, -2, -2, 0, 0, 11, 45]"
  puts "Matches:  #{result4 == [-9, -2, -2, 0, 0, 11, 45]}"
  puts

  puts "--- Test 5: Single Element and Empty Array ---"
  puts "Empty:  #{bubble_sort([]).inspect} (Expected: [])"
  puts "Single: #{bubble_sort([42]).inspect} (Expected: [42])"
end
