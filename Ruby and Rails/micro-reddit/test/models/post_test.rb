require "test_helper"

class PostTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @post = @user.posts.build(
      title: "Learning Rails with Odin Project",
      url: "https://theodinproject.com",
      body: "An amazing full stack curriculum!"
    )
  end

  test "should be valid with valid attributes" do
    assert @post.valid?
  end

  test "title should be present" do
    @post.title = "   "
    assert_not @post.valid?
    assert_includes @post.errors[:title], "can't be blank"
  end

  test "title should not be too short" do
    @post.title = "ab"
    assert_not @post.valid?
    assert_includes @post.errors[:title], "is too short (minimum is 3 characters)"
  end

  test "title should not be too long" do
    @post.title = "a" * 151
    assert_not @post.valid?
    assert_includes @post.errors[:title], "is too long (maximum is 150 characters)"
  end

  test "url should be present" do
    @post.url = "   "
    assert_not @post.valid?
    assert_includes @post.errors[:url], "can't be blank"
  end

  test "url should be valid http/https format" do
    @post.url = "ftp://not-allowed.com"
    assert_not @post.valid?
    assert_includes @post.errors[:url], "must be a valid URL starting with http or https"
  end

  test "should require an associated user" do
    @post.user = nil
    assert_not @post.valid?
    assert_includes @post.errors[:user], "must exist"
  end

  test "associated comments should be destroyed when post is destroyed" do
    @post.save!
    @post.comments.create!(body: "Nice post!", user: users(:two))
    assert_difference "Comment.count", -1 do
      @post.destroy
    end
  end
end
