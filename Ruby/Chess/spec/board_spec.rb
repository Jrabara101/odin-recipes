# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Board do
  let(:board) { Board.new }

  describe '#initialize' do
    it 'sets up 32 pieces in standard initial configuration' do
      expect(board.all_pieces.size).to eq(32)
      expect(board.all_pieces(:white).size).to eq(16)
      expect(board.all_pieces(:black).size).to eq(16)
    end

    it 'places kings at e1 and e8' do
      expect(board[[7, 4]]).to be_a(King)
      expect(board[[7, 4]].color).to eq(:white)

      expect(board[[0, 4]]).to be_a(King)
      expect(board[[0, 4]].color).to eq(:black)
    end

    it 'places rooks at corners' do
      expect(board[[7, 0]]).to be_a(Rook)
      expect(board[[7, 7]]).to be_a(Rook)
      expect(board[[0, 0]]).to be_a(Rook)
      expect(board[[0, 7]]).to be_a(Rook)
    end
  end

  describe '#in_check?' do
    let(:custom_board) { Board.new(setup: false) }

    it 'returns false when king is not threatened' do
      custom_board[[7, 4]] = King.new(:white, [7, 4])
      custom_board[[0, 4]] = King.new(:black, [0, 4])
      expect(custom_board.in_check?(:white)).to be false
    end

    it 'returns true when opponent rook has direct ray to king' do
      custom_board[[7, 4]] = King.new(:white, [7, 4])
      custom_board[[0, 4]] = King.new(:black, [0, 4])
      custom_board[[7, 0]] = Rook.new(:black, [7, 0])

      expect(custom_board.in_check?(:white)).to be true
      expect(custom_board.in_check?(:black)).to be false
    end

    it 'returns false if another piece blocks the check ray' do
      custom_board[[7, 4]] = King.new(:white, [7, 4])
      custom_board[[0, 4]] = King.new(:black, [0, 4])
      custom_board[[7, 0]] = Rook.new(:black, [7, 0])
      custom_board[[7, 2]] = Knight.new(:white, [7, 2]) # blocks rook

      expect(custom_board.in_check?(:white)).to be false
    end
  end

  describe 'Pinning and King Safety' do
    let(:custom_board) { Board.new(setup: false) }

    it 'prevents an absolute pinned piece from moving off the pin line' do
      # White King at e1 [7, 4], White Bishop at e3 [5, 4], Black Rook at e8 [0, 4]
      custom_board[[7, 4]] = King.new(:white, [7, 4])
      custom_board[[5, 4]] = Bishop.new(:white, [5, 4])
      custom_board[[0, 4]] = Rook.new(:black, [0, 4])
      custom_board[[0, 0]] = King.new(:black, [0, 0])

      # Bishop diagonal moves would expose King at e1 to Rook at e8
      legal = custom_board.legal_moves([5, 4])
      expect(legal).to be_empty
    end

    it 'prevents king from moving into attacked square' do
      custom_board[[7, 4]] = King.new(:white, [7, 4])
      custom_board[[0, 0]] = King.new(:black, [0, 0])
      custom_board[[0, 5]] = Rook.new(:black, [0, 5]) # attacks entire file 5 (f-file)

      legal = custom_board.legal_moves([7, 4])
      expect(legal).not_to include([7, 5]) # cannot step onto f1
      expect(legal).not_to include([6, 5]) # cannot step onto f2
    end
  end
end
