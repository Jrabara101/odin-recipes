# frozen_string_literal: true

require 'stringio'

# The Odin Project - Project: Recursion
# Part 1: Fibonacci Sequence

# Iterative solution:
# Takes an integer n and returns an array containing the first n numbers
# of the Fibonacci sequence.
def fibs(n)
  return [] if n <= 0
  return [0] if n == 1

  sequence = [0, 1]
  (n - 2).times do
    sequence << sequence[-1] + sequence[-2]
  end
  sequence
end

# Recursive solution:
# Solves the same problem recursively.
# Each call reduces n by 1 until the base case is reached,
# then appends the next Fibonacci number as the call stack unwinds.
def fibs_rec(n)
  puts 'This was printed recursively'
  return [] if n <= 0
  return [0] if n == 1
  return [0, 1] if n == 2

  sequence = fibs_rec(n - 1)
  sequence << sequence[-1] + sequence[-2]
end

# Demonstrations and test cases
if __FILE__ == $PROGRAM_NAME
  puts '=== Fibonacci: Iterative vs Recursive ==='
  puts

  puts '--- Testing #fibs (Iterative) with various lengths ---'
  [-1, 0, 1, 2, 3, 5, 8, 12].each do |n|
    puts "fibs(#{n.to_s.rjust(2)})  => #{fibs(n).inspect}"
  end
  puts

  puts '--- Testing #fibs_rec (Recursive) with input 8 ---'
  puts 'Notice the recursive calls printed below:'
  result_rec_8 = fibs_rec(8)
  puts "Result of fibs_rec(8): #{result_rec_8.inspect}"
  puts "Expected:             [0, 1, 1, 2, 3, 5, 8, 13]"
  puts "Matches expected:     #{result_rec_8 == [0, 1, 1, 2, 3, 5, 8, 13]}"
  puts

  puts '--- Comparing #fibs and #fibs_rec outputs ---'
  [0, 1, 2, 3, 5, 8, 10].each do |n|
    # Suppress recursion log for side-by-side comparison output clarity
    # (testing equivalence)
    iter = fibs(n)
    # Redirect stdout temporarily to check value equality cleanly
    orig_stdout = $stdout
    $stdout = StringIO.new
    rec = fibs_rec(n)
    $stdout = orig_stdout

    match = (iter == rec)
    puts "n = #{n.to_s.rjust(2)} | iter: #{iter.inspect.ljust(35)} | rec: #{rec.inspect.ljust(35)} | Match: #{match}"
  end
end
