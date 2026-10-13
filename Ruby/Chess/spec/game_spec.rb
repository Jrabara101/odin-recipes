# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Game do
  let(:white_player) { HumanPlayer.new(:white, "Alice") }
  let(:black_player) { HumanPlayer.new(:black, "Bob") }
  let(:game) { Game.new(white_player: white_player, black_player: black_player) }

  describe '#initialize' do
    it 'starts on White turn by default' do
      expect(game.current_turn).to eq(:white)
      expect(game.current_player).to eq(white_player)
    end
  end

  describe '#execute_player_move' do
    it 'updates the board, last_move, and switches active turn to black' do
      move = game.board.build_move([6, 4], [4, 4]) # e2 to e4
      game.execute_player_move(move)

      expect(game.last_move).to eq(move)
      expect(game.current_turn).to eq(:black)
      expect(game.current_player).to eq(black_player)
      expect(game.board[[4, 4]]).to be_a(Pawn)
      expect(game.board[[6, 4]]).to be_nil
    end
  end

  describe 'Game termination' do
    it 'detects immediate checkmate and announces winner' do
      # Set up Scholar's mate final position
      fen = 'r1bqkb1r/pppp1Qpp/2n2n2/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4'
      loaded = FEN.load(fen)
      checkmate_game = Game.new(
        board: loaded[:board],
        white_player: white_player,
        black_player: black_player,
        current_turn: :black
      )

      # Stub terminal renderer to avoid stdout clutter in tests
      allow(Display).to receive(:render)

      result = checkmate_game.play
      expect(result).to eq(white_player)
    end
  end
end
