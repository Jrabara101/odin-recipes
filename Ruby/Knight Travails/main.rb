# frozen_string_literal: true

require_relative 'knight_travails'

def print_header(title)
  puts "\n#{'=' * 72}"
  puts "  #{title}"
  puts "#{'=' * 72}\n"
end

def print_section(title)
  puts "\n#{'-' * 60}"
  puts ">> #{title}"
  puts "#{'-' * 60}"
end

print_header('THE ODIN PROJECT: KNIGHT TRAVAILS DRIVER SCRIPT')

# 1. Immediate move (1 move)
print_section('Example 1: Single move [0, 0] -> [1, 2]')
knight_moves([0, 0], [1, 2], display: true, visualize: true)

# 2. Two moves [0, 0] -> [3, 3]
print_section('Example 2: Two moves [0, 0] -> [3, 3]')
knight_moves([0, 0], [3, 3], display: true, visualize: true)

# 3. Two moves in reverse [3, 3] -> [0, 0]
print_section('Example 3: Reverse two moves [3, 3] -> [0, 0]')
knight_moves([3, 3], [0, 0], display: true)

# 4. Three moves [3, 3] -> [4, 3] (Official TOP Assignment Example)
print_section('Example 4: Assignment sample [3, 3] -> [4, 3]')
knight_moves([3, 3], [4, 3], display: true, visualize: true)

# 5. Corner to opposite corner [0, 0] -> [7, 7] (Maximum distance = 6 moves)
print_section('Example 5: Corner to opposite corner [0, 0] -> [7, 7]')
knight_moves([0, 0], [7, 7], display: true, visualize: true)

# 6. Same square edge case [4, 4] -> [4, 4] (0 moves)
print_section('Example 6: Zero moves [4, 4] -> [4, 4]')
knight_moves([4, 4], [4, 4], display: true)

# 7. Adjacent square [0, 0] -> [0, 1] (Requires 3 moves due to knight geometry)
print_section('Example 7: Adjacent square [0, 0] -> [0, 1]')
knight_moves([0, 0], [0, 1], display: true, visualize: true)

# 8. Random Knight Quest
print_section('Example 8: Random Knight Quest')
start_rand = [rand(0..7), rand(0..7)]
target_rand = [rand(0..7), rand(0..7)]
puts "Searching random route: #{start_rand.inspect} to #{target_rand.inspect}..."
knight_moves(start_rand, target_rand, display: true, visualize: true)

# 9. Graph Analysis: Full Board Statistics
print_section('Example 9: Full 8x8 Board Graph Diameter Analysis')
travails = KnightTravails.new
all_distances = []
max_dist = 0
furthest_pair = nil

(0..7).each do |x1|
  (0..7).each do |y1|
    start = [x1, y1]
    (0..7).each do |x2|
      (0..7).each do |y2|
        target = [x2, y2]
        dist = travails.find_path(start, target).length - 1
        all_distances << dist
        if dist > max_dist
          max_dist = dist
          furthest_pair = [start, target]
        end
      end
    end
  end
end

avg_dist = (all_distances.sum.to_f / all_distances.size).round(2)
distribution = all_distances.tally.sort.to_h

puts "Total square pairs analyzed: #{all_distances.size} (64 x 64)"
puts "Graph Diameter (Max moves needed): #{max_dist} moves (e.g. #{furthest_pair[0].inspect} to #{furthest_pair[1].inspect})"
puts "Average moves between any two random squares: #{avg_dist} moves"
puts 'Move count distribution across all 4,096 pairs:'
distribution.each do |moves, count|
  percentage = ((count.to_f / all_distances.size) * 100).round(1)
  bar = '#' * (percentage / 2).round
  puts format('  %d moves: %5d pairs (%5.1f%%) %s', moves, count, percentage, bar)
end

puts "\n#{'=' * 72}"
puts '  Knight Travails demonstrations completed successfully!'
puts "#{'=' * 72}\n"
