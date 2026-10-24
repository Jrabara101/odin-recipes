require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "valid post with title, body, and user" do
    post = Post.new(title: "Valid Title", body: "Valid content for post", user: users(:one))
    assert post.valid?
  end

  test "invalid without title" do
    post = Post.new(title: nil, body: "Valid content", user: users(:one))
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "invalid without body" do
    post = Post.new(title: "Valid Title", body: nil, user: users(:one))
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  test "invalid without user" do
    post = Post.new(title: "Valid Title", body: "Valid content", user: nil)
    assert_not post.valid?
    assert_includes post.errors[:user], "must exist"
  end
end
