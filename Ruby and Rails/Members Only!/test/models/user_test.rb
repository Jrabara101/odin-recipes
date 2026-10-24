require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with name, email, and password" do
    user = User.new(
      name: "Arthur Pendragon",
      email: "arthur.king@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert user.valid?
  end

  test "invalid without name" do
    user = User.new(
      name: nil,
      email: "nameless@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "invalid with duplicate email" do
    user = User.new(
      name: "Imposter",
      email: users(:one).email,
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "destroying user also destroys their posts" do
    user = users(:one)
    post_id = posts(:one).id
    assert Post.exists?(post_id)

    user.destroy
    assert_not Post.exists?(post_id)
  end
end
