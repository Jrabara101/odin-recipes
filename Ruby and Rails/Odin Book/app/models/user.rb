require "digest/md5"

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  has_many :sent_friendships, class_name: "Friendship", foreign_key: :sender_id, dependent: :destroy
  has_many :received_friendships, class_name: "Friendship", foreign_key: :receiver_id, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :first_name, length: { maximum: 50 }, allow_blank: true
  validates :last_name, length: { maximum: 50 }, allow_blank: true
  validates :username, uniqueness: true, length: { maximum: 30 }, allow_blank: true

  after_create_commit :send_welcome_email

  # Returns an ActiveRecord::Relation of accepted friends
  def friends
    User.where(id: Friendship.accepted.where(sender_id: id).select(:receiver_id))
        .or(User.where(id: Friendship.accepted.where(receiver_id: id).select(:sender_id)))
  end

  def pending_friend_requests_received
    Friendship.pending.where(receiver_id: id).includes(:sender)
  end

  def pending_friend_requests_sent
    Friendship.pending.where(sender_id: id).includes(:receiver)
  end

  def friend_with?(other_user)
    return false if other_user.nil? || other_user.id == id
    Friendship.accepted
              .where(sender_id: id, receiver_id: other_user.id)
              .or(Friendship.accepted.where(sender_id: other_user.id, receiver_id: id))
              .exists?
  end

  def pending_request_sent_to?(other_user)
    return false if other_user.nil?
    Friendship.pending.where(sender_id: id, receiver_id: other_user.id).exists?
  end

  def pending_request_received_from?(other_user)
    return false if other_user.nil?
    Friendship.pending.where(sender_id: other_user.id, receiver_id: id).exists?
  end

  def friendship_with(other_user)
    return nil if other_user.nil?
    Friendship.where(sender_id: id, receiver_id: other_user.id)
              .or(Friendship.where(sender_id: other_user.id, receiver_id: id))
              .first
  end

  def friendship_status_with(other_user)
    return :self if other_user == self
    return :friends if friend_with?(other_user)
    return :pending_sent if pending_request_sent_to?(other_user)
    return :pending_received if pending_request_received_from?(other_user)
    :none
  end

  def send_friend_request(other_user)
    return false if other_user == self || friendship_with(other_user).present?
    sent_friendships.create(receiver: other_user, status: "pending")
  end

  def accept_friend_request(other_user)
    req = Friendship.pending.find_by(sender: other_user, receiver: self)
    req&.accept!
  end

  def reject_friend_request(other_user)
    req = Friendship.pending.find_by(sender: other_user, receiver: self)
    req&.destroy
  end

  def unfriend(other_user)
    friendship = friendship_with(other_user)
    friendship&.destroy
  end

  # Feed posts: from self and all friends
  def feed_posts
    user_ids = [id] + friends.pluck(:id)
    Post.where(user_id: user_ids)
        .includes(:user, :likes, comments: :user)
        .with_attached_image
        .order(created_at: :desc)
  end

  def full_name
    name = [first_name, last_name].compact_blank.join(" ")
    name.presence || username.presence || email.split("@").first.titleize
  end

  def gravatar_url(size: 150)
    hash = Digest::MD5.hexdigest(email.downcase.strip)
    "https://www.gravatar.com/avatar/#{hash}?d=identicon&s=#{size}"
  end

  private

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  rescue StandardError => e
    Rails.logger.error("Failed to send welcome email to #{email}: #{e.message}")
  end
end
