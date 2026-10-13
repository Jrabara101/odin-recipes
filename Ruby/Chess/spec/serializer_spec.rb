# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe Serializer do
  let(:board) { Board.new }
  let(:white_player) { HumanPlayer.new(:white, "Alice") }
  let(:black_player) { ComputerPlayer.new(:black, "Bot", difficulty: :smart) }

  around do |example|
    Dir.mktmpdir do |dir|
      Serializer.saves_dir = dir
      example.run
    ensure
      Serializer.saves_dir = nil
    end
  end

  it 'saves and loads a game accurately' do
    # Make a couple moves
    board.make_move(board.build_move([6, 4], [4, 4])) # e2 to e4
    board.make_move(board.build_move([1, 4], [3, 4])) # e7 to e5

    filepath = Serializer.save_game(board, :white, white_player, black_player, filename: 'test_save')
    expect(File.exist?(filepath)).to be true

    loaded = Serializer.load_game(filepath)
    loaded_board = loaded[:board]

    expect(loaded[:current_turn]).to eq(:white)
    expect(loaded[:white_player].name).to eq("Alice")
    expect(loaded[:black_player].name).to eq("Bot")
    expect(loaded[:black_player].is_a?(ComputerPlayer)).to be true

    # Check piece positions
    expect(loaded_board[[4, 4]]).to be_a(Pawn)
    expect(loaded_board[[4, 4]].white?).to be true
    expect(loaded_board[[4, 4]].moved?).to be true

    expect(loaded_board[[3, 4]]).to be_a(Pawn)
    expect(loaded_board[[3, 4]].black?).to be true
    expect(loaded_board[[3, 4]].moved?).to be true

    expect(loaded_board[[6, 4]]).to be_nil
    expect(loaded_board[[1, 4]]).to be_nil
  end

  it 'lists saved games sorted by modification time' do
    Serializer.save_game(board, :white, white_player, black_player, filename: 'save1')
    sleep 0.05
    Serializer.save_game(board, :black, white_player, black_player, filename: 'save2')

    saves = Serializer.list_saves
    expect(saves.size).to eq(2)
    expect(File.basename(saves.first)).to eq('save2.json')
  end
end
