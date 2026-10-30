# frozen_string_literal: true

require "httparty"

# PexelsClient interacts with the official Pexels REST API (v1).
# Designed for The Odin Project: Ruby on Rails - Pexels API.
#
# It encapsulates all HTTP communication, authorization header injection,
# parameter sanitation, error handling, and URL parsing.
class PexelsClient
  include HTTParty
  base_uri "https://api.pexels.com/v1"

  # Response data structure returned by client methods
  Response = Struct.new(
    :success?,
    :photos,
    :total_results,
    :page,
    :per_page,
    :next_page,
    :prev_page,
    :error_message,
    :status_code,
    :collection_id,
    :is_demo?,
    keyword_init: true
  )

  attr_reader :api_key

  def initialize(api_key: nil)
    @api_key = api_key.presence ||
               ENV["PEXELS_API_KEY"].presence ||
               (Rails.application.credentials.respond_to?(:pexels_api_key) ? Rails.application.credentials.pexels_api_key.presence : nil) ||
               (Rails.application.credentials.respond_to?(:dig) ? Rails.application.credentials.dig(:pexels, :api_key).presence : nil)
  end

  # Checks if a valid API key is present
  def api_key_configured?
    @api_key.present?
  end

  # Fetches photos for a specific Pexels collection
  # Endpoint: GET https://api.pexels.com/v1/collections/:id
  #
  # @param collection_id [String] The collection ID or full Pexels collection URL
  # @param page [Integer] Page number (default: 1)
  # @param per_page [Integer] Photos per page (default: 15, max: 80)
  # @param type [String] Media filter: 'photos', 'videos', or nil (default: 'photos')
  # @return [PexelsClient::Response]
  def collection_media(collection_id, page: 1, per_page: 15, type: "photos")
    cleaned_id = self.class.extract_collection_id(collection_id)

    if cleaned_id.blank?
      return Response.new(
        success?: false,
        photos: [],
        total_results: 0,
        page: page.to_i,
        per_page: per_page.to_i,
        error_message: "Collection ID cannot be blank. Please enter a Pexels collection ID or collection URL.",
        status_code: 400,
        collection_id: collection_id,
        is_demo?: false
      )
    end

    # Return demo data if requested or collection ID is "demo"
    if cleaned_id.casecmp("demo").zero?
      return demo_response(collection_id: "demo", page: page, per_page: per_page)
    end

    unless api_key_configured?
      return Response.new(
        success?: false,
        photos: [],
        total_results: 0,
        page: page.to_i,
        per_page: per_page.to_i,
        error_message: "Pexels API key not configured. Add PEXELS_API_KEY to your .env file or credentials, or explore the Demo Gallery.",
        status_code: 401,
        collection_id: cleaned_id,
        is_demo?: false
      )
    end

    per_page_val = per_page.to_i > 0 ? per_page.to_i : 15
    query_params = {
      type: type,
      page: [ page.to_i, 1 ].max,
      per_page: per_page_val.clamp(1, 80)
    }.compact

    begin
      response = self.class.get(
        "/collections/#{CGI.escape(cleaned_id)}",
        headers: request_headers,
        query: query_params,
        timeout: 10
      )

      parse_collection_response(response, collection_id: cleaned_id)
    rescue Net::OpenTimeout, Net::ReadTimeout, Timeout::Error
      Response.new(
        success?: false,
        photos: [],
        total_results: 0,
        page: page.to_i,
        per_page: per_page.to_i,
        error_message: "Request to Pexels timed out. Please check your internet connection and try again.",
        status_code: 504,
        collection_id: cleaned_id,
        is_demo?: false
      )
    rescue SocketError => e
      Response.new(
        success?: false,
        photos: [],
        total_results: 0,
        page: page.to_i,
        per_page: per_page.to_i,
        error_message: "Unable to reach Pexels server (#{e.message}). Please verify your network connection.",
        status_code: 503,
        collection_id: cleaned_id,
        is_demo?: false
      )
    rescue StandardError => e
      Response.new(
        success?: false,
        photos: [],
        total_results: 0,
        page: page.to_i,
        per_page: per_page.to_i,
        error_message: "An unexpected error occurred: #{e.message}",
        status_code: 500,
        collection_id: cleaned_id,
        is_demo?: false
      )
    end
  end

  # Fetches featured collections from Pexels
  # Endpoint: GET https://api.pexels.com/v1/collections/featured
  def featured_collections(page: 1, per_page: 10)
    return [] unless api_key_configured?

    begin
      response = self.class.get(
        "/collections/featured",
        headers: request_headers,
        query: { page: page, per_page: per_page },
        timeout: 10
      )

      if response.success?
        response.parsed_response["collections"] || []
      else
        []
      end
    rescue StandardError
      []
    end
  end

  # Fetches collections created by the authenticated user
  # Endpoint: GET https://api.pexels.com/v1/collections
  def my_collections(page: 1, per_page: 10)
    return [] unless api_key_configured?

    begin
      response = self.class.get(
        "/collections",
        headers: request_headers,
        query: { page: page, per_page: per_page },
        timeout: 10
      )

      if response.success?
        response.parsed_response["collections"] || []
      else
        []
      end
    rescue StandardError
      []
    end
  end

  # Extracts the collection ID from raw ID strings or Pexels URLs.
  # Handles forms like:
  #   - "adkmjqz"
  #   - "https://www.pexels.com/collections/nature-adkmjqz/"
  #   - "https://www.pexels.com/collections/nature-adkmjqz?page=2"
  #   - "https://www.pexels.com/collections/adkmjqz"
  #   - "mountain-landscapes-adkmjqz"
  def self.extract_collection_id(input)
    return "" if input.blank?

    str = input.to_s.strip
    # Strip URL query parameters or hash anchors
    str = str.split("?").first.to_s.split("#").first.to_s.strip

    # Check for Pexels collection URL format
    if str =~ %r{collections/([^/?#]+)}i
      slug = Regexp.last_match(1).to_s.strip
      extract_id_from_slug(slug)
    elsif str.include?("-")
      extract_id_from_slug(str)
    else
      # Bare collection ID
      str.gsub(%r{\A/+}, "").gsub(%r{/+\z}, "").strip
    end
  end

  def self.extract_id_from_slug(slug)
    cleaned = slug.gsub(%r{\A/+}, "").gsub(%r{/+\z}, "").strip
    if cleaned.include?("-")
      # Pexels collection URLs format is "collectionTitle-collectionID"
      # e.g., "amazing-nature-adkmjqz" -> "adkmjqz"
      last_part = cleaned.split("-").last
      last_part.present? ? last_part : cleaned
    else
      cleaned
    end
  end

  private

  def request_headers
    {
      "Authorization" => @api_key,
      "User-Agent" => "OdinRecipesPexelsApp/1.0"
    }
  end

  def parse_collection_response(response, collection_id:)
    case response.code
    when 200..299
      data = response.parsed_response
      raw_media = data.is_a?(Hash) ? (data["media"] || []) : []

      # Filter for photos and map to consistent format
      photos = raw_media.select do |item|
        item["type"] == "Photo" || item["src"].present?
      end

      Response.new(
        success?: true,
        photos: photos,
        total_results: data["total_results"] || photos.size,
        page: data["page"] || 1,
        per_page: data["per_page"] || photos.size,
        next_page: data["next_page"],
        prev_page: data["prev_page"],
        error_message: nil,
        status_code: response.code,
        collection_id: collection_id,
        is_demo?: false
      )
    when 401
      Response.new(
        success?: false,
        photos: [],
        total_results: 0,
        page: 1,
        per_page: 15,
        error_message: "401 Unauthorized: Invalid Pexels API Key. Please verify your API key in .env or your Rails credentials.",
        status_code: 401,
        collection_id: collection_id,
        is_demo?: false
      )
    when 404
      Response.new(
        success?: false,
        photos: [],
        total_results: 0,
        page: 1,
        per_page: 15,
        error_message: "404 Not Found: Collection '#{collection_id}' was not found. Please verify the collection ID and make sure it is public.",
        status_code: 404,
        collection_id: collection_id,
        is_demo?: false
      )
    when 429
      Response.new(
        success?: false,
        photos: [],
        total_results: 0,
        page: 1,
        per_page: 15,
        error_message: "429 Rate Limit Exceeded: You have exceeded the Pexels hourly API rate limit (200 requests/hour). Please wait before trying again.",
        status_code: 429,
        collection_id: collection_id,
        is_demo?: false
      )
    else
      err_detail = response.parsed_response.is_a?(Hash) ? (response.parsed_response["error"] || response.parsed_response["message"]) : response.message
      Response.new(
        success?: false,
        photos: [],
        total_results: 0,
        page: 1,
        per_page: 15,
        error_message: "Pexels API Error (HTTP #{response.code}): #{err_detail.presence || 'Unknown API error'}",
        status_code: response.code,
        collection_id: collection_id,
        is_demo?: false
      )
    end
  end

  def demo_response(collection_id:, page: 1, per_page: 15)
    all_demo_photos = [
      {
        "id" => 2014422,
        "width" => 3000,
        "height" => 2000,
        "url" => "https://www.pexels.com/photo/brown-rocks-during-golden-hour-2014422/",
        "photographer" => "Joey Farina",
        "photographer_url" => "https://www.pexels.com/@joey",
        "photographer_id" => 1045053,
        "avg_color" => "#91694A",
        "src" => {
          "original" => "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg",
          "large2x" => "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
          "large" => "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&h=650&w=940",
          "medium" => "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&h=350&w=650",
          "small" => "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&h=130&w=130",
          "portrait" => "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800",
          "landscape" => "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=627&w=1200",
          "tiny" => "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=200"
        },
        "alt" => "Brown Rocks During Golden Hour in the Coastal Shore"
      },
      {
        "id" => 1287145,
        "width" => 4000,
        "height" => 2667,
        "url" => "https://www.pexels.com/photo/silhouette-of-mountains-under-cloudy-sky-1287145/",
        "photographer" => "Eberhard Grossgasteiger",
        "photographer_url" => "https://www.pexels.com/@eberhardgross",
        "photographer_id" => 121938,
        "avg_color" => "#5D6874",
        "src" => {
          "original" => "https://images.pexels.com/photos/1287145/pexels-photo-1287145.jpeg",
          "large2x" => "https://images.pexels.com/photos/1287145/pexels-photo-1287145.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
          "large" => "https://images.pexels.com/photos/1287145/pexels-photo-1287145.jpeg?auto=compress&cs=tinysrgb&h=650&w=940",
          "medium" => "https://images.pexels.com/photos/1287145/pexels-photo-1287145.jpeg?auto=compress&cs=tinysrgb&h=350&w=650",
          "small" => "https://images.pexels.com/photos/1287145/pexels-photo-1287145.jpeg?auto=compress&cs=tinysrgb&h=130&w=130",
          "portrait" => "https://images.pexels.com/photos/1287145/pexels-photo-1287145.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800",
          "landscape" => "https://images.pexels.com/photos/1287145/pexels-photo-1287145.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=627&w=1200",
          "tiny" => "https://images.pexels.com/photos/1287145/pexels-photo-1287145.jpeg?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=200"
        },
        "alt" => "Dramatic Silhouette of Alpine Mountain Peaks Under Cloudy Sky"
      },
      {
        "id" => 1366919,
        "width" => 3567,
        "height" => 5350,
        "url" => "https://www.pexels.com/photo/pine-trees-covered-in-fog-1366919/",
        "photographer" => "Eberhard Grossgasteiger",
        "photographer_url" => "https://www.pexels.com/@eberhardgross",
        "photographer_id" => 121938,
        "avg_color" => "#434B52",
        "src" => {
          "original" => "https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg",
          "large2x" => "https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
          "large" => "https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&h=650&w=940",
          "medium" => "https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&h=350&w=650",
          "small" => "https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&h=130&w=130",
          "portrait" => "https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800",
          "landscape" => "https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=627&w=1200",
          "tiny" => "https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=200"
        },
        "alt" => "Pine Trees Covered in Mysterious Morning Mountain Fog"
      },
      {
        "id" => 3573382,
        "width" => 3840,
        "height" => 5760,
        "url" => "https://www.pexels.com/photo/body-of-water-surrounded-by-trees-3573382/",
        "photographer" => "Simon Berger",
        "photographer_url" => "https://www.pexels.com/@simon-berger",
        "photographer_id" => 715364,
        "avg_color" => "#2E3B32",
        "src" => {
          "original" => "https://images.pexels.com/photos/3573382/pexels-photo-3573382.jpeg",
          "large2x" => "https://images.pexels.com/photos/3573382/pexels-photo-3573382.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
          "large" => "https://images.pexels.com/photos/3573382/pexels-photo-3573382.jpeg?auto=compress&cs=tinysrgb&h=650&w=940",
          "medium" => "https://images.pexels.com/photos/3573382/pexels-photo-3573382.jpeg?auto=compress&cs=tinysrgb&h=350&w=650",
          "small" => "https://images.pexels.com/photos/3573382/pexels-photo-3573382.jpeg?auto=compress&cs=tinysrgb&h=130&w=130",
          "portrait" => "https://images.pexels.com/photos/3573382/pexels-photo-3573382.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800",
          "landscape" => "https://images.pexels.com/photos/3573382/pexels-photo-3573382.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=627&w=1200",
          "tiny" => "https://images.pexels.com/photos/3573382/pexels-photo-3573382.jpeg?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=200"
        },
        "alt" => "Turquoise Emerald Alpine Lake Surrounded by Dense Forest"
      },
      {
        "id" => 15286,
        "width" => 2500,
        "height" => 1667,
        "url" => "https://www.pexels.com/photo/shallow-focus-photography-of-green-trees-15286/",
        "photographer" => "Luis del Río",
        "photographer_url" => "https://www.pexels.com/@luisdelrio",
        "photographer_id" => 1045,
        "avg_color" => "#374233",
        "src" => {
          "original" => "https://images.pexels.com/photos/15286/pexels-photo.jpg",
          "large2x" => "https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
          "large" => "https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&h=650&w=940",
          "medium" => "https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&h=350&w=650",
          "small" => "https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&h=130&w=130",
          "portrait" => "https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800",
          "landscape" => "https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&fit=crop&h=627&w=1200",
          "tiny" => "https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=200"
        },
        "alt" => "Person Walking Through a Serene Sunlit Forest Trail"
      },
      {
        "id" => 3408744,
        "width" => 3648,
        "height" => 5472,
        "url" => "https://www.pexels.com/photo/scenic-view-of-snow-capped-mountains-3408744/",
        "photographer" => "Stein Egil Liland",
        "photographer_url" => "https://www.pexels.com/@steinegil",
        "photographer_id" => 647970,
        "avg_color" => "#39434E",
        "src" => {
          "original" => "https://images.pexels.com/photos/3408744/pexels-photo-3408744.jpeg",
          "large2x" => "https://images.pexels.com/photos/3408744/pexels-photo-3408744.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
          "large" => "https://images.pexels.com/photos/3408744/pexels-photo-3408744.jpeg?auto=compress&cs=tinysrgb&h=650&w=940",
          "medium" => "https://images.pexels.com/photos/3408744/pexels-photo-3408744.jpeg?auto=compress&cs=tinysrgb&h=350&w=650",
          "small" => "https://images.pexels.com/photos/3408744/pexels-photo-3408744.jpeg?auto=compress&cs=tinysrgb&h=130&w=130",
          "portrait" => "https://images.pexels.com/photos/3408744/pexels-photo-3408744.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800",
          "landscape" => "https://images.pexels.com/photos/3408744/pexels-photo-3408744.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=627&w=1200",
          "tiny" => "https://images.pexels.com/photos/3408744/pexels-photo-3408744.jpeg?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=200"
        },
        "alt" => "Majestic Snow Capped Peaks Reflecting in Arctic Fjord Waters"
      }
    ]

    per_page_val = per_page.to_i > 0 ? per_page.to_i : 15
    Response.new(
      success?: true,
      photos: all_demo_photos,
      total_results: all_demo_photos.size,
      page: [ page.to_i, 1 ].max,
      per_page: per_page_val.clamp(1, 80),
      next_page: nil,
      prev_page: nil,
      error_message: nil,
      status_code: 200,
      collection_id: "demo",
      is_demo?: true
    )
  end
end
