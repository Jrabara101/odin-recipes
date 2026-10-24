require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "guest can view posts index but author identities are concealed" do
    get posts_url
    assert_response :success

    # Verify post title and body are shown
    assert_select ".post-title", text: posts(:one).title
    assert_select ".post-title", text: posts(:two).title

    # Verify author name is masked as Anonymous Member
    assert_select ".author-name.unrevealed", text: "Anonymous Member"
    # Ensure real author names are not revealed
    assert_select ".author-name", text: users(:one).name, count: 0
    assert_select ".author-name", text: users(:two).name, count: 0
  end

  test "signed in member can view posts index and see all author names" do
    sign_in users(:one)

    get posts_url
    assert_response :success

    # Verify real author names are displayed
    assert_select ".author-name", text: users(:one).name
    assert_select ".author-name", text: users(:two).name
    # Verify verified member badge is present
    assert_select ".member-pill.revealed-pill", text: "✓ Member"
  end

  test "guest is redirected to sign in when attempting to access new post page" do
    get new_post_url
    assert_redirected_to new_user_session_path
  end

  test "guest is redirected to sign in when attempting to create a post" do
    assert_no_difference("Post.count") do
      post posts_url, params: { post: { title: "Intruder Note", body: "Unauthorized post attempt" } }
    end
    assert_redirected_to new_user_session_path
  end

  test "signed in member can access new post page" do
    sign_in users(:one)

    get new_post_url
    assert_response :success
    assert_select "form#new-secret-post-form"
  end

  test "signed in member can create a secret post automatically associated with their user" do
    sign_in users(:one)

    assert_difference("Post.count", 1) do
      post posts_url, params: {
        post: {
          title: "The Sign of the Four",
          body: "A secret treasure hidden beneath the floorboards."
        }
      }
    end

    assert_redirected_to posts_path
    follow_redirect!
    assert_response :success

    created_post = Post.last
    assert_equal "The Sign of the Four", created_post.title
    assert_equal users(:one).id, created_post.user_id
    assert_equal users(:one), created_post.user
  end

  test "post creation fails gracefully with invalid attributes" do
    sign_in users(:one)

    assert_no_difference("Post.count") do
      post posts_url, params: {
        post: {
          title: "",
          body: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation"
  end
end
