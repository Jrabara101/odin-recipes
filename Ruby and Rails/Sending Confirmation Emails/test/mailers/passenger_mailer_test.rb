require "test_helper"

class PassengerMailerTest < ActionMailer::TestCase
  setup do
    @sfo = Airport.find_or_create_by!(code: "SFO", city: "San Francisco", name: "San Francisco Int Airport")
    @jfk = Airport.find_or_create_by!(code: "JFK", city: "New York", name: "John F Kennedy Int Airport")
    @flight = Flight.create!(
      departure_airport: @sfo,
      arrival_airport: @jfk,
      start_datetime: 3.days.from_now.change(hour: 9, min: 30),
      duration: 330,
      flight_number: "AERO-777"
    )
    @booking = Booking.new(flight: @flight)
    @passenger = @booking.passengers.build(name: "Jane Explorer", email: "jane@example.com")
    @booking.save!
  end

  test "confirmation_email sends to passenger email with proper subject and headers" do
    email = PassengerMailer.confirmation_email(@passenger)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["jane@example.com"], email.to
    assert_equal ["no-reply@flightbooker.com"], email.from
    assert_includes email.subject, "Flight Booking Confirmation"
    assert_includes email.subject, @flight.flight_number
    assert_includes email.subject, @booking.booking_reference
  end

  test "confirmation_email renders both HTML and plain text bodies with itinerary details" do
    email = PassengerMailer.confirmation_email(@passenger)

    # Multi-part message (HTML and Text)
    assert email.multipart?
    assert_equal 2, email.parts.size

    # Check HTML part
    html_body = email.html_part.body.to_s
    assert_includes html_body, "Jane Explorer"
    assert_includes html_body, @booking.booking_reference
    assert_includes html_body, "AERO-777"
    assert_includes html_body, "SFO"
    assert_includes html_body, "JFK"
    assert_includes html_body, "View Boarding Pass Online"

    # Check Plain text part
    text_body = email.text_part.body.to_s
    assert_includes text_body, "Hello Jane Explorer"
    assert_includes text_body, @booking.booking_reference
    assert_includes text_body, "AERO-777"
    assert_includes text_body, "SFO"
    assert_includes text_body, "JFK"
  end

  test "confirmation_email also works via ActionMailer parameterized syntax" do
    email = PassengerMailer.with(passenger: @passenger).confirmation_email
    assert_equal ["jane@example.com"], email.to
    assert_includes email.subject, @booking.booking_reference
  end
end

