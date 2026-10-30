require "test_helper"

class KittenTest < ActiveSupport::TestCase
  def setup
    @kitten = Kitten.new(name: "Pancake", age: 2, cuteness: 10, softness: 9)
  end

  test "should be valid with valid attributes" do
    assert @kitten.valid?
  end

  test "name should be present" do
    @kitten.name = "   "
    assert_not @kitten.valid?
  end

  test "age should be present and valid integer between 0 and 35" do
    @kitten.age = nil
    assert_not @kitten.valid?

    @kitten.age = -1
    assert_not @kitten.valid?

    @kitten.age = 36
    assert_not @kitten.valid?

    @kitten.age = 0
    assert @kitten.valid?

    @kitten.age = 15
    assert @kitten.valid?
  end

  test "cuteness should be integer between 1 and 10" do
    @kitten.cuteness = nil
    assert_not @kitten.valid?

    @kitten.cuteness = 0
    assert_not @kitten.valid?

    @kitten.cuteness = 11
    assert_not @kitten.valid?

    @kitten.cuteness = 7
    assert @kitten.valid?
  end

  test "softness should be integer between 1 and 10" do
    @kitten.softness = nil
    assert_not @kitten.valid?

    @kitten.softness = 0
    assert_not @kitten.valid?

    @kitten.softness = 12
    assert_not @kitten.valid?

    @kitten.softness = 10
    assert @kitten.valid?
  end

  test "as_json includes necessary attributes and labels" do
    @kitten.save!
    json = @kitten.as_json
    assert_equal @kitten.id, json["id"]
    assert_equal "Pancake", json["name"]
    assert_equal 2, json["age"]
    assert_equal 10, json["cuteness"]
    assert_equal 9, json["softness"]
    assert_equal "Maximum Overdose of Cute", json["cuteness_label"]
    assert_equal "Cloud-Level Floof", json["softness_label"]
  end
end
