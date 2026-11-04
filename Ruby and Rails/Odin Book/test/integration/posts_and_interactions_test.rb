require "test_helper"

class PostsAndInteractionsTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      first_name: "Active",
      last_name: "Poster",
      email: "poster@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    sign_in @user
  end

  test "user can create and delete a post" do
    assert_difference "@user.posts.count", 1 do
      post posts_path, params: { post: { content: "This is my integration test post!" } }
    end
    assert_redirected_to root_path

    new_post = @user.posts.last
    assert_difference "@user.posts.count", -1 do
      delete post_path(new_post)
    end
    assert_redirected_to root_path
  end

  test "user can like and unlike a post" do
    feed_post = @user.posts.create!(content: "Like me!")

    assert_difference "feed_post.likes.count", 1 do
      post post_likes_path(feed_post)
    end

    assert feed_post.liked_by?(@user)

    like = feed_post.like_from(@user)
    assert_difference "feed_post.likes.count", -1 do
      delete post_like_path(feed_post, like)
    end

    assert_not feed_post.liked_by?(@user)
  end

  test "user can comment on a post and delete their comment" do
    feed_post = @user.posts.create!(content: "Comment on me!")

    assert_difference "feed_post.comments.count", 1 do
      post post_comments_path(feed_post), params: { comment: { content: "Great test post!" } }
    end

    comment = feed_post.comments.last
    assert_equal "Great test post!", comment.content

    assert_difference "feed_post.comments.count", -1 do
      delete post_comment_path(feed_post, comment)
    end
  end
end

