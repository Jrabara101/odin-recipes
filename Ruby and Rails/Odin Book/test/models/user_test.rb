require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user1 = User.create!(
      first_name: "John",
      last_name: "Doe",
      username: "johndoe",
      email: "john@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @user2 = User.create!(
      first_name: "Jane",
      last_name: "Smith",
      username: "janesmith",
      email: "jane@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "should be valid with valid attributes" do
    assert @user1.valid?
  end

  test "requires email" do
    user = User.new(first_name: "No", last_name: "Email", password: "password123")
    assert_not user.valid?
  end

  test "requires unique email" do
    duplicate_user = User.new(first_name: "Other", last_name: "User", email: @user1.email, password: "password123")
    assert_not duplicate_user.valid?
  end

  test "full_name formats correctly" do
    assert_equal "John Doe", @user1.full_name
  end

  test "has posts association" do
    post = @user1.posts.create!(content: "Test post")
    assert_includes @user1.posts, post
  end

  test "friendship lifecycle: send, accept, unfriend" do
    assert_not @user1.friend_with?(@user2)

    # Send friend request
    @user1.send_friend_request(@user2)
    assert @user1.pending_request_sent_to?(@user2)
    assert @user2.pending_request_received_from?(@user1)
    assert_not @user1.friend_with?(@user2)

    # Accept friend request
    @user2.accept_friend_request(@user1)
    assert @user1.friend_with?(@user2)
    assert @user2.friend_with?(@user1)
    assert_includes @user1.friends, @user2
    assert_includes @user2.friends, @user1

    # Unfriend
    @user1.unfriend(@user2)
    assert_not @user1.friend_with?(@user2)
    assert_not @user2.friend_with?(@user1)
  end

  test "feed_posts includes own posts and friends' posts" do
    user3 = User.create!(
      first_name: "Stranger",
      email: "stranger@example.com",
      password: "password123"
    )

    own_post = @user1.posts.create!(content: "My own post")
    friend_post = @user2.posts.create!(content: "Friend's post")
    stranger_post = user3.posts.create!(content: "Stranger's post")

    # Before friendship, only own post is in feed
    assert_includes @user1.feed_posts, own_post
    assert_not_includes @user1.feed_posts, friend_post

    # After friendship, friend's post is included
    Friendship.create!(sender: @user1, receiver: @user2, status: "accepted")
    feed = @user1.feed_posts
    assert_includes feed, own_post
    assert_includes feed, friend_post
    assert_not_includes feed, stranger_post
  end
end

