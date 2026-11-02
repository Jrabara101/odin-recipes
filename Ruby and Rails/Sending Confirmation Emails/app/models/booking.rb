class Booking < ApplicationRecord
  belongs_to :flight
  has_many :passengers, inverse_of: :booking, dependent: :destroy

  accepts_nested_attributes_for :passengers,
                                allow_destroy: true,
                                reject_if: :all_blank

  validates :flight_id, presence: true
  validates :passengers, presence: true
  validates :booking_reference, presence: true, uniqueness: true

  before_validation :generate_booking_reference, on: :create

  private

  def generate_booking_reference
    return if booking_reference.present?

    loop do
      self.booking_reference = "SKY-#{SecureRandom.alphanumeric(6).upcase}"
      break unless Booking.exists?(booking_reference: booking_reference)
    end
  end
end
