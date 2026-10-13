# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Check, Checkmate, and Stalemate' do
  describe "Fool's Mate (Fastest Checkmate)" do
    let(:board) { Board.new }

    it 'detects checkmate against White after 1. f3 e5 2. g4 Qh4#' do
      # 1. f2-f3 [6, 5] -> [5, 5]
      board.make_move(board.build_move([6, 5], [5, 5]))
      # 1... e7-e5 [1, 4] -> [3, 4]
      board.make_move(board.build_move([1, 4], [3, 4]))
      # 2. g2-g4 [6, 6] -> [4, 6]
      board.make_move(board.build_move([6, 6], [4, 6]))
      # 2... Qd8-h4# [0, 3] -> [4, 7]
      board.make_move(board.build_move([0, 3], [4, 7]))

      expect(board.in_check?(:white)).to be true
      expect(board.all_legal_moves(:white)).to be_empty
      expect(board.checkmate?(:white)).to be true
      expect(board.checkmate?(:black)).to be false
    end
  end

  describe "Scholar's Mate" do
    let(:board) { Board.new }

    it 'detects checkmate against Black after 1. e4 e5 2. Bc4 Nc6 3. Qh5 Nf6 4. Qxf7#' do
      # 1. e4 e5
      board.make_move(board.build_move([6, 4], [4, 4]))
      board.make_move(board.build_move([1, 4], [3, 4]))
      # 2. Bc4 Nc6
      board.make_move(board.build_move([7, 5], [4, 2]))
      board.make_move(board.build_move([0, 1], [2, 2]))
      # 3. Qh5 Nf6
      board.make_move(board.build_move([7, 3], [3, 7]))
      board.make_move(board.build_move([0, 6], [2, 5]))
      # 4. Qxf7# [3, 7] -> [1, 5]
      board.make_move(board.build_move([3, 7], [1, 5]))

      expect(board.in_check?(:black)).to be true
      expect(board.all_legal_moves(:black)).to be_empty
      expect(board.checkmate?(:black)).to be true
    end
  end

  describe 'Stalemate' do
    let(:board) { Board.new(setup: false) }

    it 'detects stalemate when Black King is not in check but has zero legal moves' do
      # Classic stalemate: Black King at a8 [0, 0], White King at c7 [1, 2], White Queen at b6 [2, 1]
      board[[0, 0]] = King.new(:black, [0, 0])
      board[[1, 2]] = King.new(:white, [1, 2])
      board[[2, 1]] = Queen.new(:white, [2, 1])

      expect(board.in_check?(:black)).to be false
      expect(board.all_legal_moves(:black)).to be_empty
      expect(board.stalemate?(:black)).to be true
      expect(board.checkmate?(:black)).to be false
    end
  end

  describe 'Insufficient Material Draw' do
    let(:board) { Board.new(setup: false) }

    it 'detects King vs King as insufficient material' do
      board[[7, 4]] = King.new(:white, [7, 4])
      board[[0, 4]] = King.new(:black, [0, 4])
      expect(board.insufficient_material?).to be true
    end

    it 'detects King + Bishop vs King as insufficient material' do
      board[[7, 4]] = King.new(:white, [7, 4])
      board[[5, 2]] = Bishop.new(:white, [5, 2])
      board[[0, 4]] = King.new(:black, [0, 4])
      expect(board.insufficient_material?).to be true
    end

    it 'detects King + Knight vs King as insufficient material' do
      board[[7, 4]] = King.new(:white, [7, 4])
      board[[5, 2]] = Knight.new(:white, [5, 2])
      board[[0, 4]] = King.new(:black, [0, 4])
      expect(board.insufficient_material?).to be true
    end

    it 'detects King + Bishop vs King + Bishop when bishops are on same color squares' do
      # Both on light squares (sum of row+col is even)
      board[[7, 4]] = King.new(:white, [7, 4])
      board[[4, 4]] = Bishop.new(:white, [4, 4]) # 4+4 = 8 (light)
      board[[0, 4]] = King.new(:black, [0, 4])
      board[[2, 2]] = Bishop.new(:black, [2, 2]) # 2+2 = 4 (light)
      expect(board.insufficient_material?).to be true
    end

    it 'does NOT declare insufficient material if a pawn is present' do
      board[[7, 4]] = King.new(:white, [7, 4])
      board[[6, 4]] = Pawn.new(:white, [6, 4])
      board[[0, 4]] = King.new(:black, [0, 4])
      expect(board.insufficient_material?).to be false
    end
  end

  describe 'Escaping Check' do
    let(:board) { Board.new(setup: false) }

    it 'allows blocking the checking ray' do
      # White King at e1 [7, 4], Black Rook at e8 [0, 4]
      # White Bishop at d2 [6, 3] can move to e3 [5, 4] or e2 [6, 4] to block
      board[[7, 4]] = King.new(:white, [7, 4])
      board[[0, 4]] = Rook.new(:black, [0, 4])
      board[[0, 0]] = King.new(:black, [0, 0])
      board[[6, 3]] = Bishop.new(:white, [6, 3])

      expect(board.in_check?(:white)).to be true
      expect(board.checkmate?(:white)).to be false

      bishop_moves = board.legal_moves([6, 3])
      expect(bishop_moves).to include([5, 4]) # Block on e3
    end

    it 'allows capturing the checking piece' do
      # White King at e1 [7, 4], Black Queen at e2 [6, 4] checking King
      # White Knight at c3 [5, 2] can capture Queen at e2
      board[[7, 4]] = King.new(:white, [7, 4])
      board[[6, 4]] = Queen.new(:black, [6, 4])
      board[[0, 0]] = King.new(:black, [0, 0])
      board[[5, 2]] = Knight.new(:white, [5, 2])

      knight_moves = board.legal_moves([5, 2])
      expect(knight_moves).to include([6, 4])
    end
  end
end
