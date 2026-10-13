# frozen_string_literal: true

# Base Player class.
class Player
  attr_reader :color, :name

  def initialize(color, name = nil)
    @color = color.to_sym
    @name = name || default_name
  end

  def white?
    @color == :white
  end

  def black?
    @color == :black
  end

  def human?
    false
  end

  def get_move(_board, _game = nil)
    raise NotImplementedError, "#{self.class} must implement #get_move"
  end

  private

  def default_name
    "#{@color.to_s.capitalize} Player"
  end
end
