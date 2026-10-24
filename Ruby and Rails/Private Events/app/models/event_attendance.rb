class EventAttendance < ApplicationRecord
  belongs_to :attendee, class_name: "User"
  belongs_to :attended_event, class_name: "Event"

  validates :attendee_id, uniqueness: { scope: :attended_event_id, message: "is already attending this event" }
  validates :status, inclusion: { in: %w[attending invited declined] }
end
