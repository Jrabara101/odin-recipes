# frozen_string_literal: true

class StaticPagesController < ApplicationController
  def home
    @raw_input = params[:collection_id]

    # Support 1-click Demo preview
    if params[:demo].present? && @raw_input.blank?
      @raw_input = "demo"
    end

    @collection_id = PexelsClient.extract_collection_id(@raw_input)
    @page = [ params[:page].to_i, 1 ].max
    per_page_val = params[:per_page].to_i > 0 ? params[:per_page].to_i : 15
    @per_page = per_page_val.clamp(1, 80)

    @client = PexelsClient.new
    @api_key_configured = @client.api_key_configured?

    if @collection_id.present?
      @response = @client.collection_media(
        @collection_id,
        page: @page,
        per_page: @per_page
      )

      @photos = @response.photos
      @total_results = @response.total_results
      @error_message = @response.error_message
      @is_demo = @response.is_demo?
    else
      @photos = []
      @total_results = 0
      @error_message = nil
      @is_demo = false

      # If the API key is configured and no collection ID provided yet,
      # fetch a few featured collections to display as quick-action pills.
      if @api_key_configured
        @featured_collections = @client.featured_collections(per_page: 6)
      end
    end

    respond_to do |format|
      format.html
      format.json do
        if @response
          render json: {
            success: @response.success?,
            collection_id: @collection_id,
            total_results: @total_results,
            page: @page,
            per_page: @per_page,
            photos: @photos,
            error: @error_message
          }, status: @response.status_code || 200
        else
          render json: {
            success: true,
            message: "Provide a collection_id query parameter to fetch photos",
            api_key_configured: @api_key_configured
          }
        end
      end
    end
  end
end
