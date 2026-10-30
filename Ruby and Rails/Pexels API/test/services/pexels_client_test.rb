# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class PexelsClientTest < ActiveSupport::TestCase
  test "extract_collection_id parses plain collection IDs" do
    assert_equal "adkmjqz", PexelsClient.extract_collection_id("adkmjqz")
    assert_equal "9mp14cx", PexelsClient.extract_collection_id("  9mp14cx  ")
    assert_equal "123456", PexelsClient.extract_collection_id("/123456/")
  end

  test "extract_collection_id extracts ID from full Pexels URLs" do
    assert_equal "adkmjqz", PexelsClient.extract_collection_id("https://www.pexels.com/collections/nature-adkmjqz/")
    assert_equal "adkmjqz", PexelsClient.extract_collection_id("https://www.pexels.com/collections/nature-adkmjqz")
    assert_equal "9mp14cx", PexelsClient.extract_collection_id("https://www.pexels.com/collections/scenic-views-9mp14cx?page=2")
    assert_equal "adkmjqz", PexelsClient.extract_collection_id("https://www.pexels.com/collections/best-of-summer-2026-adkmjqz/#top")
    assert_equal "adkmjqz", PexelsClient.extract_collection_id("https://api.pexels.com/v1/collections/adkmjqz")
  end

  test "extract_collection_id extracts ID from raw slug" do
    assert_equal "adkmjqz", PexelsClient.extract_collection_id("mountain-landscapes-adkmjqz")
    assert_equal "adkmjqz", PexelsClient.extract_collection_id("my-favorite-photos-adkmjqz")
  end

  test "extract_collection_id handles blank or nil input" do
    assert_equal "", PexelsClient.extract_collection_id(nil)
    assert_equal "", PexelsClient.extract_collection_id("")
    assert_equal "", PexelsClient.extract_collection_id("   ")
  end

  test "api_key_configured? reports true when key is present" do
    client = PexelsClient.new(api_key: "test_secret_key_123")
    assert client.api_key_configured?
  end

  test "api_key_configured? reports false when key is nil or empty" do
    client = PexelsClient.new(api_key: "")
    unless ENV["PEXELS_API_KEY"].present?
      assert_not client.api_key_configured?
    end
  end

  test "collection_media returns 400 error when collection_id is blank" do
    client = PexelsClient.new(api_key: "dummy_key")
    response = client.collection_media("")
    assert_not response.success?
    assert_equal 400, response.status_code
    assert_includes response.error_message, "cannot be blank"
  end

  test "collection_media returns demo photos when collection_id is demo" do
    client = PexelsClient.new(api_key: nil)
    response = client.collection_media("demo")
    assert response.success?
    assert response.is_demo?
    assert_equal 200, response.status_code
    assert response.photos.any?
    assert_equal "demo", response.collection_id
    assert_equal 6, response.photos.size
    first_photo = response.photos.first
    assert first_photo["photographer"].present?
    assert first_photo.dig("src", "medium").present?
  end

  test "collection_media returns 401 when API key is missing for live collection" do
    client = PexelsClient.new(api_key: nil)
    original_env = ENV["PEXELS_API_KEY"]
    begin
      ENV["PEXELS_API_KEY"] = nil
      response = client.collection_media("adkmjqz")
      assert_not response.success?
      assert_equal 401, response.status_code
      assert_includes response.error_message, "API key not configured"
    ensure
      ENV["PEXELS_API_KEY"] = original_env
    end
  end

  test "handles simulated 404 response from Pexels API" do
    fake_response = Minitest::Mock.new
    fake_response.expect :code, 404
    fake_response.expect :code, 404
    fake_response.expect :parsed_response, { "error" => "Collection not found" }

    client = PexelsClient.new(api_key: "valid_key")
    PexelsClient.stub :get, fake_response do
      result = client.collection_media("nonexistent_id")
      assert_not result.success?
      assert_equal 404, result.status_code
      assert_includes result.error_message, "404 Not Found"
    end
  end

  test "handles simulated 429 rate limit response from Pexels API" do
    fake_response = Minitest::Mock.new
    fake_response.expect :code, 429
    fake_response.expect :code, 429
    fake_response.expect :parsed_response, { "error" => "Rate limit exceeded" }

    client = PexelsClient.new(api_key: "valid_key")
    PexelsClient.stub :get, fake_response do
      result = client.collection_media("adkmjqz")
      assert_not result.success?
      assert_equal 429, result.status_code
      assert_includes result.error_message, "Rate Limit Exceeded"
    end
  end
end
