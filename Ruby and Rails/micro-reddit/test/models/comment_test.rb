require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @post = posts(:one)
    @comment = Comment.new(
      body: "Insightful post, thanks for sharing!",
      user: @user,
      post: @post
    )
  end

  test "should be valid with valid attributes" do
    assert @comment.valid?
  end

  test "body should be present" do
    @comment.body = "   "
    assert_not @comment.valid?
    assert_includes @comment.errors[:body], "can't be blank"
  end

  test "should require an associated user" do
    @comment.user = nil
    assert_not @comment.valid?
    assert_includes @comment.errors[:user], "must exist"
  end

  test "should require an associated post" do
    @comment.post = nil
    assert_not @comment.valid?
    assert_includes @comment.errors[:post], "must exist"
  end

  test "associations should return correct records" do
    @comment.save!
    assert_equal @user, @comment.user
    assert_equal @post, @comment.post
    assert_includes @user.comments, @comment
    assert_includes @post.comments, @comment
  end
end
