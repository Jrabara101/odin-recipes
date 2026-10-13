# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'board'
require_relative 'human_player'
require_relative 'computer_player'

# Handles serialization and deserialization of games to and from JSON.
class Serializer
  class << self
    attr_writer :saves_dir

    def saves_dir
      @saves_dir || File.expand_path('../../saves', __FILE__)
    end
  end

  def self.ensure_saves_dir
    FileUtils.mkdir_p(saves_dir) unless Dir.exist?(saves_dir)
  end

  # Saves game state to a JSON file
  def self.save_game(board, current_turn, white_player, black_player, filename: nil)
    ensure_saves_dir

    filename ||= "chess_save_#{Time.now.strftime('%Y%m%d_%H%M%S')}"
    filename = filename.gsub(/[^0-9A-Za-z_-]/, '_')
    filepath = File.join(saves_dir, "#{filename}.json")

    grid_data = Array.new(8) { Array.new(8) }
    8.times do |r|
      8.times do |c|
        piece = board.piece_at([r, c])
        grid_data[r][c] = piece ? piece.to_h : nil
      end
    end

    data = {
      saved_at: Time.now.to_s,
      current_turn: current_turn.to_s,
      white_player: player_to_h(white_player),
      black_player: player_to_h(black_player),
      board: {
        grid: grid_data,
        en_passant_target: board.en_passant_target,
        halfmove_clock: board.halfmove_clock,
        fullmove_number: board.fullmove_number,
        captured_white: board.captured_pieces[:white].map(&:to_h),
        captured_black: board.captured_pieces[:black].map(&:to_h),
        move_history: board.move_history.map(&:to_h)
      }
    }

    File.write(filepath, JSON.pretty_generate(data))
    filepath
  end

  # Lists all available save files
  def self.list_saves
    ensure_saves_dir
    Dir.glob(File.join(saves_dir, '*.json')).sort_by { |f| File.mtime(f) }.reverse
  end

  # Loads a game from a specific file path
  def self.load_game(filepath)
    raise ArgumentError, "Save file does not exist: #{filepath}" unless File.exist?(filepath)

    content = File.read(filepath)
    data = JSON.parse(content, symbolize_names: true)

    # 1. Reconstruct Board
    board = Board.new(setup: false)
    grid_data = data[:board][:grid]

    8.times do |r|
      8.times do |c|
        p_data = grid_data[r][c]
        next unless p_data

        piece = instantiate_piece(p_data[:type], p_data[:color], p_data[:position])
        piece.moved = p_data[:moved]
        board[[r, c]] = piece
      end
    end

    board.en_passant_target = data[:board][:en_passant_target]
    board.halfmove_clock = data[:board][:halfmove_clock] || 0
    board.fullmove_number = data[:board][:fullmove_number] || 1

    # Reconstruct captured pieces
    captured_w = (data[:board][:captured_white] || []).map do |p_data|
      instantiate_piece(p_data[:type], p_data[:color], nil)
    end
    captured_b = (data[:board][:captured_black] || []).map do |p_data|
      instantiate_piece(p_data[:type], p_data[:color], nil)
    end
    board.instance_variable_set(:@captured_pieces, { white: captured_w, black: captured_b })

    # Reconstruct players
    white_player = instantiate_player(data[:white_player], :white)
    black_player = instantiate_player(data[:black_player], :black)
    turn = data[:current_turn].to_sym

    {
      board: board,
      current_turn: turn,
      white_player: white_player,
      black_player: black_player
    }
  end

  private

  def self.player_to_h(player)
    {
      type: player.human? ? 'human' : 'computer',
      color: player.color.to_s,
      name: player.name,
      difficulty: player.is_a?(ComputerPlayer) ? player.difficulty.to_s : nil
    }
  end

  def self.instantiate_piece(type, color, pos)
    color_sym = color.to_sym
    case type.to_s.downcase
    when 'pawn'   then Pawn.new(color_sym, pos)
    when 'knight' then Knight.new(color_sym, pos)
    when 'bishop' then Bishop.new(color_sym, pos)
    when 'rook'   then Rook.new(color_sym, pos)
    when 'queen'  then Queen.new(color_sym, pos)
    when 'king'   then King.new(color_sym, pos)
    else
      raise "Unknown piece type: #{type}"
    end
  end

  def self.instantiate_player(p_data, default_color)
    return HumanPlayer.new(default_color) unless p_data

    color = (p_data[:color] || default_color).to_sym
    name = p_data[:name]
    if p_data[:type] == 'computer'
      diff = (p_data[:difficulty] || 'smart').to_sym
      ComputerPlayer.new(color, name, difficulty: diff)
    else
      HumanPlayer.new(color, name)
    end
  end
end
