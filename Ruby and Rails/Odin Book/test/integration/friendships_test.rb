require "test_helper"

class FriendshipsTest < ActionDispatch::IntegrationTest
  def setup
    @alice = User.create!(first_name: "Alice", email: "alice.test@example.com", password: "password123")
    @bob = User.create!(first_name: "Bob", email: "bob.test@example.com", password: "password123")
  end

  test "sending, accepting, and deleting a friend request" do
    sign_in @alice

    # Alice sends friend request to Bob
    assert_difference "Friendship.count", 1 do
      post friendships_path, params: { receiver_id: @bob.id }
    end
    assert @alice.pending_request_sent_to?(@bob)
    assert_not @alice.friend_with?(@bob)

    friendship = Friendship.last
    assert_equal "pending", friendship.status

    # Switch to Bob
    sign_out @alice
    sign_in @bob

    # Bob confirms friend request
    patch friendship_path(friendship), params: { status: "accepted" }
    assert @alice.friend_with?(@bob)
    assert @bob.friend_with?(@alice)

    # Bob unfriends Alice
    assert_difference "Friendship.count", -1 do
      delete friendship_path(friendship)
    end
    assert_not @alice.friend_with?(@bob)
    assert_not @bob.friend_with?(@alice)
  end
end

