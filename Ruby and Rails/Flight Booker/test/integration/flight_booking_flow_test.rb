require "test_helper"

class FlightBookingFlowTest < ActionDispatch::IntegrationTest
  setup do
    @sfo = Airport.find_or_create_by!(code: "SFO", city: "San Francisco", name: "San Francisco Int Airport")
    @nyc = Airport.find_or_create_by!(code: "NYC", city: "New York", name: "JFK Int Airport")
    @flight = Flight.create!(
      departure_airport: @sfo,
      arrival_airport: @nyc,
      start_datetime: 2.days.from_now.change(hour: 10, min: 0),
      duration: 330,
      flight_number: "TEST-100"
    )
  end

  test "root page displays search form and dropdowns" do
    get root_path
    assert_response :success
    assert_select "#departure_airport_id"
    assert_select "#arrival_airport_id"
    assert_select "#num_tickets"
    assert_select "#date"
  end

  test "searching for flights returns available matching flights with radio buttons" do
    get flights_path, params: {
      departure_airport_id: @sfo.id,
      arrival_airport_id: @nyc.id,
      date: @flight.start_datetime.to_date.to_s,
      num_tickets: 2
    }
    assert_response :success
    assert_select "#flight_selection_form"
    assert_select "input[type=radio][name=flight_id][value='#{@flight.id}']"
    assert_select "input[type=hidden][name=num_tickets][value='2']"
  end

  test "selecting a flight renders booking form with sub-forms for passengers" do
    get new_booking_path, params: {
      flight_id: @flight.id,
      num_tickets: 2
    }
    assert_response :success
    assert_select "#booking_passengers_form"
    assert_select "input[name='booking[passengers_attributes][0][name]']"
    assert_select "input[name='booking[passengers_attributes][0][email]']"
    assert_select "input[name='booking[passengers_attributes][1][name]']"
    assert_select "input[name='booking[passengers_attributes][1][email]']"
  end

  test "submitting booking form creates booking and passengers and redirects to show" do
    assert_difference -> { Booking.count } => 1, -> { Passenger.count } => 2 do
      post bookings_path, params: {
        booking: {
          flight_id: @flight.id,
          passengers_attributes: {
            "0" => { name: "Alice Test", email: "alice@test.com" },
            "1" => { name: "Bob Test", email: "bob@test.com" }
          }
        }
      }
    end

    booking = Booking.last
    assert_redirected_to booking_path(booking)
    follow_redirect!
    assert_response :success
    assert_select "#booking-reference-code", text: booking.booking_reference
    assert_select ".cell-value.strong", text: "Alice Test"
    assert_select ".cell-value.strong", text: "Bob Test"
  end
end
