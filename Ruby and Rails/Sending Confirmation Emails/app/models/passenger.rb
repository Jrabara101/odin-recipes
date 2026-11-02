class Passenger < ApplicationRecord
  belongs_to :booking, inverse_of: :passengers
  has_one :flight, through: :booking

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  before_validation { self.email = email.to_s.strip.downcase }
  before_validation { self.name = name.to_s.strip }
end
