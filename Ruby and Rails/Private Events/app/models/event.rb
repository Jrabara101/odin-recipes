class Event < ApplicationRecord
  # Associations
  belongs_to :creator, class_name: "User"
  has_many :event_attendances, foreign_key: :attended_event_id, dependent: :destroy
  has_many :attendees, through: :event_attendances, source: :attendee

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 120 }
  validates :description, presence: true
  validates :location, presence: true
  validates :date, presence: true

  # Scopes
  scope :past, -> { where("date < ?", Time.current).order(date: :desc) }
  scope :upcoming, -> { where("date >= ?", Time.current).order(date: :asc) }
  scope :public_events, -> { where(private: false) }

  # Class methods for past and upcoming as asked by Odin project before scope refactoring
  # (demonstrating both class methods and scopes)
  def self.past_events
    past
  end

  def self.upcoming_events
    upcoming
  end

  # Helper methods
  def past?
    date.present? && date < Time.current
  end

  def upcoming?
    !past?
  end

  def visible_to?(user)
    return true unless private?
    return false if user.nil?

    creator == user || attendees.include?(user)
  end
end
