require "test_helper"

class LikeTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(first_name: "Liker", email: "liker@example.com", password: "password123")
    @post = @user.posts.create!(content: "A post to like")
  end

  test "user can like a post" do
    like = Like.new(user: @user, post: @post)
    assert like.valid?
  end

  test "user cannot like the same post twice" do
    Like.create!(user: @user, post: @post)
    duplicate = Like.new(user: @user, post: @post)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already liked this post"
  end
end

