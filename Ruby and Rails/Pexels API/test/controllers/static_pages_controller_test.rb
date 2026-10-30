# frozen_string_literal: true

require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home page with empty state" do
    get root_url
    assert_response :success
    assert_select "h1.hero-title", text: /Display Photos from Your Pexels Gallery/i
    assert_select "input.search-input"
    assert_select ".guide-section"
  end

  test "should load demo gallery when demo parameter is passed" do
    get root_url, params: { demo: 1 }
    assert_response :success
    assert_select ".photo-card"
    assert_select ".alert-info", text: /Demo Gallery Active/i
    assert_select ".photographer-name"
    assert_select ".btn-download"
  end

  test "should load demo gallery when collection_id is demo" do
    get root_url, params: { collection_id: "demo" }
    assert_response :success
    assert_select ".photo-card"
    assert_select ".results-title", text: /Demo Collection/i
  end

  test "should return JSON payload when requested with demo" do
    get root_url, params: { demo: 1 }, headers: { "Accept" => "application/json" }
    assert_response :success
    json = JSON.parse(response.body)
    assert json["success"]
    assert_equal "demo", json["collection_id"]
    assert json["photos"].is_a?(Array)
    assert json["photos"].any?
  end

  test "should display friendly error when collection ID is blank" do
    get root_url, params: { collection_id: "   " }
    assert_response :success
    assert_select ".photo-card", count: 0
  end

  test "should display 401 alert when live collection is searched without API key" do
    original_env = ENV["PEXELS_API_KEY"]
    begin
      ENV["PEXELS_API_KEY"] = nil
      get root_url, params: { collection_id: "custom_123" }
      assert_response :success
      assert_select ".alert-danger", text: /Pexels API key not configured/i
    ensure
      ENV["PEXELS_API_KEY"] = original_env
    end
  end

  test "should render pagination links when page > 1" do
    get root_url, params: { demo: 1, page: 2 }
    assert_response :success
    assert_select ".page-indicator", text: /Page 2/i
    assert_select ".btn-page", text: /Previous Page/i
  end
end
