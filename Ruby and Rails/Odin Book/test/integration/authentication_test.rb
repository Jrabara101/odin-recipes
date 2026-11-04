require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      first_name: "Test",
      last_name: "User",
      email: "testuser@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "unauthenticated user is redirected to sign in from feed" do
    get root_path
    assert_redirected_to new_user_session_path
  end

  test "unauthenticated user is redirected to sign in from users index" do
    get users_path
    assert_redirected_to new_user_session_path
  end

  test "unauthenticated user can access sign in page" do
    get new_user_session_path
    assert_response :success
  end

  test "unauthenticated user can access sign up page" do
    get new_user_registration_path
    assert_response :success
  end

  test "authenticated user can access root feed and users index" do
    sign_in @user
    get root_path
    assert_response :success

    get users_path
    assert_response :success

    get user_path(@user)
    assert_response :success
  end
end

