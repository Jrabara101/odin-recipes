# frozen_string_literal: true

# Encapsulates a chess move from one position to another, including special flags.
class Move
  attr_accessor :from, :to, :piece, :captured, :castling, :en_passant, :promotion

  def initialize(from:, to:, piece:, captured: nil, castling: nil, en_passant: false, promotion: nil)
    @from = from
    @to = to
    @piece = piece
    @captured = captured
    @castling = castling
    @en_passant = en_passant
    @promotion = promotion
  end

  def self.pos_to_coord(pos)
    return nil if pos.nil?

    r, c = pos
    file = (c + 'a'.ord).chr
    rank = (8 - r).to_s
    "#{file}#{rank}"
  end

  def self.coord_to_pos(coord)
    return nil if coord.nil?

    coord = coord.to_s.strip.downcase
    return nil unless coord =~ /\A[a-h][1-8]\z/

    file = coord[0].ord - 'a'.ord
    rank = 8 - coord[1].to_i
    [rank, file]
  end

  def from_coord
    Move.pos_to_coord(@from)
  end

  def to_coord
    Move.pos_to_coord(@to)
  end

  def castling?
    !@castling.nil?
  end

  def en_passant?
    @en_passant
  end

  def promotion?
    !@promotion.nil?
  end

  def capture?
    !@captured.nil? || @en_passant
  end

  def to_s
    if @castling == :kingside
      "O-O"
    elsif @castling == :queenside
      "O-O-O"
    else
      promo_str = @promotion ? "=#{@promotion.to_s[0].upcase}" : ""
      separator = capture? ? "x" : "-"
      "#{from_coord}#{separator}#{to_coord}#{promo_str}"
    end
  end

  def to_h
    {
      from: @from,
      to: @to,
      from_coord: from_coord,
      to_coord: to_coord,
      piece: @piece.nil? ? nil : @piece.to_h,
      captured: @captured.nil? ? nil : @captured.to_h,
      castling: @castling,
      en_passant: @en_passant,
      promotion: @promotion
    }
  end

  def ==(other)
    other.is_a?(Move) &&
      @from == other.from &&
      @to == other.to &&
      @promotion == other.promotion
  end
  alias eql? ==

  def hash
    [@from, @to, @promotion].hash
  end
end
