class User < ApplicationRecord
  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { in: 4..20 }

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
end
