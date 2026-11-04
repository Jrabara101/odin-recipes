require "test_helper"

class PostTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(first_name: "Post", last_name: "Author", email: "author@example.com", password: "password123")
  end

  test "valid with content" do
    post = @user.posts.build(content: "Great day today!")
    assert post.valid?
  end

  test "invalid without content or image" do
    post = @user.posts.build(content: "")
    assert_not post.valid?
  end

  test "liked_by? returns true when user liked the post" do
    post = @user.posts.create!(content: "Testing likes")
    liker = User.create!(first_name: "Liker", email: "liker@example.com", password: "password123")

    assert_not post.liked_by?(liker)
    post.likes.create!(user: liker)
    assert post.liked_by?(liker)
  end
end

