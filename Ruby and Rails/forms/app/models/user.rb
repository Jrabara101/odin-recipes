class User < ApplicationRecord
  validates :username, presence: true, length: { minimum: 3 }
  validates :email, presence: true
  validates :password, presence: true, length: { minimum: 6 }
end
