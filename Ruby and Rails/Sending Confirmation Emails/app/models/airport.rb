class Airport < ApplicationRecord
  has_many :departing_flights,
           class_name: "Flight",
           foreign_key: "departure_airport_id",
           inverse_of: :departure_airport,
           dependent: :destroy

  has_many :arriving_flights,
           class_name: "Flight",
           foreign_key: "arrival_airport_id",
           inverse_of: :arrival_airport,
           dependent: :destroy

  validates :code, presence: true, uniqueness: { case_sensitive: false }, length: { is: 3 }
  validates :city, presence: true
  validates :name, presence: true

  before_validation { self.code = code.to_s.upcase.strip }

  def display_label
    "#{code} - #{city} (#{name})"
  end

  def short_label
    "#{code} - #{city}"
  end
end
