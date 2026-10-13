# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FEN do
  it 'loads the standard starting FEN position' do
    data = FEN.load(FEN::STARTING_FEN)
    board = data[:board]
    turn = data[:turn]

    expect(turn).to eq(:white)
    expect(board.all_pieces.size).to eq(32)
    expect(board[[7, 4]]).to be_a(King)
    expect(board[[0, 4]]).to be_a(King)
    expect(board[[7, 4]].moved?).to be false
  end

  it 'exports the starting board back to FEN' do
    board = Board.new
    fen_str = FEN.to_fen(board, :white)
    expect(fen_str).to eq(FEN::STARTING_FEN)
  end

  it 'correctly loads a custom position and active turn' do
    # Scholar's mate final position
    scholars_fen = 'r1bqkb1r/pppp1Qpp/2n2n2/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4'
    data = FEN.load(scholars_fen)
    board = data[:board]
    turn = data[:turn]

    expect(turn).to eq(:black)
    expect(board[[1, 5]]).to be_a(Queen) # White Queen at f7
    expect(board[[1, 5]].white?).to be true
    expect(board.checkmate?(:black)).to be true
  end
end
