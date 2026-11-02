class FlightsController < ApplicationController
  def index
    @airport_options = Airport.order(:code).map { |a| [a.display_label, a.id] }
    @date_options = Flight.available_dates.map do |d|
      [d.strftime("%m/%d/%Y (%A)"), d.strftime("%Y-%m-%d")]
    end
    @passenger_options = (1..4).map { |n| [n == 1 ? "1 Passenger" : "#{n} Passengers", n] }

    @departure_airport_id = resolve_airport_id(params[:departure_airport_id] || params[:departure_code])
    @arrival_airport_id = resolve_airport_id(params[:arrival_airport_id] || params[:arrival_code])
    @selected_date = params[:date]
    @num_tickets = (params[:num_tickets] || 1).to_i.clamp(1, 4)

    @search_performed = params[:commit].present? ||
                        params[:departure_airport_id].present? ||
                        params[:departure_code].present? ||
                        params[:arrival_airport_id].present? ||
                        params[:arrival_code].present? ||
                        params[:date].present?

    if @search_performed
      @flights = Flight.search(
        departure_id: @departure_airport_id,
        arrival_id: @arrival_airport_id,
        date: @selected_date
      )
    else
      @flights = Flight.none
    end
  end

  private

  def resolve_airport_id(value)
    return nil if value.blank?

    if value.to_s =~ /\A\d+\z/
      value.to_i
    else
      Airport.find_by("UPPER(code) = ?", value.to_s.upcase)&.id
    end
  end
end
