require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @user = users(:alice)
    @event = events(:upcoming_event)
  end

  test "should be valid with valid attributes" do
    assert @event.valid?
  end

  test "requires title, description, location, date, and creator" do
    event = Event.new
    assert_not event.valid?
    assert_includes event.errors[:title], "can't be blank"
    assert_includes event.errors[:description], "can't be blank"
    assert_includes event.errors[:location], "can't be blank"
    assert_includes event.errors[:date], "can't be blank"
    assert_includes event.errors[:creator], "must exist"
  end

  test "creator association works" do
    assert_equal @user, @event.creator
  end

  test "building event through association sets creator_id" do
    built_event = @user.created_events.build(
      title: "Built Event",
      description: "Testing build method",
      location: "Room 101",
      date: 1.day.from_now
    )
    assert_equal @user.id, built_event.creator_id
  end

  test "upcoming scope returns future events" do
    upcoming = Event.upcoming
    assert_includes upcoming, events(:upcoming_event)
    assert_not_includes upcoming, events(:past_event)
  end

  test "past scope returns past events" do
    past = Event.past
    assert_includes past, events(:past_event)
    assert_not_includes past, events(:upcoming_event)
  end

  test "attendees association works through event_attendances" do
    bob = users(:bob)
    assert_includes @event.attendees, bob
  end
end
