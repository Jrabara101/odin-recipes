class Friendship < ApplicationRecord
  STATUSES = %w[pending accepted rejected].freeze

  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  validates :status, inclusion: { in: STATUSES }
  validates :receiver_id, uniqueness: { scope: :sender_id, message: "already has a friend request with this user" }
  validate :not_self_referential

  scope :pending, -> { where(status: "pending") }
  scope :accepted, -> { where(status: "accepted") }
  scope :rejected, -> { where(status: "rejected") }

  def accept!
    update(status: "accepted")
  end

  def reject!
    update(status: "rejected")
  end

  private

  def not_self_referential
    errors.add(:receiver_id, "cannot send friend request to yourself") if sender_id == receiver_id
  end
end
