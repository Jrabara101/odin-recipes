# lib/connect_four.rb
require_relative 'board'
require_relative 'player'
require_relative 'game'

def setup_game
  puts '========================================'
  puts '       CONNECT FOUR CONFIGURATION       '
  puts '========================================'
  print 'Enter Player 1 name (press Enter for "Player 1"): '
  name1 = gets&.chomp.to_s.strip
  name1 = 'Player 1' if name1.empty?

  print 'Enter Player 2 name (press Enter for "Player 2"): '
  name2 = gets&.chomp.to_s.strip
  name2 = 'Player 2' if name2.empty?

  player1 = Player.new(name: name1, symbol: '🔴')
  player2 = Player.new(name: name2, symbol: '🟡')

  Game.new(player1: player1, player2: player2)
end

if __FILE__ == $PROGRAM_NAME
  loop do
    game = setup_game
    game.play

    print "\nWould you like to play again? (y/n): "
    answer = gets&.chomp.to_s.strip.downcase
    break unless answer.start_with?('y')

    puts "\nRestarting new game...\n"
  end

  puts "\nThank you for playing Connect Four! Goodbye!\n"
end
