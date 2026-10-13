# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require_relative 'node'
require_relative 'board'
require_relative 'knight_travails'

class NodeTest < Minitest::Test
  def setup
    @root = KnightNode.new([0, 0])
  end

  def test_initialization
    assert_equal [0, 0], @root.position
    assert_nil @root.parent
    assert_equal 0, @root.depth
    assert_equal 0, @root.x
    assert_equal 0, @root.y
  end

  def test_child_node_depth_and_parent
    child = KnightNode.new([1, 2], @root)
    grandchild = KnightNode.new([3, 3], child)

    assert_equal @root, child.parent
    assert_equal 1, child.depth
    assert_equal child, grandchild.parent
    assert_equal 2, grandchild.depth
  end

  def test_root_path_reconstruction
    assert_equal [[0, 0]], @root.path
  end

  def test_multi_step_path_reconstruction
    step1 = KnightNode.new([1, 2], @root)
    step2 = KnightNode.new([3, 3], step1)
    step3 = KnightNode.new([4, 5], step2)

    expected_path = [[0, 0], [1, 2], [3, 3], [4, 5]]
    assert_equal expected_path, step3.path
  end

  def test_equality_and_hash
    node_a = KnightNode.new([2, 3])
    node_b = KnightNode.new([2, 3])
    node_c = KnightNode.new([4, 4])

    assert_equal node_a, node_b
    refute_equal node_a, node_c
    assert_equal node_a.hash, node_b.hash
  end

  def test_string_representations
    node = KnightNode.new([3, 4])
    assert_equal '[3, 4]', node.to_s
    assert_includes node.inspect, 'KnightNode(pos: [3, 4], depth: 0)'
  end
end

class BoardTest < Minitest::Test
  def setup
    @board = Board.new
  end

  def test_default_board_size
    assert_equal 8, @board.size
  end

  def test_valid_positions
    assert @board.valid_position?([0, 0])
    assert @board.valid_position?([7, 7])
    assert @board.valid_position?([3, 4])
    assert @board.valid_position?([0, 7])
    assert @board.valid_position?([7, 0])
  end

  def test_invalid_positions
    refute @board.valid_position?([-1, 0])
    refute @board.valid_position?([0, -1])
    refute @board.valid_position?([8, 0])
    refute @board.valid_position?([0, 8])
    refute @board.valid_position?([10, 10])
    refute @board.valid_position?([1])
    refute @board.valid_position?([1, 2, 3])
    refute @board.valid_position?(nil)
    refute @board.valid_position?('a')
    refute @board.valid_position?([1.5, 2])
    refute @board.valid_position?(['0', '0'])
  end

  def test_corner_moves
    moves = @board.possible_moves([0, 0])
    assert_equal 2, moves.length
    assert_includes moves, [1, 2]
    assert_includes moves, [2, 1]
  end

  def test_edge_moves
    moves = @board.possible_moves([0, 4])
    assert_equal 4, moves.length
    assert_includes moves, [1, 6]
    assert_includes moves, [2, 5]
    assert_includes moves, [2, 3]
    assert_includes moves, [1, 2]
  end

  def test_center_moves
    moves = @board.possible_moves([3, 3])
    assert_equal 8, moves.length
    expected = [
      [4, 5], [5, 4], [5, 2], [4, 1],
      [2, 1], [1, 2], [1, 4], [2, 5]
    ]
    expected.each { |m| assert_includes moves, m }
  end

  def test_all_generated_moves_are_within_board
    (0..7).each do |x|
      (0..7).each do |y|
        moves = @board.possible_moves([x, y])
        moves.each do |move|
          assert @board.valid_position?(move), "Move #{move.inspect} from #{[x, y].inspect} is out of bounds!"
        end
      end
    end
  end

  def test_invalid_position_raises_argument_error
    assert_raises(ArgumentError) { @board.possible_moves([-1, 5]) }
  end

  def test_visualize_path_renders_expected_legend_and_steps
    path = [[0, 0], [1, 2], [3, 3]]
    output = @board.visualize_path(path)
    assert_includes output, '[S]'
    assert_includes output, '[2]'
    assert_includes output, ' 1 '
    assert_includes output, 'Legend:'
  end
end

