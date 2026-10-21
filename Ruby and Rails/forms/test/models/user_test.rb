require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with all attributes" do
    user = User.new(username: "odin_student", email: "student@theodinproject.com", password: "password123")
    assert user.valid?
  end

  test "invalid without username" do
    user = User.new(username: nil, email: "student@theodinproject.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "invalid without email" do
    user = User.new(username: "odin_student", email: nil, password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "invalid without password" do
    user = User.new(username: "odin_student", email: "student@theodinproject.com", password: nil)
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "invalid with short password" do
    user = User.new(username: "odin_student", email: "student@theodinproject.com", password: "123")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end
end
