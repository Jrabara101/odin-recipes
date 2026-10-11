# lib/game.rb

class Game
  attr_reader :board, :player1, :player2, :current_player, :winner

  def initialize(board: Board.new, player1: Player.new(name: 'Player 1', symbol: '🔴'), player2: Player.new(name: 'Player 2', symbol: '🟡'))
    @board = board
    @player1 = player1
    @player2 = player2
    @current_player = @player1
    @winner = nil
  end

  def switch_players
    @current_player = (@current_player == @player1 ? @player2 : @player1)
  end

  def game_over?
    if @board.win?(@player1.symbol)
      @winner = @player1
      true
    elsif @board.win?(@player2.symbol)
      @winner = @player2
      true
    elsif @board.full?
      @winner = nil
      true
    else
      false
    end
  end

  def solicit_move
    loop do
      print "#{current_player.name} (#{current_player.symbol}), choose a column (1-7): "
      input = user_input.to_s.strip
      col = input =~ /^\d+$/ ? input.to_i : nil

      if col && board.valid_column?(col)
        return col
      elsif col && col.between?(1, Board::COLUMNS) && board.column_full?(col)
        puts "Column #{col} is already full! Please choose another column."
      else
        puts "Invalid choice! Please choose an available column between 1 and 7."
      end
    end
  end

  def user_input
    gets&.chomp
  end

  def take_turn
    puts board.render
    col = solicit_move
    board.drop_piece(col, current_player.symbol)
  end

  def announce_result
    puts board.render
    if winner
      puts "🎉 Congratulations, #{winner.name} (#{winner.symbol})! You won the game!"
    else
      puts "🤝 It's a draw! The board is full and no player connected four."
    end
  end

  def play
    puts '========================================'
    puts '        WELCOME TO CONNECT FOUR!        '
    puts '========================================'
    puts "#{player1.name} (#{player1.symbol}) vs #{player2.name} (#{player2.symbol})"
    puts 'Connect 4 pieces horizontally, vertically, or diagonally to win.'
    puts '----------------------------------------'

    until game_over?
      take_turn
      break if game_over?

      switch_players
    end

    announce_result
  end
end
