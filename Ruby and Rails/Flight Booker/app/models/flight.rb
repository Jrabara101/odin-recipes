class Flight < ApplicationRecord
  belongs_to :departure_airport,
             class_name: "Airport",
             foreign_key: "departure_airport_id",
             inverse_of: :departing_flights

  belongs_to :arrival_airport,
             class_name: "Airport",
             foreign_key: "arrival_airport_id",
             inverse_of: :arriving_flights

  has_many :bookings, dependent: :destroy
  has_many :passengers, through: :bookings

  validates :departure_airport_id, presence: true
  validates :arrival_airport_id, presence: true
  validates :start_datetime, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :flight_number, presence: true
  validate :airports_must_be_different

  scope :ordered, -> { order(:start_datetime) }

  def self.search(departure_id: nil, arrival_id: nil, date: nil)
    flights = all.includes(:departure_airport, :arrival_airport).ordered

    flights = flights.where(departure_airport_id: departure_id) if departure_id.present?
    flights = flights.where(arrival_airport_id: arrival_id) if arrival_id.present?

    if date.present?
      parsed_date = parse_date_safely(date)
      if parsed_date
        flights = flights.where(start_datetime: parsed_date.beginning_of_day..parsed_date.end_of_day)
      end
    end

    flights
  end

  def self.available_dates
    # Distinct dates of flights available in the database, ordered chronologically
    order(:start_datetime)
      .pluck(:start_datetime)
      .map(&:to_date)
      .uniq
  end

  def arrival_datetime
    start_datetime + duration.minutes
  end

  def formatted_date
    start_datetime.strftime("%m/%d/%Y")
  end

  def formatted_full_date
    start_datetime.strftime("%A, %B %e, %Y")
  end

  def formatted_time
    start_datetime.strftime("%I:%M %p")
  end

  def formatted_arrival_time
    arrival_datetime.strftime("%I:%M %p")
  end

  def formatted_duration
    hours = duration / 60
    minutes = duration % 60
    "#{hours}h #{minutes}m"
  end

  private

  def airports_must_be_different
    if departure_airport_id.present? && departure_airport_id == arrival_airport_id
      errors.add(:arrival_airport_id, "cannot be the same as departure airport")
    end
  end

  def self.parse_date_safely(date_input)
    return date_input if date_input.is_a?(Date) || date_input.is_a?(Time)

    Date.parse(date_input.to_s)
  rescue ArgumentError
    nil
  end
end
