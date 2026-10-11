# spec/player_spec.rb
require 'spec_helper'

RSpec.describe Player do
  subject(:player) { described_class.new(name: 'Alice', symbol: '🔴') }

  describe '#initialize' do
    it 'sets the player name' do
      expect(player.name).to eq('Alice')
    end

    it 'sets the player symbol' do
      expect(player.symbol).to eq('🔴')
    end

    context 'when default arguments are used' do
      subject(:default_player) { described_class.new }

      it 'assigns a default name' do
        expect(default_player.name).to eq('Player 1')
      end

      it 'assigns a default symbol' do
        expect(default_player.symbol).to eq('🔴')
      end
    end
  end
end
