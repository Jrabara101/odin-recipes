# spec/board_spec.rb
require 'spec_helper'

RSpec.describe Board do
  subject(:board) { described_class.new }

  describe '#initialize' do
    it 'creates a board with 6 rows' do
      expect(board.grid.length).to eq(6)
    end

    it 'creates each row with 7 columns' do
      expect(board.grid.all? { |row| row.length == 7 }).to be true
    end

    it 'initializes all cells as empty spaces' do
      all_empty = board.grid.flatten.all? { |cell| cell == Board::EMPTY }
      expect(all_empty).to be true
    end
  end

  describe '#drop_piece' do
    context 'when column is empty' do
      it 'places the piece at the bottom row (row index 5)' do
        board.drop_piece(1, '🔴')
        expect(board.grid[5][0]).to eq('🔴')
      end

      it 'returns true on successful drop' do
        expect(board.drop_piece(1, '🔴')).to be true
      end
    end

    context 'when column already has pieces' do
      before do
        board.drop_piece(1, '🔴')
      end

      it 'stacks the new piece directly on top (row index 4)' do
        board.drop_piece(1, '🟡')
        expect(board.grid[4][0]).to eq('🟡')
        expect(board.grid[5][0]).to eq('🔴')
      end
    end

    context 'when column is completely full' do
      before do
        6.times { board.drop_piece(3, '🔴') }
      end

      it 'returns false and does not add the piece' do
        result = board.drop_piece(3, '🟡')
        expect(result).to be false
        expect(board.grid[0][2]).to eq('🔴')
      end
    end

    context 'when column number is out of bounds' do
      it 'returns false for column 0' do
        expect(board.drop_piece(0, '🔴')).to be false
      end

      it 'returns false for column 8' do
        expect(board.drop_piece(8, '🔴')).to be false
      end

      it 'returns false for negative column' do
        expect(board.drop_piece(-1, '🔴')).to be false
      end
    end
  end

  describe '#column_full?' do
    it 'returns false when column is empty' do
      expect(board.column_full?(1)).to be false
    end

    it 'returns false when column has space remaining' do
      3.times { board.drop_piece(2, '🔴') }
      expect(board.column_full?(2)).to be false
    end

    it 'returns true when column has 6 pieces' do
      6.times { board.drop_piece(2, '🔴') }
      expect(board.column_full?(2)).to be true
    end
  end

  describe '#valid_column?' do
    it 'returns true for valid empty columns between 1 and 7' do
      (1..7).each do |col|
        expect(board.valid_column?(col)).to be true
      end
    end

    it 'returns false for column < 1' do
      expect(board.valid_column?(0)).to be false
    end

    it 'returns false for column > 7' do
      expect(board.valid_column?(8)).to be false
    end

    it 'returns false for a full column' do
      6.times { board.drop_piece(4, '🔴') }
      expect(board.valid_column?(4)).to be false
    end
  end

  describe '#full?' do
    it 'returns false for a new empty board' do
      expect(board.full?).to be false
    end

    it 'returns false when only some columns are full' do
      (1..6).each do |col|
        6.times { board.drop_piece(col, '🔴') }
      end
      expect(board.full?).to be false
    end

    it 'returns true when all 42 slots are filled' do
      (1..7).each do |col|
        6.times { board.drop_piece(col, '🔴') }
      end
      expect(board.full?).to be true
    end
  end

  describe '#win?' do
    context 'when board is empty' do
      it 'returns false for red' do
        expect(board.win?('🔴')).to be false
      end

      it 'returns false for yellow' do
        expect(board.win?('🟡')).to be false
      end
    end

    context 'horizontal wins' do
      it 'detects 4 in a row at the bottom' do
        (1..4).each { |col| board.drop_piece(col, '🔴') }
        expect(board.win?('🔴')).to be true
        expect(board.win?('🟡')).to be false
      end

      it 'detects 4 in a row at the right edge' do
        (4..7).each { |col| board.drop_piece(col, '🟡') }
        expect(board.win?('🟡')).to be true
      end

      it 'detects 4 in a row in a higher row' do
        # Fill base row with red
        (2..5).each { |col| board.drop_piece(col, '🔴') }
        # Fill second row with yellow
        (2..5).each { |col| board.drop_piece(col, '🟡') }
        expect(board.win?('🟡')).to be true
      end

      it 'returns false when 4 tokens are interrupted by another player' do
        board.drop_piece(1, '🔴')
        board.drop_piece(2, '🔴')
        board.drop_piece(3, '🟡')
        board.drop_piece(4, '🔴')
        expect(board.win?('🔴')).to be false
      end

      it 'returns false for only 3 consecutive tokens' do
        (1..3).each { |col| board.drop_piece(col, '🔴') }
        expect(board.win?('🔴')).to be false
      end
    end

    context 'vertical wins' do
      it 'detects 4 consecutive tokens in column 1' do
        4.times { board.drop_piece(1, '🔴') }
        expect(board.win?('🔴')).to be true
        expect(board.win?('🟡')).to be false
      end

      it 'detects 4 consecutive tokens in column 7' do
        4.times { board.drop_piece(7, '🟡') }
        expect(board.win?('🟡')).to be true
      end

      it 'detects 4 consecutive tokens stacked on top of an opponent piece' do
        board.drop_piece(2, '🔴')
        4.times { board.drop_piece(2, '🟡') }
        expect(board.win?('🟡')).to be true
        expect(board.win?('🔴')).to be false
      end

      it 'returns false for only 3 consecutive stacked tokens' do
        3.times { board.drop_piece(3, '🔴') }
        expect(board.win?('🔴')).to be false
      end
    end

    context 'diagonal wins (ascending / bottom-left to top-right)' do
      # Target diagonal:
      # col 1 (row 5)
      # col 2 (row 4)
      # col 3 (row 3)
      # col 4 (row 2)
      before do
        board.drop_piece(1, '🔴')

        board.drop_piece(2, '🟡')
        board.drop_piece(2, '🔴')

        board.drop_piece(3, '🟡')
        board.drop_piece(3, '🟡')
        board.drop_piece(3, '🔴')

        board.drop_piece(4, '🟡')
        board.drop_piece(4, '🟡')
        board.drop_piece(4, '🟡')
        board.drop_piece(4, '🔴')
      end

      it 'detects the ascending diagonal win for red' do
        expect(board.win?('🔴')).to be true
        expect(board.win?('🟡')).to be false
      end

      it 'returns false for ascending diagonal with only 3 tokens' do
        fresh_board = described_class.new
        fresh_board.drop_piece(1, '🔴')

        fresh_board.drop_piece(2, '🟡')
        fresh_board.drop_piece(2, '🔴')

        fresh_board.drop_piece(3, '🟡')
        fresh_board.drop_piece(3, '🟡')
        fresh_board.drop_piece(3, '🔴')

        expect(fresh_board.win?('🔴')).to be false
      end

      it 'detects ascending diagonal on the right edge (cols 4 to 7)' do
        edge_board = described_class.new
        edge_board.drop_piece(4, '🔴')

        edge_board.drop_piece(5, '🟡')
        edge_board.drop_piece(5, '🔴')

        2.times { edge_board.drop_piece(6, '🟡') }
        edge_board.drop_piece(6, '🔴')

        3.times { edge_board.drop_piece(7, '🟡') }
        edge_board.drop_piece(7, '🔴')

        expect(edge_board.win?('🔴')).to be true
      end
    end

    context 'diagonal wins (descending / top-left to bottom-right)' do
      # Target diagonal:
      # col 1 (row 2)
      # col 2 (row 3)
      # col 3 (row 4)
      # col 4 (row 5)
      before do
        3.times { board.drop_piece(1, '🟡') }
        board.drop_piece(1, '🔴')

        2.times { board.drop_piece(2, '🟡') }
        board.drop_piece(2, '🔴')

        board.drop_piece(3, '🟡')
        board.drop_piece(3, '🔴')

        board.drop_piece(4, '🔴')
      end

      it 'detects the descending diagonal win for red' do
        expect(board.win?('🔴')).to be true
        expect(board.win?('🟡')).to be false
      end

      it 'returns false when a diagonal is broken by an opponent token' do
        broken_board = described_class.new
        3.times { broken_board.drop_piece(1, '🟡') }
        broken_board.drop_piece(1, '🔴')

        2.times { broken_board.drop_piece(2, '🟡') }
        broken_board.drop_piece(2, '🔴')

        broken_board.drop_piece(3, '🟡')
        broken_board.drop_piece(3, '🟡') # Opponent blocks!

        broken_board.drop_piece(4, '🔴')

        expect(broken_board.win?('🔴')).to be false
      end

      it 'detects descending diagonal on the right edge (cols 4 to 7)' do
        edge_board = described_class.new
        3.times { edge_board.drop_piece(4, '🟡') }
        edge_board.drop_piece(4, '🔴')

        2.times { edge_board.drop_piece(5, '🟡') }
        edge_board.drop_piece(5, '🔴')

        edge_board.drop_piece(6, '🟡')
        edge_board.drop_piece(6, '🔴')

        edge_board.drop_piece(7, '🔴')

        expect(edge_board.win?('🔴')).to be true
      end
    end
  end

  describe '#render' do
    it 'returns a formatted string displaying the grid and columns' do
      board.drop_piece(1, '🔴')
      output = board.render
      expect(output).to include('1   2   3   4   5   6   7')
      expect(output).to include('🔴')
    end
  end
end
