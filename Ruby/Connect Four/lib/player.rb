# lib/player.rb

class Player
  attr_reader :name, :symbol

  def initialize(name: 'Player 1', symbol: '🔴')
    @name = name
    @symbol = symbol
  end
end
