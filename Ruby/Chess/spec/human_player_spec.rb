# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe HumanPlayer do
  let(:player) { HumanPlayer.new(:white, "Alice") }
  let(:board) { Board.new }

  describe '#get_move input parsing' do
    it 'accepts standard coordinate notation e2e4' do
      allow(player).to receive(:gets).and_return("e2e4\n")
      move = player.get_move(board)

      expect(move).to be_a(Move)
      expect(move.from).to eq([6, 4])
      expect(move.to).to eq([4, 4])
    end

    it 'accepts space-separated coordinate notation e2 e4' do
      allow(player).to receive(:gets).and_return("e2 e4\n")
      move = player.get_move(board)

      expect(move).to be_a(Move)
      expect(move.from).to eq([6, 4])
      expect(move.to).to eq([4, 4])
    end

    it 'recognizes kingside castling shorthand O-O' do
      # Setup clear path for castling
      custom_board = Board.new(setup: false)
      custom_board[[7, 4]] = King.new(:white, [7, 4])
      custom_board[[7, 7]] = Rook.new(:white, [7, 7])
      custom_board[[0, 4]] = King.new(:black, [0, 4])

      allow(player).to receive(:gets).and_return("O-O\n")
      move = player.get_move(custom_board)

      expect(move).to be_a(Move)
      expect(move.castling?).to be true
      expect(move.castling).to eq(:kingside)
    end

    it 'returns commands like :save, :help, :resign' do
      allow(player).to receive(:gets).and_return("save\n")
      expect(player.get_move(board)).to eq(:save)

      allow(player).to receive(:gets).and_return("help\n")
      expect(player.get_move(board)).to eq(:help)

      allow(player).to receive(:gets).and_return("resign\n")
      expect(player.get_move(board)).to eq(:resign)
    end
  end
end
