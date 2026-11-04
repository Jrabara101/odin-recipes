class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liking_users, through: :likes, source: :user
  has_many :comments, -> { order(created_at: :asc) }, dependent: :destroy

  has_one_attached :image

  validate :content_or_image_present

  scope :recent, -> { order(created_at: :desc) }

  def liked_by?(user)
    return false if user.nil?
    likes.exists?(user_id: user.id)
  end

  def like_from(user)
    return nil if user.nil?
    likes.find_by(user_id: user.id)
  end

  private

  def content_or_image_present
    if content.blank? && !image.attached?
      errors.add(:base, "Post must include either text content or an image.")
    end
  end
end
