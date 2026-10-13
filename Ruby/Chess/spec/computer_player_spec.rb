# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComputerPlayer do
  let(:bot) { ComputerPlayer.new(:white, "ChessBot", difficulty: :smart) }

  it 'generates a legal move on starting board' do
    board = Board.new
    move = bot.get_move(board)

    expect(move).to be_a(Move)
    expect(board.legal_moves(move.from)).to include(move.to)
  end

  it 'chooses an immediate checkmating move when available' do
    # White Queen at h5 [3, 7], White Bishop at c4 [4, 2], Black King at e8 [0, 4]
    # Move Qxf7# ([3, 7] to [1, 5]) delivers immediate mate
    fen = 'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4'
    board = FEN.load(fen)[:board]

    move = bot.get_move(board)
    expect(move.from).to eq([3, 7])
    expect(move.to).to eq([1, 5]) # Qxf7#
  end

  it 'prioritizes capturing high-value hanging pieces' do
    board = Board.new(setup: false)
    # White King at e1, White Rook at e2 [6, 4]
    # Black King at a8, Black Queen hanging at e7 [1, 4]
    board[[7, 4]] = King.new(:white, [7, 4])
    board[[6, 4]] = Rook.new(:white, [6, 4])
    board[[0, 0]] = King.new(:black, [0, 0])
    board[[1, 4]] = Queen.new(:black, [1, 4])

    move = bot.get_move(board)
    expect(move.from).to eq([6, 4])
    expect(move.to).to eq([1, 4]) # Rook captures hanging Queen
  end
end
