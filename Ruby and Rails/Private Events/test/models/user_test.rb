require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:alice)
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "requires name and username" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
    assert_includes user.errors[:username], "can't be blank"
  end

  test "has created_events association" do
    assert_includes @user.created_events, events(:upcoming_event)
  end

  test "has attended_events association" do
    assert_includes @user.attended_events, events(:past_event)
  end

  test "attending? helper method" do
    assert @user.attending?(events(:past_event))
    assert_not @user.attending?(events(:upcoming_event))
  end
end
