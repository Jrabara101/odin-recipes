require "test_helper"

class FriendshipTest < ActiveSupport::TestCase
  def setup
    @sender = User.create!(first_name: "Sender", email: "sender@example.com", password: "password123")
    @receiver = User.create!(first_name: "Receiver", email: "receiver@example.com", password: "password123")
  end

  test "valid friendship defaults to pending" do
    friendship = Friendship.create!(sender: @sender, receiver: @receiver)
    assert_equal "pending", friendship.status
    assert friendship.valid?
  end

  test "cannot be self-referential" do
    friendship = Friendship.new(sender: @sender, receiver: @sender)
    assert_not friendship.valid?
    assert_includes friendship.errors[:receiver_id], "cannot send friend request to yourself"
  end

  test "unique sender and receiver pairing" do
    Friendship.create!(sender: @sender, receiver: @receiver)
    duplicate = Friendship.new(sender: @sender, receiver: @receiver)
    assert_not duplicate.valid?
  end

  test "accept! updates status to accepted" do
    friendship = Friendship.create!(sender: @sender, receiver: @receiver)
    friendship.accept!
    assert_equal "accepted", friendship.reload.status
  end

  test "reject! updates status to rejected" do
    friendship = Friendship.create!(sender: @sender, receiver: @receiver)
    friendship.reject!
    assert_equal "rejected", friendship.reload.status
  end
end

