require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(first_name: "Commenter", email: "commenter@example.com", password: "password123")
    @post = @user.posts.create!(content: "A post to comment on")
  end

  test "valid with content" do
    comment = Comment.new(user: @user, post: @post, content: "Nice post!")
    assert comment.valid?
  end

  test "invalid without content" do
    comment = Comment.new(user: @user, post: @post, content: "")
    assert_not comment.valid?
  end
end