class KnightTravailsTest < Minitest::Test
  def setup
    @travails = KnightTravails.new
    @board = @travails.board
  end

  # Helper: asserts that every adjacent step in path is a legal knight move
  def assert_valid_knight_path(path, expected_start, expected_target)
    assert_equal expected_start, path.first, "Path start #{path.first.inspect} does not match #{expected_start.inspect}"
    assert_equal expected_target, path.last, "Path end #{path.last.inspect} does not match #{expected_target.inspect}"

    (0...(path.length - 1)).each do |i|
      from = path[i]
      to = path[i + 1]
      legal_moves = @board.possible_moves(from)
      assert_includes legal_moves, to, "Move from #{from.inspect} to #{to.inspect} is not a valid knight move!"
    end
  end

  def test_zero_moves_when_start_equals_target
    path = @travails.find_path([0, 0], [0, 0])
    assert_equal [[0, 0]], path
    assert_equal 0, path.length - 1
  end

  def test_one_move_path
    path = @travails.find_path([0, 0], [1, 2])
    assert_equal [[0, 0], [1, 2]], path
    assert_equal 1, path.length - 1
    assert_valid_knight_path(path, [0, 0], [1, 2])
  end

  def test_all_immediate_knight_moves_from_center
    start = [3, 3]
    @board.possible_moves(start).each do |target|
      path = @travails.find_path(start, target)
      assert_equal 2, path.length
      assert_equal [start, target], path
      assert_valid_knight_path(path, start, target)
    end
  end

  def test_two_moves_path_from_origin_to_3_3
    path = @travails.find_path([0, 0], [3, 3])
    assert_equal 3, path.length # 2 moves
    assert_valid_knight_path(path, [0, 0], [3, 3])

    # Possible valid shortest paths: [[0,0],[2,1],[3,3]] or [[0,0],[1,2],[3,3]]
    valid_paths = [
      [[0, 0], [2, 1], [3, 3]],
      [[0, 0], [1, 2], [3, 3]]
    ]
    assert_includes valid_paths, path
  end

  def test_reverse_two_moves_path_from_3_3_to_0_0
    path = @travails.find_path([3, 3], [0, 0])
    assert_equal 3, path.length # 2 moves
    assert_valid_knight_path(path, [3, 3], [0, 0])
  end

  def test_three_moves_path_assignment_example
    # TOP example: knight_moves([3,3],[4,3]) => 3 moves
    path = @travails.find_path([3, 3], [4, 3])
    assert_equal 4, path.length # 3 moves
    assert_valid_knight_path(path, [3, 3], [4, 3])
  end

  def test_corner_to_opposite_corner_max_distance
    # [0, 0] to [7, 7] requires 6 moves
    path = @travails.find_path([0, 0], [7, 7])
    assert_equal 7, path.length # 6 moves
    assert_valid_knight_path(path, [0, 0], [7, 7])
  end

  def test_opposite_diagonal_corners
    path = @travails.find_path([0, 7], [7, 0])
    assert_equal 7, path.length # 6 moves
    assert_valid_knight_path(path, [0, 7], [7, 0])
  end

  def test_adjacent_square_requires_three_moves
    # [0, 0] to [0, 1] is adjacent, which takes exactly 3 knight moves
    path = @travails.find_path([0, 0], [0, 1])
    assert_equal 4, path.length # 3 moves
    assert_valid_knight_path(path, [0, 0], [0, 1])
  end

  def test_all_64_squares_are_reachable_from_corner
    start = [0, 0]
    (0..7).each do |x|
      (0..7).each do |y|
        target = [x, y]
        path = @travails.find_path(start, target)
        refute_nil path, "Should find a path from #{start.inspect} to #{target.inspect}"
        assert_valid_knight_path(path, start, target)
        assert path.length - 1 <= 6, "Path between any two squares on an 8x8 board must be <= 6 moves"
      end
    end
  end

  def test_invalid_start_position_raises_argument_error
    error = assert_raises(ArgumentError) { @travails.find_path([-1, 0], [3, 3]) }
    assert_includes error.message, 'Invalid start position'
  end

  def test_invalid_target_position_raises_argument_error
    error = assert_raises(ArgumentError) { @travails.find_path([0, 0], [8, 7]) }
    assert_includes error.message, 'Invalid target position'
  end

  def test_knight_moves_output_formatting
    # Capture stdout
    out, = capture_io do
      path = @travails.knight_moves([3, 3], [4, 3], display: true)
      assert_equal 4, path.length
    end

    assert_includes out, "You made it in 3 moves!  Here's your path:"
    assert_includes out, '  [3, 3]'
    assert_includes out, '  [4, 3]'
  end

  def test_knight_moves_singular_move_formatting
    out, = capture_io do
      @travails.knight_moves([0, 0], [1, 2], display: true)
    end

    assert_includes out, "You made it in 1 move!  Here's your path:"
  end

  def test_top_level_knight_moves_method
    out, = capture_io do
      path = knight_moves([0, 0], [3, 3])
      assert_equal 3, path.length
    end

    assert_includes out, "You made it in 2 moves!  Here's your path:"
  end
end
