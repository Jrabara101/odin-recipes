require "test_helper"

class KittensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kitten = Kitten.create!(name: "Waffles", age: 1, cuteness: 10, softness: 10)
  end

  test "should get index as HTML" do
    get kittens_url
    assert_response :success
    assert_select "h1", text: /Kitten Sanctuary/
    assert_select "h3.card-name", text: /Waffles/
  end

  test "should get index as JSON" do
    get kittens_url, headers: { "Accept" => "application/json" }
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type

    json = JSON.parse(response.body)
    assert_kind_of Array, json
    assert json.any? { |k| k["name"] == "Waffles" }
  end

  test "should get index with .json extension" do
    get kittens_url(format: :json)
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type

    json = JSON.parse(response.body)
    assert_kind_of Array, json
  end

  test "should get show as HTML" do
    get kitten_url(@kitten)
    assert_response :success
    assert_select "h1.profile-name", text: "Waffles"
    assert_select "span.metric-score", text: "10"
  end

  test "should get show as JSON" do
    get kitten_url(@kitten), headers: { "Accept" => "application/json" }
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type

    json = JSON.parse(response.body)
    assert_equal @kitten.id, json["id"]
    assert_equal "Waffles", json["name"]
    assert_equal 1, json["age"]
    assert_equal 10, json["cuteness"]
    assert_equal 10, json["softness"]
  end

  test "should get show with .json extension" do
    get kitten_url(@kitten, format: :json)
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @kitten.id, json["id"]
  end

  test "should get new" do
    get new_kitten_url
    assert_response :success
    assert_select "h1.form-title", text: "Register a New Kitten"
  end

  test "should create kitten with valid params" do
    assert_difference("Kitten.count", 1) do
      post kittens_url, params: { kitten: { name: "Noodle", age: 2, cuteness: 9, softness: 8 } }
    end

    created_kitten = Kitten.last
    assert_redirected_to kitten_url(created_kitten)
    follow_redirect!
    assert_select ".flash-success", text: /Purr-fection/
  end

  test "should not create kitten with invalid params" do
    assert_no_difference("Kitten.count") do
      post kittens_url, params: { kitten: { name: "", age: -5, cuteness: 15, softness: 0 } }
    end

    assert_response :unprocessable_entity
    assert_select ".flash-alert", text: /Meow-uch/
    assert_select ".form-error-banner"
  end

  test "should get edit" do
    get edit_kitten_url(@kitten)
    assert_response :success
    assert_select "h1.form-title", text: "Edit Kitten: Waffles"
    # Verify delete link exists on edit page
    assert_select ".danger-zone-card", text: /Delete Waffles/
  end

  test "should update kitten with valid params" do
    patch kitten_url(@kitten), params: { kitten: { name: "Sir Waffles III", cuteness: 10 } }
    assert_redirected_to kitten_url(@kitten)
    @kitten.reload
    assert_equal "Sir Waffles III", @kitten.name
    follow_redirect!
    assert_select ".flash-success", text: /Snazzy/
  end

  test "should not update kitten with invalid params" do
    patch kitten_url(@kitten), params: { kitten: { name: "", cuteness: 99 } }
    assert_response :unprocessable_entity
    assert_select ".flash-alert", text: /botched the makeover/
  end

  test "should destroy kitten" do
    assert_difference("Kitten.count", -1) do
      delete kitten_url(@kitten)
    end

    assert_redirected_to kittens_url
    follow_redirect!
    assert_select ".flash-toast", text: /Farewell, Waffles/
  end
end
