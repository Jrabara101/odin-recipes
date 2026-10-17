require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(username: "valid_user", email: "user@example.com")
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "username should be present" do
    @user.username = "   "
    assert_not @user.valid?
    assert_includes @user.errors[:username], "can't be blank"
  end

  test "username should not be too short" do
    @user.username = "abc"
    assert_not @user.valid?
    assert_includes @user.errors[:username], "is too short (minimum is 4 characters)"
  end

  test "username should not be too long" do
    @user.username = "a" * 21
    assert_not @user.valid?
    assert_includes @user.errors[:username], "is too long (maximum is 20 characters)"
  end

  test "username should be unique" do
    duplicate_user = @user.dup
    duplicate_user.username = @user.username.upcase
    @user.save!
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:username], "has already been taken"
  end

  test "email should be present" do
    @user.email = "   "
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "email should reject invalid formats" do
    invalid_emails = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com]
    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?, "#{invalid_email.inspect} should be invalid"
    end
  end

  test "email should accept valid formats" do
    valid_emails = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp]
    valid_emails.each do |valid_email|
      @user.email = valid_email
      assert @user.valid?, "#{valid_email.inspect} should be valid"
    end
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save!
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "associated posts should be destroyed when user is destroyed" do
    @user.save!
    @user.posts.create!(title: "Post to destroy", url: "https://example.com")
    assert_difference "Post.count", -1 do
      @user.destroy
    end
  end
end
