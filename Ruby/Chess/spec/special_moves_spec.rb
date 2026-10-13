# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Special Chess Moves' do
  describe 'Castling' do
    let(:board) { Board.new(setup: false) }

    before do
      # King at e1, Rooks at a1 and h1
      board[[7, 4]] = King.new(:white, [7, 4])
      board[[7, 0]] = Rook.new(:white, [7, 0])
      board[[7, 7]] = Rook.new(:white, [7, 7])
      # Black king far away
      board[[0, 4]] = King.new(:black, [0, 4])
    end

    it 'allows kingside castling when path is clear and unattacked' do
      moves = board.legal_moves([7, 4])
      expect(moves).to include([7, 6]) # g1
    end

    it 'allows queenside castling when path is clear and unattacked' do
      moves = board.legal_moves([7, 4])
      expect(moves).to include([7, 2]) # c1
    end

    it 'executes castling by moving both King and Rook' do
      castling_move = board.build_move([7, 4], [7, 6])
      expect(castling_move.castling?).to be true
      expect(castling_move.castling).to eq(:kingside)

      board.make_move(castling_move)

      expect(board[[7, 6]]).to be_a(King)
      expect(board[[7, 5]]).to be_a(Rook) # Rook hopped to f1
      expect(board[[7, 4]]).to be_nil
      expect(board[[7, 7]]).to be_nil
      expect(board[[7, 6]].moved?).to be true
      expect(board[[7, 5]].moved?).to be true
    end

    it 'disallows castling if king has already moved' do
      board[[7, 4]].moved = true
      moves = board.legal_moves([7, 4])
      expect(moves).not_to include([7, 6])
      expect(moves).not_to include([7, 2])
    end

    it 'disallows kingside castling if kingside rook has moved' do
      board[[7, 7]].moved = true
      moves = board.legal_moves([7, 4])
      expect(moves).not_to include([7, 6])
      expect(moves).to include([7, 2]) # Queenside still valid
    end

    it 'disallows castling if intermediate square is occupied' do
      board[[7, 5]] = Bishop.new(:white, [7, 5])
      moves = board.legal_moves([7, 4])
      expect(moves).not_to include([7, 6])
    end

    it 'disallows castling if king is currently in check' do
      board[[2, 4]] = Rook.new(:black, [2, 4]) # attacks e1
      moves = board.legal_moves([7, 4])
      expect(moves).not_to include([7, 6])
      expect(moves).not_to include([7, 2])
    end

    it 'disallows castling if king must pass through an attacked square' do
      board[[2, 5]] = Rook.new(:black, [2, 5]) # attacks f1 [7, 5]
      moves = board.legal_moves([7, 4])
      expect(moves).not_to include([7, 6])
    end

    it 'disallows castling if king destination square is attacked' do
      board[[2, 6]] = Rook.new(:black, [2, 6]) # attacks g1 [7, 6]
      moves = board.legal_moves([7, 4])
      expect(moves).not_to include([7, 6])
    end
  end

  describe 'En Passant' do
    let(:board) { Board.new(setup: false) }

    before do
      board[[7, 4]] = King.new(:white, [7, 4])
      board[[0, 4]] = King.new(:black, [0, 4])
    end

    it 'sets en passant target when a pawn advances 2 squares' do
      white_pawn = Pawn.new(:white, [6, 4]) # e2
      board[[6, 4]] = white_pawn
      move = board.build_move([6, 4], [4, 4]) # e2 to e4
      board.make_move(move)

      expect(board.en_passant_target).to eq([5, 4]) # e3
    end

    it 'allows adjacent enemy pawn to capture en passant' do
      # White pawn at e5 [3, 4], Black pawn moves d7 [1, 3] -> d5 [3, 3]
      white_pawn = Pawn.new(:white, [3, 4])
      black_pawn = Pawn.new(:black, [1, 3])
      board[[3, 4]] = white_pawn
      board[[1, 3]] = black_pawn

      double_step = board.build_move([1, 3], [3, 3])
      board.make_move(double_step)

      expect(board.en_passant_target).to eq([2, 3]) # d6

      # White pawn at e5 can now move diagonally to d6 and capture black pawn at d5
      ep_moves = board.legal_moves([3, 4])
      expect(ep_moves).to include([2, 3])

      ep_move = board.build_move([3, 4], [2, 3])
      expect(ep_move.en_passant?).to be true
      expect(ep_move.captured).to eq(black_pawn)

      board.make_move(ep_move)

      expect(board[[2, 3]]).to eq(white_pawn)
      expect(board[[3, 4]]).to be_nil
      expect(board[[3, 3]]).to be_nil # Black pawn removed from d5!
      expect(board.captured_pieces[:black]).to include(black_pawn)
    end

    it 'clears en passant target on the subsequent move if not taken' do
      white_pawn = Pawn.new(:white, [6, 4])
      board[[6, 4]] = white_pawn
      board.make_move(board.build_move([6, 4], [4, 4]))
      expect(board.en_passant_target).to eq([5, 4])

      # Black makes a different move: King moves [0, 4] -> [0, 5]
      board.make_move(board.build_move([0, 4], [0, 5]))
      expect(board.en_passant_target).to be_nil
    end
  end

  describe 'Pawn Promotion' do
    let(:board) { Board.new(setup: false) }

    before do
      board[[7, 4]] = King.new(:white, [7, 4])
      board[[0, 0]] = King.new(:black, [0, 0])
    end

    it 'promotes a white pawn reaching rank 8 (row 0) to Queen by default' do
      pawn = Pawn.new(:white, [1, 4])
      board[[1, 4]] = pawn

      move = board.build_move([1, 4], [0, 4])
      expect(move.promotion?).to be true
      expect(move.promotion).to eq(:queen)

      board.make_move(move)
      expect(board[[0, 4]]).to be_a(Queen)
      expect(board[[0, 4]].color).to eq(:white)
    end

    it 'promotes to Knight when specified' do
      pawn = Pawn.new(:white, [1, 4])
      board[[1, 4]] = pawn

      move = board.build_move([1, 4], [0, 4], :knight)
      expect(move.promotion).to eq(:knight)

      board.make_move(move)
      expect(board[[0, 4]]).to be_a(Knight)
      expect(board[[0, 4]].color).to eq(:white)
    end
  end
end
