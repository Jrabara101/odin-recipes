require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get users_url
    assert_response :success
    assert_select "h1", text: /Users Directory/
  end

  test "should get new" do
    get new_user_url
    assert_response :success
    assert_select "h1", text: /New User/
    assert_select "form"
  end

  test "should create user with valid parameters" do
    assert_difference("User.count", 1) do
      post users_url, params: {
        user: {
          username: "valid_user",
          email: "valid@example.com",
          password: "password789"
        }
      }
    end

    assert_redirected_to new_user_url
    follow_redirect!
    assert_select ".flash-notice", text: /User created successfully!/
  end

  test "should reject user creation with invalid parameters" do
    assert_no_difference("User.count") do
      post users_url, params: {
        user: {
          username: "",
          email: "bad_email",
          password: "123"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation"
  end

  test "should get edit" do
    get edit_user_url(@user)
    assert_response :success
    assert_select "h1", text: /Edit User ##{@user.id}/
    assert_select "input[name='user[username]'][value=?]", @user.username
  end

  test "should update user with valid parameters" do
    patch user_url(@user), params: {
      user: {
        username: "updated_username",
        email: "updated@example.com",
        password: "newpassword123"
      }
    }

    assert_redirected_to edit_user_url(@user)
    @user.reload
    assert_equal "updated_username", @user.username
    assert_equal "updated@example.com", @user.email
  end

  test "should reject user update with invalid parameters" do
    patch user_url(@user), params: {
      user: {
        username: "",
        password: "123"
      }
    }

    assert_response :unprocessable_entity
    assert_select "#error_explanation"
  end
end
