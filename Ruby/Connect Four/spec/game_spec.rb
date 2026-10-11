# spec/game_spec.rb
require 'spec_helper'

RSpec.describe Game do
  let(:board) { instance_double(Board) }
  let(:player1) { instance_double(Player, name: 'Alice', symbol: '🔴') }
  let(:player2) { instance_double(Player, name: 'Bob', symbol: '🟡') }
  subject(:game) { described_class.new(board: board, player1: player1, player2: player2) }

  describe '#initialize' do
    it 'sets the board' do
      expect(game.board).to eq(board)
    end

    it 'sets player1' do
      expect(game.player1).to eq(player1)
    end

    it 'sets player2' do
      expect(game.player2).to eq(player2)
    end

    it 'sets player1 as the initial current player' do
      expect(game.current_player).to eq(player1)
    end

    it 'starts with no winner' do
      expect(game.winner).to be_nil
    end
  end

  describe '#switch_players' do
    it 'switches current player from player1 to player2' do
      game.switch_players
      expect(game.current_player).to eq(player2)
    end

    it 'switches current player from player2 back to player1' do
      game.switch_players
      game.switch_players
      expect(game.current_player).to eq(player1)
    end
  end

  describe '#game_over?' do
    context 'when current player has a winning line' do
      before do
        allow(board).to receive(:win?).with('🔴').and_return(true)
        allow(board).to receive(:full?).and_return(false)
      end

      it 'returns true' do
        expect(game.game_over?).to be true
      end

      it 'assigns current player as winner' do
        game.game_over?
        expect(game.winner).to eq(player1)
      end
    end

    context 'when board is full with no winner' do
      before do
        allow(board).to receive(:win?).with('🔴').and_return(false)
        allow(board).to receive(:win?).with('🟡').and_return(false)
        allow(board).to receive(:full?).and_return(true)
      end

      it 'returns true' do
        expect(game.game_over?).to be true
      end

      it 'leaves winner as nil (draw)' do
        game.game_over?
        expect(game.winner).to be_nil
      end
    end

    context 'when game is ongoing' do
      before do
        allow(board).to receive(:win?).with('🔴').and_return(false)
        allow(board).to receive(:win?).with('🟡').and_return(false)
        allow(board).to receive(:full?).and_return(false)
      end

      it 'returns false' do
        expect(game.game_over?).to be false
      end
    end
  end

  describe '#solicit_move' do
    before do
      # Suppress puts output in console during testing
      allow(game).to receive(:puts)
      allow(game).to receive(:print)
    end

    context 'when user enters a valid column on first attempt' do
      it 'returns the column integer' do
        allow(game).to receive(:user_input).and_return('4')
        allow(board).to receive(:valid_column?).with(4).and_return(true)

        expect(game.solicit_move).to eq(4)
      end
    end

    context 'when user enters an out of bounds number before a valid one' do
      it 'prompts again and returns the valid column' do
        allow(game).to receive(:user_input).and_return('9', '3')
        allow(board).to receive(:valid_column?).with(9).and_return(false)
        allow(board).to receive(:valid_column?).with(3).and_return(true)

        expect(game).to receive(:puts).with(match(/Invalid choice/i)).once
        expect(game.solicit_move).to eq(3)
      end
    end

    context 'when user enters non-numeric input before a valid column' do
      it 'prompts again and returns the valid column' do
        allow(game).to receive(:user_input).and_return('abc', '5')
        allow(board).to receive(:valid_column?).with('abc').and_return(false)
        allow(board).to receive(:valid_column?).with(5).and_return(true)

        expect(game).to receive(:puts).with(match(/Invalid choice/i)).once
        expect(game.solicit_move).to eq(5)
      end
    end

    context 'when chosen column is full' do
      it 'warns the player and prompts again until valid' do
        allow(game).to receive(:user_input).and_return('2', '1')
        allow(board).to receive(:valid_column?).with(2).and_return(false)
        allow(board).to receive(:column_full?).with(2).and_return(true)
        allow(board).to receive(:valid_column?).with(1).and_return(true)

        expect(game).to receive(:puts).with(match(/Column 2 is already full/i)).once
        expect(game.solicit_move).to eq(1)
      end
    end
  end

  describe '#take_turn' do
    before do
      allow(game).to receive(:puts)
      allow(board).to receive(:render).and_return('BOARD')
      allow(game).to receive(:solicit_move).and_return(3)
      allow(board).to receive(:drop_piece).with(3, '🔴').and_return(true)
    end

    it 'renders the board' do
      expect(board).to receive(:render)
      game.take_turn
    end

    it 'drops the piece in the selected column' do
      expect(board).to receive(:drop_piece).with(3, '🔴')
      game.take_turn
    end
  end

  describe '#play' do
    before do
      allow(game).to receive(:puts)
      allow(board).to receive(:render).and_return('BOARD')
    end

    context 'when player 1 wins on the first move' do
      it 'displays the board, drops piece, announces player 1 win, and stops' do
        allow(game).to receive(:solicit_move).and_return(4)
        allow(board).to receive(:drop_piece).with(4, '🔴').and_return(true)

        # game_over? returns false before move, then true after move
        allow(game).to receive(:game_over?).and_return(false, true)
        allow(game).to receive(:winner).and_return(player1)

        expect(game).to receive(:announce_result).once
        game.play
      end
    end

    context 'when the game ends in a draw' do
      it 'announces a draw when board is full and no winner' do
        allow(game).to receive(:solicit_move).and_return(1)
        allow(board).to receive(:drop_piece).with(1, '🔴').and_return(true)

        allow(game).to receive(:game_over?).and_return(false, true)
        allow(game).to receive(:winner).and_return(nil)

        expect(game).to receive(:announce_result).once
        game.play
      end
    end
  end
end
