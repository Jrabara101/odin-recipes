# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Chess Pieces' do
  let(:board) { Board.new(setup: false) }

  describe Pawn do
    context 'White Pawn on starting rank (e2 / [6, 4])' do
      let(:pawn) { Pawn.new(:white, [6, 4]) }

      before { board[[6, 4]] = pawn }

      it 'can move forward 1 or 2 squares when unobstructed' do
        moves = pawn.pseudolegal_moves(board)
        expect(moves).to contain_exactly([5, 4], [4, 4])
      end

      it 'is blocked from moving forward when a piece is directly ahead' do
        board[[5, 4]] = Pawn.new(:black, [5, 4])
        moves = pawn.pseudolegal_moves(board)
        expect(moves).to be_empty
      end

      it 'can capture diagonally' do
        board[[5, 3]] = Pawn.new(:black, [5, 3])
        board[[5, 5]] = Pawn.new(:white, [5, 5]) # friendly, cannot capture
        moves = pawn.pseudolegal_moves(board)
        expect(moves).to include([5, 3])
        expect(moves).not_to include([5, 5])
      end

      it 'attacks diagonal squares regardless of whether occupied' do
        attacks = pawn.attacks(board)
        expect(attacks).to contain_exactly([5, 3], [5, 5])
      end
    end

    context 'Black Pawn on starting rank (e7 / [1, 4])' do
      let(:pawn) { Pawn.new(:black, [1, 4]) }

      before { board[[1, 4]] = pawn }

      it 'moves forward downwards ([2, 4] and [3, 4])' do
        moves = pawn.pseudolegal_moves(board)
        expect(moves).to contain_exactly([2, 4], [3, 4])
      end
    end
  end

  describe Knight do
    let(:knight) { Knight.new(:white, [4, 4]) }

    before { board[[4, 4]] = knight }

    it 'has 8 possible L-shaped jumps from center of empty board' do
      moves = knight.pseudolegal_moves(board)
      expect(moves.size).to eq(8)
      expect(moves).to include([2, 3], [2, 5], [3, 2], [3, 6], [5, 2], [5, 6], [6, 3], [6, 5])
    end

    it 'can jump over intervening pieces' do
      # Surround knight with pawns
      board[[3, 4]] = Pawn.new(:white, [3, 4])
      board[[5, 4]] = Pawn.new(:white, [5, 4])
      board[[4, 3]] = Pawn.new(:white, [4, 3])
      board[[4, 5]] = Pawn.new(:white, [4, 5])

      moves = knight.pseudolegal_moves(board)
      expect(moves.size).to eq(8)
    end

    it 'cannot land on friendly pieces but can capture enemy pieces' do
      board[[2, 3]] = Pawn.new(:white, [2, 3])
      board[[2, 5]] = Pawn.new(:black, [2, 5])

      moves = knight.pseudolegal_moves(board)
      expect(moves).not_to include([2, 3])
      expect(moves).to include([2, 5])
    end
  end

  describe Bishop do
    let(:bishop) { Bishop.new(:white, [4, 4]) }

    before { board[[4, 4]] = bishop }

    it 'slides diagonally in 4 directions' do
      moves = bishop.pseudolegal_moves(board)
      expect(moves).to include([3, 3], [2, 2], [5, 5], [6, 6], [3, 5], [5, 3])
      expect(moves.size).to eq(13)
    end

    it 'stops sliding before friendly pieces and on enemy pieces' do
      board[[2, 2]] = Pawn.new(:white, [2, 2])
      board[[2, 6]] = Pawn.new(:black, [2, 6])

      moves = bishop.pseudolegal_moves(board)
      expect(moves).to include([3, 3])
      expect(moves).not_to include([2, 2]) # friendly blocks
      expect(moves).not_to include([1, 1]) # behind friendly
      expect(moves).to include([3, 5], [2, 6]) # enemy captured
      expect(moves).not_to include([1, 7]) # behind enemy
    end
  end

  describe Rook do
    let(:rook) { Rook.new(:white, [4, 4]) }

    before { board[[4, 4]] = rook }

    it 'slides orthogonally in 4 directions' do
      moves = rook.pseudolegal_moves(board)
      expect(moves.size).to eq(14)
      expect(moves).to include([4, 0], [4, 7], [0, 4], [7, 4])
    end

    it 'is blocked by friendly and captures enemy' do
      board[[4, 6]] = Pawn.new(:white, [4, 6])
      board[[2, 4]] = Pawn.new(:black, [2, 4])

      moves = rook.pseudolegal_moves(board)
      expect(moves).to include([4, 5])
      expect(moves).not_to include([4, 6])
      expect(moves).to include([3, 4], [2, 4])
      expect(moves).not_to include([1, 4])
    end
  end

  describe Queen do
    let(:queen) { Queen.new(:white, [4, 4]) }

    before { board[[4, 4]] = queen }

    it 'combines bishop diagonals and rook orthogonals' do
      moves = queen.pseudolegal_moves(board)
      expect(moves.size).to eq(27) # 13 diagonal + 14 orthogonal
    end
  end

  describe King do
    let(:king) { King.new(:white, [4, 4]) }

    before { board[[4, 4]] = king }

    it 'steps 1 square in all 8 directions' do
      moves = king.attacks(board)
      expect(moves.size).to eq(8)
      expect(moves).to include([3, 3], [3, 4], [3, 5], [4, 3], [4, 5], [5, 3], [5, 4], [5, 5])
    end
  end
end
